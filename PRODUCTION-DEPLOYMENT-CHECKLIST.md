# 🚀 Production Deployment Checklist - Hudson Life Dispatch

## Current Status
- **Backend URL**: `https://hudson-dispatch-api.fly.dev`
- **Frontend URL**: TBD (Vercel/Netlify)
- **Admin Panel**: `https://hudson-dispatch-api.fly.dev/` (root path)

---

## ⚠️ CRITICAL ISSUES TO FIX BEFORE DEPLOYMENT

### 1. Missing Clerk API Secret in Production
**Status**: ❌ **BLOCKING**

The backend production environment is **missing** the Clerk API secret, which means:
- Magic link authentication will **FAIL** in production
- Users cannot log in to the admin panel
- The `ClerkAuthController` cannot validate tokens

**Fix Required**:
```bash
cd hudson-life-dispatch-backend
flyctl secrets set CLERK_API_SECRET=sk_test_99wh2uKEepvBSLjioPZxsxttsoLgUlzxX1Tg1yY5p9
flyctl secrets set CLERK_ENDPOINT=https://api.clerk.com/v1
```

⚠️ **IMPORTANT**: The current Clerk secret is a **TEST** key (`sk_test_...`). For production, you need:
1. Go to Clerk Dashboard: https://dashboard.clerk.com
2. Switch to **Production** environment
3. Copy the **Production Secret Key** (starts with `sk_live_...`)
4. Set it in Fly.io:
   ```bash
   flyctl secrets set CLERK_API_SECRET=sk_live_YOUR_PRODUCTION_KEY_HERE
   ```

---

### 2. Clerk Publishable Key in Login View
**Status**: ❌ **BLOCKING**

The Clerk login view has a **hardcoded TEST publishable key**:

**File**: `hudson-life-dispatch-backend/resources/views/filament/pages/auth/clerk-login.blade.php`
**Line 13**: `data-clerk-publishable-key="pk_test_YW11c2luZy1kb3ZlLTMuY2xlcmsuYWNjb3VudHMuZGV2JA"`

**Fix Required**:
1. Add `CLERK_PUBLISHABLE_KEY` to backend `.env`:
   ```env
   CLERK_PUBLISHABLE_KEY=pk_live_YOUR_PRODUCTION_KEY_HERE
   ```

2. Update the Blade view to use the environment variable:
   ```blade
   data-clerk-publishable-key="{{ config('clerk.publishable_key') }}"
   ```

3. Add to `config/clerk.php`:
   ```php
   'publishable_key' => env('CLERK_PUBLISHABLE_KEY', ''),
   ```

4. Set in Fly.io production:
   ```bash
   flyctl secrets set CLERK_PUBLISHABLE_KEY=pk_live_YOUR_PRODUCTION_KEY_HERE
   ```

---

### 3. Admin IP Allowlist
**Status**: ⚠️ **REVIEW NEEDED**

Currently, `ADMIN_ALLOWED_IPS` is set in production. This means:
- Only specific IPs can access the admin panel
- If your IP changes, you'll be locked out (404 error)

**Options**:
- **Option A (Recommended)**: Keep IP allowlist for security, but add your current production IPs
- **Option B**: Remove IP allowlist for easier access (less secure)

**To check current value**:
```bash
flyctl secrets list | grep ADMIN_ALLOWED_IPS
```

**To update** (comma-separated list):
```bash
flyctl secrets set ADMIN_ALLOWED_IPS="1.2.3.4,5.6.7.8"
```

**To remove** (allow all IPs):
```bash
flyctl secrets unset ADMIN_ALLOWED_IPS
```

---

## 📋 Pre-Deployment Checklist

### Backend (Laravel on Fly.io)

- [ ] **Set Clerk Production Keys**
  ```bash
  flyctl secrets set CLERK_API_SECRET=sk_live_...
  flyctl secrets set CLERK_PUBLISHABLE_KEY=pk_live_...
  ```

- [ ] **Update Clerk Login Blade View**
  - [ ] Change hardcoded publishable key to `{{ config('clerk.publishable_key') }}`
  - [ ] Add `publishable_key` to `config/clerk.php`

- [ ] **Verify Database Connection**
  ```bash
  flyctl ssh console
  php artisan migrate:status
  ```

- [ ] **Check Admin User Exists**
  ```bash
  flyctl ssh console
  php artisan tinker
  >>> App\Models\User::where('email', 'kinvergtmwn.l8yhu@simplelogin.com')->first()
  ```

- [ ] **Review IP Allowlist**
  - [ ] Decide if keeping IP restriction
  - [ ] Add your production IPs if keeping

