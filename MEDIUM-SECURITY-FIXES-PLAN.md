# Medium Security Issues - Remediation Plan

**Timeline:** 2 weeks  
**Priority Level:** Medium  
**Total Issues:** 8 (4 Backend, 4 Frontend)

---

## Backend (Laravel) - 4 Issues

### 1. Mass Assignment Vulnerability on User Model ⚠️

**Current Issue:**
- `roles` field is included in `$fillable` array on User model
- Allows attackers to assign themselves admin roles via mass assignment

**Location:** `hudson-life-dispatch-backend/app/Models/User.php`

**Fix Steps:**
1. Remove `roles` from `$fillable` array
2. Add `roles` to `$guarded` array (or keep it out entirely)
3. Create explicit setter method for role changes:
   ```php
   public function assignRole(string $role): void
   {
       if (!in_array($role, ['user', 'admin', 'editor'])) {
           throw new InvalidArgumentException('Invalid role');
       }
       $this->roles = $role;
       $this->save();
   }
   ```
4. Update all controllers that modify roles to use the new method
5. Add test cases to verify mass assignment is blocked

**Files to Modify:**
- `app/Models/User.php`
- Any controllers that update user roles
- Add test in `tests/Feature/UserSecurityTest.php`

**Verification:**
```php
// This should fail:
User::create(['name' => 'Test', 'roles' => 'admin']);
```

---

### 2. CORS Configuration - Staging Origin with Credentials ⚠️

**Current Issue:**
- CORS allows staging origin with `supports_credentials: true`
- Increases risk of credential theft if staging environment is compromised

**Location:** `hudson-life-dispatch-backend/config/cors.php`

**Fix Steps:**
1. Review `allowed_origins` in `config/cors.php`
2. If staging origin is needed, set `supports_credentials: false` for non-production origins
3. Implement environment-based CORS configuration:
   ```php
   'supports_credentials' => env('APP_ENV') === 'production',
   'allowed_origins' => env('APP_ENV') === 'production' 
       ? [env('FRONTEND_URL')] 
       : [env('FRONTEND_URL'), env('STAGING_FRONTEND_URL')],
   ```
4. Update `.env.example` with clear documentation
5. Consider using separate CORS middleware for API vs web routes

**Files to Modify:**
- `config/cors.php`
- `.env.example`
- Possibly `app/Http/Kernel.php` for route-specific CORS

**Verification:**
- Test OPTIONS requests from staging origin
- Verify credentials are NOT accepted from non-production origins

---

### 3. Inconsistent Rate Limiting Across Endpoints ⚠️

**Current Issue:**
- Some API endpoints have rate limiting, others don't
- Inconsistent limits (some 60/min, others 100/min)
- No rate limiting on expensive operations

**Locations:**
- Various controllers and routes
- `routes/api.php`
- `routes/web.php`

**Fix Steps:**
1. Audit all endpoints and categorize:
   - Public endpoints: 60 requests/minute
   - Authenticated endpoints: 300 requests/minute
   - Admin endpoints: 1000 requests/minute
   - Resource-intensive (search, exports): 10 requests/minute
   - Webhook endpoints: 100 requests/minute

2. Create named rate limit groups in `app/Providers/RouteServiceProvider.php`:
   ```php
   RateLimiter::for('public', function (Request $request) {
       return Limit::perMinute(60)->by($request->ip());
   });
   
   RateLimiter::for('authenticated', function (Request $request) {
       return Limit::perMinute(300)->by($request->user()?->id ?? $request->ip());
   });
   
   RateLimiter::for('resource-intensive', function (Request $request) {
       return Limit::perMinute(10)->by($request->user()?->id ?? $request->ip());
   });
   ```

3. Apply rate limiters consistently in routes:
   ```php
   Route::middleware(['throttle:public'])->group(function () {
       // Public routes
   });
   ```

4. Add rate limit headers to responses
5. Document rate limits in API documentation

**Files to Modify:**
- `app/Providers/RouteServiceProvider.php`
- `routes/api.php`
- `routes/web.php`
- All API controllers (add `@throttle` annotations)

**Verification:**
- Test each endpoint type with rate limit testing tool
- Verify 429 responses are returned with proper headers
- Test that authenticated users get higher limits

---

### 4. Clerk Role Preservation Bug ⚠️

