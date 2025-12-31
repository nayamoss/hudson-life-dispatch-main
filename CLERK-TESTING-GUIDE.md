# Clerk Authentication Testing Guide

## Prerequisites

Before testing, ensure:

1. ✅ Clerk API keys added to `.env` (see `CLERK-ENV-SETUP.md`)
2. ✅ Both servers running:
   - Laravel backend: `http://localhost:8000`
   - Next.js frontend: `http://localhost:3000`

## Start the Servers

```bash
# Terminal 1 - Laravel Backend
cd hudson-life-dispatch-backend
php artisan serve --host=0.0.0.0 --port=8000

# Terminal 2 - Next.js Frontend
cd hudson-life-dispatch-frontend
npm run dev
```

## Test 1: Clerk Authentication (API Level)

### Step 1.1: Sign in with Clerk on Frontend

1. Navigate to `http://localhost:3000`
2. Click "Sign In"
3. Sign in using one of your test accounts:
   - **Subscriber**: naya@namoslabs.com
   - **Admin**: kinvergtmwn.l8yhu@simplelogin.com

### Step 1.2: Get Clerk Session Token

Open browser console and run:

```javascript
const token = await window.Clerk.session.getToken();
console.log('Clerk Token:', token);
```

Copy the token for the next step.

### Step 1.3: Test Clerk Auth Endpoint

Replace `YOUR_TOKEN_HERE` with the token from above:

```bash
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
     http://localhost:8000/api/test/clerk
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Clerk authentication working",
  "user": {
    "id": "user_...",
    "email": "...",
    "name": "...",
    "roles": ["admin"] or ["subscriber"]
  },
  "auth_method": "clerk"
}
```

### Step 1.4: Test Without Token (Should Fail)

```bash
curl http://localhost:8000/api/test/clerk
```

**Expected Response:**
```json
{
  "success": false,
  "error": "Unauthorized - No token provided"
}
```

✅ **Clerk authentication is working if both tests pass!**

## Test 2: Password Authentication (Sanctum)

### Step 2.1: Login with Password

```bash
curl -X POST http://localhost:8000/api/login \
     -H "Content-Type: application/json" \
     -d '{
       "email": "test@example.com",
       "password": "password"
     }'
```

**Expected Response:**
```json
{
  "user": {...},
  "token": "..."
}
```

Save the token from the response.

### Step 2.2: Test Sanctum Auth

Replace `YOUR_SANCTUM_TOKEN` with the token from login:

```bash
curl -H "Authorization: Bearer YOUR_SANCTUM_TOKEN" \
     http://localhost:8000/api/user
```

**Expected Response:**
```json
{
  "id": "...",
  "email": "...",
  "name": "..."
}
```

✅ **Sanctum authentication still works!**

## Test 3: Dual Authentication (Both Work)

The `/test/auth` endpoint accepts BOTH Clerk and Sanctum tokens.

### Test 3.1: With Clerk Token

```bash
curl -H "Authorization: Bearer YOUR_CLERK_TOKEN" \
     http://localhost:8000/api/test/auth
```

**Expected:**
```json
{
  "success": true,
  "message": "Authentication working",
  "user": {...},
  "auth_method": "clerk"
}
```

### Test 3.2: With Sanctum Token

```bash
curl -H "Authorization: Bearer YOUR_SANCTUM_TOKEN" \
     http://localhost:8000/api/test/auth
```

**Expected:**
```json
{
  "success": true,
  "message": "Authentication working",
  "user": {...},
  "auth_method": "sanctum"
}
```

✅ **Dual authentication works if both succeed!**

## Test 4: Admin Access (Clerk)

### Step 4.1: Sign in as Admin

Sign in with the admin account (kinvergtmwn.l8yhu@simplelogin.com) via Clerk.

### Step 4.2: Get Admin Token

```javascript
const adminToken = await window.Clerk.session.getToken();
console.log('Admin Token:', adminToken);
```

### Step 4.3: Test Admin Endpoint

```bash
curl -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
     http://localhost:8000/api/admin/users
```

**Expected:** Admin data returned (not 403 Forbidden)

### Step 4.4: Test Filament Admin Panel

1. Navigate to `http://localhost:8000/admin`
2. Sign in with Clerk (if not already signed in)
3. **Expected:** Full access to Filament admin panel

✅ **Admin access works if you can access admin routes!**

