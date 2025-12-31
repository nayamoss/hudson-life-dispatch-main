# Clerk Two-Way Sync - Complete Guide

## Quick Start

```bash
cd hudson-life-dispatch-backend

# 1. Run migration
php artisan migrate

# 2. Start queue worker (for retries)
php artisan queue:work

# 3. Done! Go create a user in Filament
```

## What This Does

Admins can create, edit, and delete users in Filament. Changes automatically sync to Clerk.

## What Syncs Where?

### ✅ Syncs to Clerk (Two-Way)
- Name
- Email  
- Username

### ❌ Stays in Laravel Only
- Roles
- Bios
- Social links
- Display name

## Usage

### Create User
1. Filament → Users → Create
2. Fill in name, email, username
3. Save → User created in both Laravel and Clerk
4. Check sync status column (green = good)

### Edit User
1. Edit any field
2. Save → Clerk fields sync to Clerk, Laravel fields stay local
3. Check sync status

### Failed Sync?
1. Look for red "Failed" badge
2. Click Edit → "Retry Clerk Sync" button
3. Or wait for automatic retries (3 attempts)

### Delete User
1. Click Delete → Deleted from both Clerk and Laravel

## Sync Status

- ✅ **Synced** (green) = All good
- ⏳ **Pending** (yellow) = Syncing or queued
- ❌ **Failed** (red) = Needs attention

## Testing

```bash
# Test 1: Create user in Filament → Check Clerk dashboard
# Test 2: Edit name in Filament → Check Clerk dashboard  
# Test 3: Edit roles in Filament → Should NOT appear in Clerk
# Test 4: Edit user in Clerk → Check Filament (webhook sync)
# Test 5: Delete user in Filament → Gone from Clerk
```

## Logs

```bash
tail -f storage/logs/laravel.log | grep Clerk
```

## Files Changed

**New:**
- `app/Services/ClerkService.php`
- `app/Jobs/SyncUserToClerk.php`
- `database/migrations/2025_01_01_000001_add_clerk_sync_fields_to_users_table.php`

**Updated:**
- `app/Filament/Resources/UserResource.php`
- `app/Filament/Resources/UserResource/Pages/CreateUser.php`
- `app/Filament/Resources/UserResource/Pages/EditUser.php`
- `app/Http/Controllers/ClerkWebhookController.php`
- `app/Models/User.php`
- `config/services.php`

## Troubleshooting

**Sync always fails?**
- Check `.env` has valid `CLERK_API_SECRET`
- Check Laravel logs for specific error
- Verify Clerk API status

**Queue not processing?**
```bash
php artisan queue:work
```

**Webhook not working?**
- Clerk webhook URL: `https://admin.hudsonlifedispatch.com/webhook/clerk`
- Verify signing secret matches

## Rollback

```bash
# Remove sync status columns
php artisan migrate:rollback --step=1

# Or comment out hooks in CreateUser/EditUser pages
```

## Architecture

```
Admin Creates User in Filament
    ↓
ClerkService API Call
    ↓
Success? → sync_status = 'synced' ✅
    ↓
Failure? → Queue SyncUserToClerk job ⏳
    ↓
Retry 3 times (1min, 5min, 15min)
    ↓
All failed? → sync_status = 'failed' ❌
```

## That's It!

Manage users in Filament, everything syncs to Clerk automatically.