**Current Issue:**
- Clerk auth middleware resets user roles on every login
- Role changes made in admin panel get overwritten
- Potential privilege escalation/de-escalation issues

**Location:** `hudson-life-dispatch-backend/app/Http/Middleware/ClerkAuth.php`

**Fix Steps:**
1. Locate the Clerk middleware that handles user sync
2. Modify role sync logic:
   ```php
   // Current (problematic):
   $user->roles = $clerkUser['public_metadata']['roles'] ?? 'user';
   
   // Fixed (preserve local roles):
   if ($user->wasRecentlyCreated) {
       // Only set roles for new users
       $user->roles = $clerkUser['public_metadata']['roles'] ?? 'user';
   }
   // For existing users, keep local roles as source of truth
   ```

3. Alternative: Sync roles FROM Laravel TO Clerk (make Laravel authoritative):
   ```php
   // Push local roles to Clerk metadata
   if ($user->roles !== $clerkUser['public_metadata']['roles']) {
       $this->syncRolesToClerk($user);
   }
   ```

4. Add database migration to track last role sync timestamp
5. Implement role audit logging

**Files to Modify:**
- `app/Http/Middleware/ClerkAuth.php` or equivalent
- Create new migration: `xxxx_add_role_sync_tracking_to_users_table.php`
- Add `app/Services/ClerkRoleSyncService.php`

**Verification:**
- Create test user, assign admin role
- Log out and log back in
- Verify role is preserved
- Add automated test case

---

## Frontend (Next.js) - 4 Issues

### 5. TypeScript Build Errors Ignored ⚠️

**Current Issue:**
- `ignoreBuildErrors: true` in Next.js config
- Type errors are hidden, reducing code quality and safety
- May hide security-relevant type mismatches

**Location:** `hudson-life-dispatch-frontend/next.config.mjs`

**Fix Steps:**
1. Remove `ignoreBuildErrors: true` from `next.config.mjs`
2. Run `npm run build` to identify all TypeScript errors
3. Create tracking document for errors found
4. Fix errors in priority order:
   - Security-relevant (auth, data validation): Fix immediately
   - Data integrity (API types, form handling): Fix in sprint 1
   - UI/UX types: Fix in sprint 2
   - Non-critical: Fix incrementally

5. Add pre-commit hook to prevent new type errors:
   ```json
   // package.json
   {
     "husky": {
       "hooks": {
         "pre-commit": "tsc --noEmit"
       }
     }
   }
   ```

**Files to Modify:**
- `next.config.mjs`
- All files with TypeScript errors
- `package.json` (add husky/lint-staged)
- `.husky/pre-commit`

**Verification:**
- `npm run build` completes without errors
- `tsc --noEmit` passes
- Pre-commit hook blocks commits with type errors

---

### 6. Missing iframe Domain Whitelist in Sanitizer ⚠️

**Current Issue:**
- HTML sanitizer allows iframes without domain restrictions
- Could be exploited for phishing or malicious content embedding
- Particularly risky in user-generated content

**Location:** Search for `sanitizeHtml` usage and configuration

**Fix Steps:**
1. Locate HTML sanitization configuration (likely in `lib/sanitize.ts` or similar)
2. Add iframe allowlist:
   ```typescript
   const ALLOWED_IFRAME_DOMAINS = [
     'youtube.com',
     'www.youtube.com',
     'youtube-nocookie.com',
     'vimeo.com',
     'player.vimeo.com',
     // Add other trusted domains
   ];
   
   const sanitizerConfig = {
     allowedTags: ['iframe', /* ... */],
     allowedAttributes: {
       iframe: ['src', 'width', 'height', 'frameborder', 'allow', 'allowfullscreen']
     },
     allowedIframeHostnames: ALLOWED_IFRAME_DOMAINS
   };
   ```

3. Create validation function:
   ```typescript
   function isAllowedIframeSrc(src: string): boolean {
     try {
       const url = new URL(src);
       return ALLOWED_IFRAME_DOMAINS.some(domain => 
         url.hostname === domain || url.hostname.endsWith('.' + domain)
       );
     } catch {
       return false;
     }
   }
   ```

4. Apply to all user-generated content areas:
   - Event descriptions
   - Story submissions
   - Partner profiles
   - Newsletter content

