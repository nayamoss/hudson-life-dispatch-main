# Update Clerk Usernames

## Issue Detected

Your admin user in Clerk has `username: null`, but our database expects `username: "nayaadmin"`.

## Solution: Update Usernames in Clerk Dashboard

### For Admin User

1. Go to https://dashboard.clerk.com
2. Navigate to **Users**
3. Find user: **kinvergtmwn.l8yhu@simplelogin.com**
4. Click to edit
5. Set **Username:** `nayaadmin`
6. Save

### For Subscriber User

1. Find user: **naya@namoslabs.com**
2. Click to edit
3. Set **Username:** `nayamoss`
4. Save

## Why This Matters

When users sign in via Clerk, the middleware syncs their data to the Laravel database:

```php
'username' => $clerkUser->username ?? strtolower(str_replace(' ', '', $name))
```

- If username is set in Clerk: Uses that value
- If username is null: Generates from name (e.g., "NayaAdmin" → "nayaadmin")

Setting usernames in Clerk ensures consistency across both systems.

## Automatic Sync

After updating usernames in Clerk:

1. User signs in again
2. Middleware fetches updated data from Clerk
3. Database is automatically updated with new username

Or you can trigger webhook to sync immediately (if webhooks are configured).

## Alternative: Update Database to Match

If you prefer, you can update the database usernames to match what's generated:

```bash
cd hudson-life-dispatch-backend
php artisan tinker
```

```php
// Check current usernames
$admin = \App\Models\User::find('user_37acLPftUqMQXvaURj41Y4ALdxz');
echo "Current username: " . $admin->username . PHP_EOL;

// The middleware will auto-generate 'nayaadmin' from 'Naya Admin'
// So they should already match, but you can verify:
$admin->username = 'nayaadmin';
$admin->save();

// For subscriber
$subscriber = \App\Models\User::find('user_37acMrQMIJ8FspRHfKUM5gEgjbZ');
$subscriber->username = 'nayamoss';
$subscriber->save();
```

## Current Data

**Admin (from Clerk):**
- ID: `user_37acLPftUqMQXvaURj41Y4ALdxz`
- Name: "Naya Admin"
- Email: kinvergtmwn.l8yhu@simplelogin.com
- Username: `null` → Will auto-generate to "nayaadmin"

**Admin (in Database):**
- Username: "nayaadmin" (from seeder)

**Result:** They match! ✅

The middleware will automatically set username to "nayaadmin" on next sign-in because:
- Clerk username is `null`
- Falls back to: `strtolower(str_replace(' ', '', 'Naya Admin'))` = "nayaadmin"

## No Action Needed!

Actually, your setup will work fine as-is. The middleware handles null usernames correctly:

1. Clerk has `username: null`
2. Middleware generates: "nayaadmin" from name
3. Matches database: "nayaadmin" ✅

But for consistency, I recommend setting usernames in Clerk Dashboard anyway.

