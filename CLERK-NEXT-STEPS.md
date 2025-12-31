# Clerk Authentication - Next Steps

## Quick Action Checklist

### Step 1: Get Your Clerk API Keys ✅

1. Go to https://dashboard.clerk.com
2. Select your project
3. Navigate to **"API Keys"** in the left sidebar
4. Copy your **Secret Key** (starts with `sk_test_` or `sk_live_`)

### Step 2: Add Keys to `.env` File ⏳

Open `hudson-life-dispatch-backend/.env` and add:

```env
CLERK_API_SECRET=sk_test_YOUR_ACTUAL_KEY_HERE
CLERK_ENDPOINT=https://api.clerk.com/v1
CLERK_WEBHOOK_PATH=/webhook/clerk
CLERK_WEBHOOK_VERIFY_TOKEN=true
```

**Replace `sk_test_YOUR_ACTUAL_KEY_HERE` with your actual secret key!**

### Step 3: Configure Webhooks ⏳

1. In Clerk Dashboard, go to **"Webhooks"**
2. Click **"Add Endpoint"**
3. Enter URL: `https://admin.hudsonlifedispatch.com/api/webhooks/clerk`
   - For local testing: Use ngrok and add: `https://YOUR-NGROK-URL.ngrok.io/api/webhooks/clerk`
4. Select these events:
   - ✅ `user.created`
   - ✅ `user.updated`
   - ✅ `user.deleted`
5. Click **"Create"**
6. Copy the **Signing Secret** (starts with `whsec_`)
7. Add to `.env`:
   ```env
   CLERK_WEBHOOK_TOKEN=whsec_YOUR_SIGNING_SECRET_HERE
   ```

### Step 4: Quick Test (5 minutes) ⏳

#### Test 1: Basic Auth Test

```bash
# In terminal, from backend directory:
cd hudson-life-dispatch-backend

# Start the server (if not running)
php artisan serve --host=0.0.0.0 --port=8000
```

#### Test 2: Sign in on Frontend

1. Open `http://localhost:3000`
2. Click "Sign In"
3. Sign in as **admin**: kinvergtmwn.l8yhu@simplelogin.com
4. You should be signed in successfully

#### Test 3: Test API Endpoint

Open browser console (F12) and run:

```javascript
// Get Clerk token
const token = await window.Clerk.session.getToken();
console.log('Token:', token);

// Test API call
fetch('http://localhost:8000/api/test/clerk', {
  headers: { 'Authorization': `Bearer ${token}` }
})
.then(r => r.json())
.then(data => console.log('API Response:', data));
```

**Expected output:**
```json
{
  "success": true,
  "message": "Clerk authentication working",
  "user": { "id": "user_...", "email": "...", ... },
  "auth_method": "clerk"
}
```

✅ **If you see this, Clerk authentication is working!**

### Step 5: Test Admin Access ⏳

1. While signed in as admin, navigate to:
   ```
   http://localhost:8000/admin
   ```

2. You should have full access to the Filament admin panel

✅ **If you can access admin panel, admin auth is working!**

### Step 6: Test Webhook (Optional for Local) ⏳

**For Production:**
Webhooks work automatically once configured in Clerk Dashboard.

**For Local Testing:**

1. Install ngrok: `brew install ngrok`
2. Run ngrok:
   ```bash
   ngrok http 8000
   ```
3. Copy the ngrok URL (e.g., `https://abc123.ngrok.io`)
4. In Clerk Dashboard, update webhook URL to:
   ```
   https://abc123.ngrok.io/api/webhooks/clerk
   ```
5. Create a test user in Clerk Dashboard
6. Check Laravel database - user should be created automatically

### Step 7: Verify Everything Works ⏳

Run through the complete testing guide:

```bash
# Open the testing guide
cat CLERK-TESTING-GUIDE.md
```

Or follow these quick tests:

- ✅ Can sign in via Clerk
- ✅ Can make authenticated API calls
- ✅ Admin users can access /admin
- ✅ Subscriber users cannot access /admin
- ✅ Users created in Clerk appear in database

## Troubleshooting

### Problem: "Unauthorized" Error

**Solution:**
1. Check Clerk keys are in `.env`
2. Restart Laravel server: `php artisan serve`
3. Clear config cache: `php artisan config:clear`

### Problem: User Not Syncing to Database

**Solution:**
1. Check webhook is configured in Clerk Dashboard
2. Check `CLERK_WEBHOOK_TOKEN` in `.env`
3. For local testing, use ngrok
4. Check Laravel logs: `tail -f storage/logs/laravel.log`

### Problem: Admin Access Denied

**Solution:**
Check user has admin role in database:

```bash
cd hudson-life-dispatch-backend
php artisan tinker
```

```php
$user = \App\Models\User::where('email', 'kinvergtmwn.l8yhu@simplelogin.com')->first();
print_r($user->roles);
// Should show: Array ( [0] => admin )

// If not, fix it:
$user->roles = ['admin'];
$user->primary_role = 'admin';
$user->save();
```

## Success! 🎉

Once all steps are complete and tests pass:

- ✅ Clerk authentication is fully integrated
- ✅ Users can sign in without passwords
- ✅ Admin access is protected
- ✅ User data syncs automatically
- ✅ Both Clerk and password auth work in parallel

## Additional Resources

- **Complete Testing Guide:** `CLERK-TESTING-GUIDE.md`
- **Environment Setup:** `CLERK-ENV-SETUP.md`
- **Implementation Summary:** `CLERK-IMPLEMENTATION-SUMMARY.md`
- **Full Documentation:** `hudson-life-dispatch-backend/docs/CLERK-AUTH.md`

## Need Help?

1. Check logs: `storage/logs/laravel.log`
2. Review documentation files
3. Check Clerk Dashboard for errors
4. Test with curl/Postman
5. Verify environment variables

---

**Time to complete:** ~15 minutes  
**Difficulty:** Easy  
**Status:** Ready to go! 🚀