**Files to Modify:**
- `lib/sanitize.ts` (or create if doesn't exist)
- `components/events/EventDetail.tsx`
- `components/stories/StoryContent.tsx`
- Any component using `dangerouslySetInnerHTML`

**Verification:**
- Test with valid YouTube embed (should work)
- Test with malicious iframe (should be stripped)
- Test with unknown domain (should be blocked)

---

### 7. IP Address Spoofing for Rate Limit Bypass ⚠️

**Current Issue:**
- Rate limiting uses `request.ip` which can be spoofed via X-Forwarded-For header
- Attackers can bypass rate limits by rotating IP addresses in headers
- No verification that X-Forwarded-For is from trusted proxy

**Location:** Rate limiting middleware and API routes

**Fix Steps:**
1. Configure trusted proxy in Next.js middleware:
   ```typescript
   // middleware.ts
   const TRUSTED_PROXIES = [
     '10.0.0.0/8',      // Private network
     '172.16.0.0/12',   // Private network
     '192.168.0.0/16',  // Private network
     // Add Fly.io proxy IPs if applicable
   ];
   
   function getTrustedClientIP(request: Request): string {
     const forwardedFor = request.headers.get('x-forwarded-for');
     const realIP = request.headers.get('x-real-ip');
     const directIP = request.ip;
     
     // Only trust X-Forwarded-For if request comes from trusted proxy
     if (isTrustedProxy(directIP) && forwardedFor) {
       return forwardedFor.split(',')[0].trim();
     }
     
     return realIP || directIP || 'unknown';
   }
   ```

2. Update all rate limiting to use trusted IP:
   ```typescript
   // lib/rate-limit.ts
   export function rateLimit(request: Request) {
     const ip = getTrustedClientIP(request);
     const identifier = `rate_limit:${ip}`;
     // ... rest of rate limiting logic
   }
   ```

3. Add IP validation and logging:
   ```typescript
   if (isRateLimited) {
     console.warn('Rate limit exceeded', {
       trustedIP: getTrustedClientIP(request),
       headers: {
         'x-forwarded-for': request.headers.get('x-forwarded-for'),
         'x-real-ip': request.headers.get('x-real-ip'),
       },
       timestamp: new Date().toISOString()
     });
   }
   ```

**Files to Modify:**
- `middleware.ts`
- `lib/rate-limit.ts` (or wherever rate limiting is implemented)
- All API routes that implement rate limiting
- Add `lib/trusted-ip.ts` for IP validation utilities

**Verification:**
- Test rate limiting with spoofed X-Forwarded-For header
- Verify rate limit still applies
- Test from actual different IPs (if possible)
- Review logs for suspicious patterns

---

### 8. No Request Body Size Limits ⚠️

**Current Issue:**
- API routes accept unlimited request body sizes
- Could lead to DoS attacks via large payloads
- Memory exhaustion possible
- Particularly risky for file uploads and story submissions

**Location:** All API routes, especially:
- `app/api/stories/submit/route.ts`
- `app/api/waitlist/route.ts`
- `app/api/partners/submit/route.ts`

**Fix Steps:**
1. Configure global body size limit in `next.config.mjs`:
   ```javascript
   export default {
     api: {
       bodyParser: {
         sizeLimit: '1mb', // Default for most routes
       },
     },
   };
   ```

2. Create middleware for body size validation:
   ```typescript
   // lib/middleware/body-size-limit.ts
   export function createBodySizeLimit(maxSize: number) {
     return async (request: Request) => {
       const contentLength = request.headers.get('content-length');
       if (contentLength && parseInt(contentLength) > maxSize) {
         return new Response('Payload too large', { status: 413 });
       }
     };
   }
   ```

3. Apply route-specific limits:
   ```typescript
   // app/api/stories/submit/route.ts
   export const config = {
     api: {
       bodyParser: {
         sizeLimit: '10mb', // Larger for story submissions with images
       },
     },
   };
   
   // In the handler:
   const sizeCheck = await createBodySizeLimit(10 * 1024 * 1024)(request);
   if (sizeCheck) return sizeCheck;
   ```

4. Configure size limits per route type:
   - Standard API calls: 1MB
   - Story submissions: 10MB
   - Image uploads: 5MB
   - Waitlist submissions: 100KB
   - Search queries: 10KB

5. Add monitoring for large request attempts

**Files to Modify:**
- `next.config.mjs`
- Create `lib/middleware/body-size-limit.ts`
- `app/api/stories/submit/route.ts`
- `app/api/waitlist/route.ts`
- `app/api/partners/submit/route.ts`
- All other API routes

**Verification:**
- Test each endpoint with oversized payloads
- Verify 413 responses are returned
- Test legitimate large payloads (story submissions) work correctly
- Monitor memory usage under load

---

## Implementation Schedule (2 Weeks)

### Week 1 (Days 1-5)
**Day 1-2:** Backend Issues
- [ ] Fix User model mass assignment vulnerability
- [ ] Update CORS configuration
- [ ] Create comprehensive test suite for both

**Day 3-4:** Backend Issues Continued
- [ ] Implement consistent rate limiting framework
- [ ] Fix Clerk role preservation bug
- [ ] Test role sync edge cases

**Day 5:** Testing & Verification
- [ ] Run full backend security test suite
- [ ] Verify all backend fixes work in staging
- [ ] Document changes

### Week 2 (Days 6-10)
**Day 6-7:** Frontend Issues
- [ ] Remove `ignoreBuildErrors` and fix TypeScript errors (high priority ones first)
- [ ] Add iframe domain whitelist to sanitizer
- [ ] Test content rendering with various inputs

**Day 8-9:** Frontend Issues Continued
- [ ] Implement trusted IP resolution for rate limiting
- [ ] Add request body size limits to all API routes
- [ ] Create monitoring dashboards

**Day 10:** Final Testing & Documentation
- [ ] Full security regression testing
- [ ] Deploy to staging environment
- [ ] Update security documentation
- [ ] Create runbook for monitoring these fixes

---

## Testing Requirements

### Automated Tests to Add
1. **User Model Security Test**
   - Test mass assignment blocking
   - Test role assignment method works
   - Test unauthorized role changes are rejected

2. **CORS Security Test**
   - Test staging origin with credentials fails
   - Test production origin works correctly
   - Test OPTIONS requests

3. **Rate Limiting Test Suite**
   - Test each rate limit tier
   - Test IP-based limiting
   - Test user-based limiting
   - Test rate limit reset timing

4. **Role Preservation Test**
   - Test role persists across logins
   - Test role sync doesn't overwrite local changes
   - Test audit log creation

5. **Frontend Security Tests**
   - TypeScript compilation in CI/CD
   - Iframe domain validation
   - IP spoofing resistance
   - Body size limit enforcement

### Manual Testing Checklist
- [ ] Attempt to assign admin role via API (should fail)
- [ ] Verify staging CORS with credentials blocked
- [ ] Test rate limits on all endpoints
- [ ] Change user role in admin, logout/login, verify preserved
- [ ] Build TypeScript without errors
- [ ] Attempt to inject malicious iframe (should be blocked)
- [ ] Spoof X-Forwarded-For header (should not bypass rate limit)
- [ ] Send oversized request body (should get 413)

---

## Rollback Plan

If any fix causes issues:

1. **User Model Changes:** Revert migration, restore $fillable array
2. **CORS Changes:** Restore previous config/cors.php
3. **Rate Limiting:** Disable throttle middleware temporarily
4. **Clerk Role Sync:** Add feature flag to toggle old/new behavior
5. **TypeScript:** Re-add `ignoreBuildErrors: true` temporarily
6. **Iframe Whitelist:** Make allowlist permissive temporarily
7. **IP Trust:** Fallback to direct IP reading
8. **Body Size Limits:** Increase limits or disable checks

Each fix should be deployed independently with monitoring and rollback capability.

---

## Monitoring Post-Deployment

### Metrics to Watch
- 401/403 error rates (authentication issues)
- 413 error rates (body size limit hits)
- 429 error rates (rate limit hits)
- Role sync failures
- Build failure rates
- Content sanitization blocks

### Alerts to Configure
- Spike in 413 errors (may indicate legitimate need for larger limits)
- Increase in failed role syncs
- TypeScript build failures in CI/CD
- Unusual rate limit patterns (potential attack)

---

## Success Criteria

✅ All medium severity issues resolved  
✅ Test coverage >80% for security fixes  
✅ No regression in existing functionality  
✅ TypeScript builds without errors  
✅ Security audit score improved  
✅ Documentation updated  
✅ Team trained on new security measures  

---

## Notes
- All fixes should be implemented on a feature branch
- Each fix should have its own commit for easy rollback
- Deploy to staging first, monitor for 24 hours
- Then deploy to production during low-traffic period
- Keep this document updated with actual findings during implementation