- [ ] **Test API Endpoints**
  ```bash
  curl https://hudson-dispatch-api.fly.dev/api/jobs
  curl https://hudson-dispatch-api.fly.dev/api/companies
  curl https://hudson-dispatch-api.fly.dev/api/events
  ```

- [ ] **Deploy Latest Code**
  ```bash
  cd hudson-life-dispatch-backend
  git push
  flyctl deploy
  ```

---

### Frontend (Next.js - Vercel/Netlify)

- [ ] **Set Environment Variables**
  ```env
  NEXT_PUBLIC_API_URL=https://hudson-dispatch-api.fly.dev
  NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_live_...
  CLERK_SECRET_KEY=sk_live_...
  ```

- [ ] **Update API Base URL**
  - Check all `fetch()` calls use `process.env.NEXT_PUBLIC_API_URL`

- [ ] **Deploy Frontend**
  ```bash
  cd hudson-life-dispatch-frontend
  git push
  # Vercel/Netlify will auto-deploy
  ```

- [ ] **Update Backend CORS**
  - Add production frontend URL to `config/cors.php`:
    ```php
    'allowed_origins' => [
        'https://your-frontend-domain.com',
        'https://hudsonlifedispatch.com',
    ],
    ```

- [ ] **Update Backend FRONTEND_URL Secret**
  ```bash
  flyctl secrets set FRONTEND_URL=https://your-frontend-domain.com
  ```

---

## 🧪 Post-Deployment Testing

### 1. Test Backend API
```bash
# Jobs API
curl https://hudson-dispatch-api.fly.dev/api/jobs | jq .

# Companies API
curl https://hudson-dispatch-api.fly.dev/api/companies | jq .

# Events API
curl https://hudson-dispatch-api.fly.dev/api/events | jq .

# Newsletter Editions API
curl https://hudson-dispatch-api.fly.dev/api/newsletter-editions | jq .
```

### 2. Test Admin Login
1. Go to `https://hudson-dispatch-api.fly.dev/`
2. Enter admin email: `kinvergtmwn.l8yhu@simplelogin.com`
3. Check SimpleLogin inbox for magic link
4. Click magic link
5. **Expected**: Redirect to admin dashboard
6. **If fails**: Check browser console and Laravel logs

### 3. Test Frontend
1. Go to your frontend URL
2. Test job listings page: `/jobs`
3. Test job detail page: `/jobs/[id]`
4. Test job seeker registration: `/job-seeker-register`
5. Test job application flow

### 4. Test Newsletter Editor
1. Log in to admin panel
2. Go to Newsletter Editions
3. Create new edition
4. Verify all sections auto-generate
5. Test "Refresh All Sections" button
6. Test content insertion buttons
7. Test preview modal

---

## 🔧 Quick Fix Commands

### View Production Logs
```bash
cd hudson-life-dispatch-backend
flyctl logs
```

### SSH into Production
```bash
flyctl ssh console
```

### Run Artisan Commands in Production
```bash
flyctl ssh console
php artisan route:list
php artisan migrate:status
php artisan config:clear
php artisan cache:clear
```

### Restart Production App
```bash
flyctl apps restart hudson-dispatch-api
```

---

## 🚨 Rollback Plan

If deployment fails:

1. **Rollback Backend**:
   ```bash
   flyctl releases list
   flyctl releases rollback <previous-version>
   ```

2. **Rollback Frontend**:
   - Vercel: Go to Deployments → Previous deployment → "Promote to Production"
   - Netlify: Go to Deploys → Previous deploy → "Publish deploy"

---

## ✅ Success Criteria

- [ ] Backend API responds with 200 status codes
- [ ] Admin can log in via Clerk magic link
- [ ] Admin dashboard loads without errors
- [ ] Newsletter editor works (create, edit, preview)
- [ ] Frontend displays job listings
- [ ] Job application flow works end-to-end
- [ ] All CORS requests succeed (no CORS errors in browser console)
- [ ] No 404 errors for admin panel
- [ ] No authentication failures

---

## 📞 Support

If you encounter issues:
1. Check Laravel logs: `flyctl logs`
2. Check browser console (F12)
3. Verify all environment variables are set
4. Test API endpoints with `curl`
5. Verify Clerk dashboard shows production keys

---

## 🎯 Next Steps After Successful Deployment

1. Set up custom domain for backend: `admin.hudsonlifedispatch.com`
2. Set up custom domain for frontend: `hudsonlifedispatch.com`
3. Configure SSL certificates (Fly.io and Vercel/Netlify handle this automatically)
4. Set up monitoring and alerts
5. Configure automated backups for database
6. Set up staging environment for testing

