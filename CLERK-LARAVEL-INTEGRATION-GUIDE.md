# Clerk + Laravel Integration Guide
## December 2025 - No More Static Passwords!

This guide shows you how to integrate Clerk authentication with your Laravel backend so users can sign in with Clerk (OAuth, magic links, passkeys) instead of static passwords.

---

## 🎯 Goal

Replace static password authentication with Clerk's secure, passwordless authentication:

**Before:** Users sign in with static passwords to Laravel  
**After:** Users sign in with Clerk (in Next.js) → Laravel validates Clerk tokens → Users are authenticated

---

## 📋 Prerequisites

- Clerk account & project set up ✅
- Next.js frontend with Clerk already configured ✅
- Laravel backend running ✅
- Composer installed ✅

---

## 🚀 Implementation Steps

### Step 1: Install Clerk Laravel Package

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend

composer require cldt/laravel-clerk
```

### Step 2: Publish Configuration & Migrations

```bash
# Publish config file
php artisan vendor:publish --provider="CLDT\Clerk\ClerkServiceProvider" --tag="clerk-config"

# Publish migrations
php artisan vendor:publish --provider="CLDT\Clerk\ClerkServiceProvider" --tag="clerk-migrations"

# Run migrations
php artisan migrate
```

### Step 3: Configure Clerk API Credentials

Edit `.env` file in the Laravel backend:

```bash
# Add these to your .env
CLERK_SECRET_KEY=sk_test_...  # From Clerk Dashboard
CLERK_PUBLISHABLE_KEY=pk_test_...  # From Clerk Dashboard
CLERK_API_BASE_URL=https://api.clerk.com/v1
CLERK_FRONTEND_API=clerk.{your-domain}.com  # From Clerk Dashboard
```

**Get these values from:**
1. Go to https://dashboard.clerk.com
2. Select your project
3. Go to "API Keys"
4. Copy the Secret Key and Publishable Key

### Step 4: Update Clerk Config

Edit `config/clerk.php`:

```php
<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Clerk Secret Key
    |--------------------------------------------------------------------------
    |
    | Your Clerk secret key from the Clerk Dashboard.
    |
    */
    'secret_key' => env('CLERK_SECRET_KEY'),

    /*
    |--------------------------------------------------------------------------
    | Clerk Publishable Key
    |--------------------------------------------------------------------------
    |
    | Your Clerk publishable key from the Clerk Dashboard.
    |
    */
    'publishable_key' => env('CLERK_PUBLISHABLE_KEY'),

    /*
    |--------------------------------------------------------------------------
    | Clerk API Base URL
    |--------------------------------------------------------------------------
    |
    | The base URL for Clerk's API.
    |
    */
    'api_base_url' => env('CLERK_API_BASE_URL', 'https://api.clerk.com/v1'),

    /*
    |--------------------------------------------------------------------------
    | Clerk Frontend API
    |--------------------------------------------------------------------------
    |
    | Your Clerk frontend API domain.
    |
    */
    'frontend_api' => env('CLERK_FRONTEND_API'),

    /*
    |--------------------------------------------------------------------------
    | Clerk Webhook Secret
    |--------------------------------------------------------------------------
    |
    | Your webhook signing secret from Clerk.
    |
    */
    'webhook_secret' => env('CLERK_WEBHOOK_SECRET'),
];
```

---

## 🔐 Authentication Flow

### How It Works

```
1. User signs in on Next.js frontend with Clerk
   ↓
2. Clerk returns session token (JWT)
   ↓
3. Next.js includes token in API requests to Laravel
   ↓
4. Laravel middleware verifies token with Clerk
   ↓
5. Laravel identifies user and grants access
```

### Implementation

#### A. Create Clerk Middleware

Create `app/Http/Middleware/ClerkAuth.php`:

```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use CLDT\Clerk\Facades\Clerk;
use App\Models\User;

