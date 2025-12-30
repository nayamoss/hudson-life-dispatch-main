# Migrate Real Events from Next.js to Laravel

## Problem
The events table was missing in Laravel, so I created it. I also created sample events, but you already have REAL scraped events in your Next.js database!

## Solution
Migrate the real events from Next.js PostgreSQL to Laravel PostgreSQL.

## Steps

### 1. Get Your Next.js Database URL

Find your `DATABASE_URL` from the Next.js frontend environment variables:

```bash
# Check .env.local or wherever you store it
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/frontend
cat .env.local | grep DATABASE_URL
```

It should look like:
```
DATABASE_URL=postgresql://username:password@host:5432/database_name
```

### 2. Run the Migration Script

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend

php scripts/migrate-events-from-nextjs.php "YOUR_NEXTJS_DATABASE_URL_HERE"
```

**Example:**
```bash
php scripts/migrate-events-from-nextjs.php "postgresql://user:pass@localhost:5432/hudson_nextjs"
```

### 3. Verify Migration

```bash
php artisan tinker --execute="echo 'Total events: ' . App\Models\Event::count() . PHP_EOL; echo 'Published: ' . App\Models\Event::where('status', 'published')->count() . PHP_EOL;"
```

### 4. Check in Filament Admin

Visit: `https://admin.hudsonlifedispatch.com/admin/events`

You should now see all your real scraped events!

## What Happened

1. ✅ Created `events` table migration in Laravel
2. ✅ Ran the migration
3. ✅ Created sample events (FAKE - now deleted)
4. ✅ Deleted the fake sample events
5. ✅ Created migration script to copy real events from Next.js DB
6. ⏳ **YOU NEED TO:** Run the migration script with your Next.js DATABASE_URL

## Alternative: Manual Check

If you want to check how many events are in your Next.js database first:

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/frontend

# Using psql
psql "$DATABASE_URL" -c "SELECT COUNT(*) FROM events;"

# See sample events
psql "$DATABASE_URL" -c "SELECT title, status, source_type FROM events LIMIT 10;"
```

## Important Notes

- The migration script will **NOT** duplicate events (checks by ID)
- All event data is preserved exactly as is
- The script shows progress (. = success, E = error)
- Your real events will keep their original IDs, slugs, and data

Once you run the migration, your Laravel Filament admin will show all your real scraped events! 🎉

