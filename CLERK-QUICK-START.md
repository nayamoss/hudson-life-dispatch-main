# Clerk + Laravel Quick Start
## Get Clerk Authentication Working in 10 Minutes

This is the **TL;DR** version. For full details, see `CLERK-LARAVEL-INTEGRATION-GUIDE.md`.

---

## 🚀 Quick Setup Commands

### 1. Install Clerk Package (2 min)

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend

# Install package
composer require cldt/laravel-clerk

# Publish config and migrations
php artisan vendor:publish --provider="CLDT\Clerk\ClerkServiceProvider" --tag="clerk-config"
php artisan vendor:publish --provider="CLDT\Clerk\ClerkServiceProvider" --tag="clerk-migrations"

# Run migrations
php artisan migrate
```

### 2. Add Environment Variables (1 min)

Add to `hudson-life-dispatch-backend/.env`:

```bash
CLERK_SECRET_KEY=sk_test_YOUR_KEY_HERE
CLERK_PUBLISHABLE_KEY=pk_test_YOUR_KEY_HERE
CLERK_API_BASE_URL=https://api.clerk.com/v1
CLERK_FRONTEND_API=clerk.YOUR_DOMAIN.com
CLERK_WEBHOOK_SECRET=whsec_YOUR_SECRET_HERE
```

**Get these from:** https://dashboard.clerk.com → API Keys

### 3. Create Middleware (2 min)

```bash
php artisan make:middleware ClerkAuth
```

Copy this code to `app/Http/Middleware/ClerkAuth.php`:

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use CLDT\Clerk\Facades\Clerk;
use App\Models\User;

class ClerkAuth
{
    public function handle(Request $request, Closure $next)
    {
        $token = $request->bearerToken();
        
        if (!$token) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }

        try {
            $session = Clerk::sessions()->verify($token);
            
            if (!$session || $session->status !== 'active') {
                return response()->json(['error' => 'Invalid session'], 401);
            }

            $clerkUser = Clerk::users()->get($session->user_id);
            
            $user = User::updateOrCreate(
                ['id' => $clerkUser->id],
                [
                    'email' => $clerkUser->email_addresses[0]->email_address ?? null,
                    'name' => "{$clerkUser->first_name} {$clerkUser->last_name}",
                    'image' => $clerkUser->image_url,
                    'email_verified' => true,
                    'username' => $clerkUser->username ?? strtolower(str_replace(' ', '', $clerkUser->first_name . $clerkUser->last_name)),
                ]
            );

            $request->merge(['user' => $user]);
            return $next($request);
            
        } catch (\Exception $e) {
            \Log::error('Clerk auth error: ' . $e->getMessage());
            return response()->json(['error' => 'Auth failed'], 401);
        }
    }
}
```

### 4. Register Middleware (1 min)

Edit `app/Http/Kernel.php`:

```php
protected $middlewareAliases = [
    // ... existing middleware ...
    'clerk.auth' => \App\Http\Middleware\ClerkAuth::class,
];
```

### 5. Protect Routes (1 min)

In `routes/api.php`, add:

```php
// Test endpoint
Route::middleware('clerk.auth')->get('/test-auth', function (Request $request) {
    return response()->json([
        'success' => true,
        'message' => 'Authenticated!',
        'user' => $request->user
    ]);
});
```

### 6. Update Frontend API Client (2 min)

Edit `hudson-life-dispatch-frontend/lib/api/client.ts`:

Add this at the top:
```typescript
import { auth } from '@clerk/nextjs/server';
```

Update the `apiClient` function:
```typescript
export async function apiClient<T>(
  endpoint: string,
  options?: RequestInit
): Promise<APIResponse<T>> {
  const url = `${API_URL}${endpoint}`;
  
  // Get Clerk token
  const { getToken } = auth();
  const token = await getToken();
  
  const response = await fetch(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...(token && { 'Authorization': `Bearer ${token}` }),
      ...options?.headers,
    },
  });

  // ... rest of the function
}
```

### 7. Test It! (1 min)

```bash
# In one terminal - Laravel
cd hudson-life-dispatch-backend
php artisan serve --port=8000

# In another terminal - Next.js
cd hudson-life-dispatch-frontend
npm run dev
```

Then:
1. Go to `http://localhost:3000`
2. Sign in with Clerk
3. Open browser console and run:

```javascript
const token = await window.Clerk.session.getToken();
const response = await fetch('http://localhost:8000/api/test-auth', {
  headers: { 'Authorization': `Bearer ${token}` }
});
const data = await response.json();
console.log(data);
```

**Expected:**
```json
{
  "success": true,
  "message": "Authenticated!",
  "user": {
    "id": "user_...",
    "email": "...",
    "name": "..."
  }
}
```

---

## ✅ Done!

Clerk authentication is now working! 

**Next steps:**
1. Set up webhooks (see full guide)
2. Protect your existing routes
3. Remove static password authentication

See `CLERK-LARAVEL-INTEGRATION-GUIDE.md` for complete details on:
- Webhook setup
- Role-based access control
- Migration strategy
- Troubleshooting

---

## 🆘 Common Issues

### "Package not found"
```bash
# Make sure you're in the backend directory
cd hudson-life-dispatch-backend
composer require cldt/laravel-clerk
```

### "401 Unauthorized"
- Check Clerk keys in `.env`
- Make sure token is being sent
- Verify session is active in Clerk dashboard

### "Class not found"
```bash
# Clear cache
php artisan config:clear
php artisan cache:clear
composer dump-autoload
```

### Frontend token is null
- Make sure user is signed in
- Check Clerk configuration in Next.js
- Verify `@clerk/nextjs` is installed

---

## 📝 Checklist

- [ ] Install `cldt/laravel-clerk`
- [ ] Add Clerk keys to `.env`
- [ ] Create `ClerkAuth` middleware
- [ ] Register middleware in `Kernel.php`
- [ ] Add test route with `clerk.auth` middleware
- [ ] Update frontend API client to send token
- [ ] Test authentication works
- [ ] Set up webhooks (optional but recommended)

---

**Time estimate:** 10 minutes if you have Clerk keys ready!