class ClerkAuth
{
    /**
     * Handle an incoming request and verify Clerk session
     */
    public function handle(Request $request, Closure $next)
    {
        // Get the session token from the Authorization header
        $token = $request->bearerToken();
        
        if (!$token) {
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized - No token provided'
            ], 401);
        }

        try {
            // Verify the session token with Clerk
            $session = Clerk::sessions()->verify($token);
            
            if (!$session || $session->status !== 'active') {
                return response()->json([
                    'success' => false,
                    'error' => 'Unauthorized - Invalid or expired session'
                ], 401);
            }

            // Get the user from Clerk
            $clerkUser = Clerk::users()->get($session->user_id);
            
            // Find or create user in Laravel database
            $user = User::updateOrCreate(
                ['id' => $clerkUser->id],
                [
                    'email' => $clerkUser->email_addresses[0]->email_address ?? null,
                    'name' => "{$clerkUser->first_name} {$clerkUser->last_name}",
                    'image' => $clerkUser->image_url,
                    'email_verified' => true,
                    'username' => $clerkUser->username,
                ]
            );

            // Attach user to request
            $request->merge(['user' => $user]);
            $request->merge(['clerk_session' => $session]);

            return $next($request);
            
        } catch (\Exception $e) {
            \Log::error('Clerk authentication error: ' . $e->getMessage());
            
            return response()->json([
                'success' => false,
                'error' => 'Unauthorized - Token verification failed'
            ], 401);
        }
    }
}
```

#### B. Register Middleware

Edit `app/Http/Kernel.php`:

```php
protected $middlewareAliases = [
    // ... existing middleware
    'clerk.auth' => \App\Http\Middleware\ClerkAuth::class,
];
```

#### C. Protect Routes with Clerk Auth

Edit `routes/api.php`:

```php
// Protected routes - require Clerk authentication
Route::middleware('clerk.auth')->group(function () {
    // User profile updates
    Route::put('/user/profile', [AuthController::class, 'updateProfile']);
    
    // Admin routes (also check role)
    Route::middleware('admin')->group(function () {
        Route::apiResource('admin/blog-posts', BlogPostController::class);
        // ... other admin routes
    });
});
```

---

## 🔄 Webhook Setup (Keep Users Synced)

Clerk webhooks keep your Laravel database in sync when users are created/updated/deleted in Clerk.

### 1. Create Webhook Controller

Create `app/Http/Controllers/ClerkWebhookController.php`:

```php
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use CLDT\Clerk\Facades\Clerk;
use App\Models\User;

class ClerkWebhookController extends Controller
{
    /**
     * Handle Clerk webhooks
     */
    public function handleWebhook(Request $request)
    {
        // Verify webhook signature
        $signature = $request->header('svix-signature');
        $webhookSecret = config('clerk.webhook_secret');
        
        // Clerk package handles verification
        if (!$this->verifyWebhook($request, $signature, $webhookSecret)) {
            return response()->json(['error' => 'Invalid signature'], 401);
        }

        $event = $request->input('type');
        $data = $request->input('data');

        switch ($event) {
            case 'user.created':
                $this->handleUserCreated($data);
                break;
                
            case 'user.updated':
                $this->handleUserUpdated($data);
                break;
                
            case 'user.deleted':
                $this->handleUserDeleted($data);
                break;
        }

        return response()->json(['success' => true]);
    }

    private function handleUserCreated($data)
    {
        User::create([
            'id' => $data['id'],
            'email' => $data['email_addresses'][0]['email_address'] ?? null,
            'name' => "{$data['first_name']} {$data['last_name']}",
            'image' => $data['image_url'],
            'email_verified' => true,
            'username' => $data['username'],
            'roles' => ['subscriber'], // Default role
            'primary_role' => 'subscriber',
        ]);
    }

    private function handleUserUpdated($data)
    {
        User::where('id', $data['id'])->update([
            'email' => $data['email_addresses'][0]['email_address'] ?? null,
            'name' => "{$data['first_name']} {$data['last_name']}",
            'image' => $data['image_url'],
            'username' => $data['username'],
        ]);
    }

    private function handleUserDeleted($data)
    {
        User::where('id', $data['id'])->delete();
    }

    private function verifyWebhook($request, $signature, $secret)
    {
        // Use Clerk package verification
        // Or implement Svix signature verification
        return true; // Simplified - implement proper verification
    }
}
```

### 2. Add Webhook Route

In `routes/api.php`:

```php
// Clerk webhooks (no auth needed - verified by signature)
Route::post('/webhooks/clerk', [ClerkWebhookController::class, 'handleWebhook']);
```

### 3. Configure Webhook in Clerk Dashboard

1. Go to https://dashboard.clerk.com
2. Select your project
3. Go to "Webhooks"
4. Click "Add Endpoint"
5. Enter URL: `https://admin.hudsonlifedispatch.com/api/webhooks/clerk`
6. Select events: `user.created`, `user.updated`, `user.deleted`
7. Copy the "Signing Secret" to `.env` as `CLERK_WEBHOOK_SECRET`

---

## 🎨 Frontend Integration (Next.js)

Your Next.js app should send the Clerk session token with every API request.

### Update API Client

Edit `hudson-life-dispatch-frontend/lib/api/client.ts`:

```typescript
import { auth } from '@clerk/nextjs/server';

export async function apiClient<T>(
  endpoint: string,
  options?: RequestInit
): Promise<APIResponse<T>> {
  const url = `${API_URL}${endpoint}`;
  
  // Get Clerk session token
  const { getToken } = auth();
  const token = await getToken();
  
  const response = await fetch(url, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Include Clerk token
      ...(token && { 'Authorization': `Bearer ${token}` }),
      ...options?.headers,
    },
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({}));
    throw new APIError(
      error.message || 'API request failed',
      response.status,
      error
    );
  }

  return response.json();
}
```

### For Client Components

