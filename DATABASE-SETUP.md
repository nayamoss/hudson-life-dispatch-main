# Database Setup - Events, Jobs, Blog & Newsletter

## Current Status

✅ Schema updated with `events` and `jobs` tables
✅ All pages updated to fetch from database
✅ Seed script created with sample data
⚠️ Migration and seeding need to be run (disk space issue prevented completion)

## What Was Done

1. **Added to schema** (`/frontend/lib/db/schema.ts`):
   - `events` table - stores event information
   - `jobs` table - stores job listings

2. **Updated pages to fetch from database**:
   - `/events/page.tsx` - Lists all published events
   - `/events/[id]/page.tsx` - Event detail page
   - `/jobs/page.tsx` - Lists all published jobs
   - `/jobs/[id]/page.tsx` - Job detail page
   - `/newsletter/page.tsx` - Lists all sent newsletters
   - `/newsletter/[id]/page.tsx` - Newsletter detail page
   - `/blog/page.tsx` - Lists all published blog posts
   - `/blog/[id]/page.tsx` - Blog post detail page (already existed)

3. **Created seed script** (`/frontend/scripts/seed-events-jobs.ts`):
   - Seeds 3 sample events
   - Seeds 3 sample jobs
   - Seeds 3 sample blog posts
   - Seeds 3 sample newsletters

## Next Steps

### 1. Free Up Disk Space

The migration failed due to "no space left on device". You need to free up some disk space:

```bash
# Check disk space
df -h

# Clear npm cache if needed
npm cache clean --force

# Remove unused node_modules
find . -name "node_modules" -type d -prune -print | xargs du -chs
```

### 2. Run Database Migration

Once you have space, run the migration to create the tables:

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/frontend
npm run migrate
```

This will create the `events` and `jobs` tables in your database.

### 3. Seed the Database

Run the seed script to populate the database with sample data:

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/frontend
npx tsx scripts/seed-events-jobs.ts
```

This will add:
- 3 events (Hudson Farmers Market, Winter Art Walk, Live Music at Brewery)
- 3 jobs (Barista, Marketing Manager, Server)
- 3 blog posts (if not already present)
- 3 newsletters (if not already present)

### 4. Verify in Admin Panel

After seeding, check the admin panel to see the data:
- Navigate to `/admin` or your admin dashboard
- You should see events, jobs, blog posts, and newsletters

### 5. Adding Data via Admin Panel

Once the tables exist, you can also add new entries through the admin panel if it has CRUD interfaces for these tables. If not, you may need to create admin pages for managing:
- Events
- Jobs
- Blog Posts
- Newsletters

## Database Schema

### Events Table
- id, title, slug, description, fullDescription
- date, endDate, time, location, venue, address
- category, organizer, website, imageUrl
- status, featured, views, clicks
- townId (FK), sourceType, sourceId, sourceUrl

### Jobs Table  
- id, title, slug, company, description, fullDescription
- location, type, category, salary, schedule
- requirements, benefits, applicationEmail, applicationUrl
- companyDescription, companyWebsite, companyLogo
- status, featured, remote, expiresAt, views, clicks
- townId (FK), businessId (FK), postedBy (FK)

## Troubleshooting

### Migration fails with interactive prompt
If the migration asks about table creation/renaming, select "create table" for new tables.

### Pages show no data
- Check that migration ran successfully
- Check that seed script completed without errors
- Check database connection in `.env.local`

### Cards not clickable
- This should now be fixed - all cards link to detail pages
- Events link to `/events/{id}`
- Jobs link to `/jobs/{id}`
- Newsletters link to `/newsletter/{id}`
- Blog posts link to `/blog/{id}`