## Test 5: Webhooks (User Sync)

### Step 5.1: Configure Webhook in Clerk Dashboard

1. Go to https://dashboard.clerk.com
2. Select your project
3. Go to "Webhooks"
4. Add endpoint: `http://localhost:8000/api/webhooks/clerk` (or use ngrok for local testing)
5. Select events: `user.created`, `user.updated`, `user.deleted`

### Step 5.2: Create Test User in Clerk

1. In Clerk Dashboard, go to "Users"
2. Click "Create User"
3. Fill in details:
   - Email: testuser@example.com
   - First Name: Test
   - Last Name: User

### Step 5.3: Check Database

```bash
cd hudson-life-dispatch-backend
php artisan tinker
```

```php
$user = \App\Models\User::where('email', 'testuser@example.com')->first();
dd($user);
```

**Expected:** User exists in database with Clerk ID starting with `user_`

### Step 5.4: Update User in Clerk

1. In Clerk Dashboard, edit the test user
2. Change the first name to "Updated"
3. Save

### Step 5.5: Check Database Again

```php
$user = \App\Models\User::where('email', 'testuser@example.com')->first();
echo $user->name; // Should be "Updated User"
```

✅ **Webhooks work if user data syncs automatically!**

## Test 6: Frontend Integration

### Step 6.1: Test Server Component API Call

Create a test page in `app/test-clerk/page.tsx`:

```typescript
import { apiClient } from '@/lib/api/client';

export default async function TestClerkPage() {
  const data = await apiClient('/test/auth');
  
  return (
    <div>
      <h1>Clerk Auth Test</h1>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
```

Visit `http://localhost:3000/test-clerk` while signed in.

**Expected:** User data displayed without errors.

### Step 6.2: Test Client Component API Call

Create a test component:

```typescript
'use client';

import { useAPIClient } from '@/lib/api/client-api';
import { useEffect, useState } from 'react';

export default function TestClientAPI() {
  const { apiCall } = useAPIClient();
  const [data, setData] = useState(null);

  useEffect(() => {
    apiCall('/test/auth').then(setData);
  }, []);

  return (
    <div>
      <h2>Client API Test</h2>
      <pre>{JSON.stringify(data, null, 2)}</pre>
    </div>
  );
}
```

**Expected:** User data loads via client-side API call.

✅ **Frontend integration works if API calls succeed!**

## Troubleshooting

### 401 Unauthorized Error

**Check:**
- Clerk token is being sent in `Authorization: Bearer {token}` header
- Clerk API secret key is correct in `.env`
- User is signed in to Clerk
- Token hasn't expired

**Debug:**
```bash
# Check Laravel logs
tail -f storage/logs/laravel.log
```

### Webhook Not Firing

**Check:**
- Webhook URL is correct (use ngrok for local testing)
- Events are selected in Clerk Dashboard
- Webhook signing secret is in `.env`
- Check Clerk Dashboard webhook logs for errors

**Local Testing with ngrok:**
```bash
ngrok http 8000
# Use the ngrok URL in Clerk webhook configuration
# Example: https://abc123.ngrok.io/api/webhooks/clerk
```

### User Not Syncing

**Check:**
- Webhook is configured correctly
- Check Laravel logs for webhook errors
- Verify user data structure in Clerk matches webhook handler

### Filament Admin Access Denied

**Check:**
- User has `admin` in roles array
- User model `canAccessPanel` method returns true
- Check `$user->roles` in tinker:
  ```php
  $user = \App\Models\User::find('user_...');
  dd($user->roles);
  ```

## Success Criteria

All tests should pass:

- ✅ Clerk authentication works for API requests
- ✅ Password authentication still works (parallel operation)
- ✅ Dual authentication accepts both token types
- ✅ Admin users can access admin routes via Clerk
- ✅ Webhooks sync user data automatically
- ✅ Frontend includes Clerk tokens in API calls
- ✅ Server and client components can make authenticated requests

## Next Steps

Once all tests pass:

1. Configure production Clerk keys
2. Set up production webhooks
3. Update Clerk Dashboard settings
4. Test with real users
5. Monitor logs for any issues

## Support

For issues:
- Check Laravel logs: `storage/logs/laravel.log`
- Check browser console for frontend errors
- Check Clerk Dashboard logs
- Review `CLERK-LARAVEL-INTEGRATION-GUIDE.md` for detailed setup