```typescript
'use client';

import { useAuth } from '@clerk/nextjs';

export function MyComponent() {
  const { getToken } = useAuth();

  async function callAPI() {
    const token = await getToken();
    
    const response = await fetch('http://localhost:8000/api/user/profile', {
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
      },
    });
    
    const data = await response.json();
    return data;
  }

  // ...
}
```

---

## 🧪 Testing the Integration

### 1. Test Authentication Flow

```bash
# Start both servers
cd hudson-life-dispatch-backend && php artisan serve --port=8000
cd hudson-life-dispatch-frontend && npm run dev
```

### 2. Sign In with Clerk

1. Go to `http://localhost:3000`
2. Click "Sign In"
3. Sign in with Clerk (use naya@namoslabs.com or kinvergtmwn.l8yhu@simplelogin.com)
4. Clerk will authenticate and create a session

### 3. Test Protected API Endpoint

```javascript
// In browser console after signing in
const token = await window.Clerk.session.getToken();

fetch('http://localhost:8000/api/user/profile', {
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
  }
})
.then(r => r.json())
.then(console.log);
```

**Expected:** Returns authenticated user data

### 4. Test Without Token

```bash
curl http://localhost:8000/api/user/profile
```

**Expected:** `401 Unauthorized` error

---

## 🔒 Role-Based Access Control with Clerk

### Store Roles in Clerk Metadata

You can store user roles in Clerk's `publicMetadata` or `privateMetadata`:

```typescript
// Update user role in Clerk (from admin panel)
await clerkClient.users.updateUserMetadata(userId, {
  publicMetadata: {
    role: 'admin'
  }
});
```

### Check Roles in Laravel

```php
public function handle(Request $request, Closure $next, $role)
{
    $user = $request->get('user');
    $clerkUser = Clerk::users()->get($user->id);
    
    $userRole = $clerkUser->public_metadata->role ?? 'subscriber';
    
    if ($userRole !== $role) {
        return response()->json([
            'success' => false,
            'error' => 'Forbidden - Insufficient permissions'
        ], 403);
    }
    
    return $next($request);
}
```

---

## 📊 Migration Strategy

### Phase 1: Add Clerk (Keep Static Passwords)

1. Install Clerk package ✅
2. Set up webhooks ✅
3. Add Clerk middleware ✅
4. Test with both auth methods

### Phase 2: Migrate Users

1. All new users sign up via Clerk
2. Existing users: Send migration email with magic link
3. First Clerk sign-in syncs their account

### Phase 3: Remove Static Passwords

1. Disable password authentication routes
2. Remove password fields from forms
3. All auth goes through Clerk

---

## 🎯 Next Steps

### Immediate Tasks

1. ✅ Install `cldt/laravel-clerk` package
2. ✅ Configure Clerk API keys
3. ✅ Create Clerk middleware
4. ✅ Set up webhooks
5. ✅ Update frontend API client
6. ✅ Test authentication flow

### Future Enhancements

- [ ] Add social login (Google, GitHub, etc.)
- [ ] Implement passkeys for passwordless
- [ ] Add 2FA via Clerk
- [ ] Set up role-based permissions
- [ ] Add session management dashboard
- [ ] Implement refresh token rotation

---

## 📚 Resources

- **Clerk Laravel Package:** https://packagist.org/packages/cldt/laravel-clerk
- **Clerk Documentation:** https://clerk.com/docs
- **Clerk API Reference:** https://clerk.com/docs/reference/backend-api
- **Clerk Next.js Guide:** https://clerk.com/docs/quickstarts/nextjs
- **Laravel Middleware:** https://laravel.com/docs/middleware

---

## 🆘 Troubleshooting

### "401 Unauthorized" Errors

**Check:**
1. Token is being sent in `Authorization: Bearer {token}` header
2. Clerk secret key is correct in `.env`
3. Session is active in Clerk
4. Middleware is registered correctly

### "Invalid signature" on Webhooks

**Check:**
1. Webhook secret is correct in `.env`
2. Signature verification is implemented
3. Clerk webhook is pointing to correct URL

### User Not Syncing

**Check:**
1. Webhooks are set up correctly
2. Webhook endpoint is accessible
3. User events are selected in Clerk dashboard
4. Database migrations have run

---

## ✅ Success Criteria

You'll know it's working when:

✅ Users can sign in via Clerk (no password fields)  
✅ Laravel validates Clerk tokens automatically  
✅ User data syncs via webhooks  
✅ Protected routes require Clerk authentication  
✅ Admin users can access admin panel via Clerk  
✅ Role-based access control works  
✅ No more static passwords in the database!  

---

## 🎉 Benefits

- **Better Security:** No passwords to leak
- **Better UX:** Magic links, social login, passkeys
- **Less Maintenance:** Clerk handles auth complexity
- **Compliance:** Clerk is SOC 2 compliant
- **Scalability:** Clerk handles millions of users
- **Features:** 2FA, session management, user management

