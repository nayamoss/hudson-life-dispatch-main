# Jobs Directory - Quick Start

## ✅ Implementation Complete

The Jobs Directory feature has been fully implemented with all functionality. Here's how to get it running:

## Step 1: Run Database Migration

```bash
cd ossining-edit
npx drizzle-kit push
```

This creates the three new tables:
- `jobs` - Main job listings
- `job_applications` - Application submissions
- `job_categories` - Job categories

## Step 2: Seed Job Categories

```bash
npx tsx scripts/seed-job-categories.ts
```

This adds 10 job categories:
- Technology & IT
- Healthcare & Medical
- Retail & Sales
- Food & Hospitality
- Education & Childcare
- Construction & Trades
- Transportation & Logistics
- Administrative & Office
- Marketing & Creative
- Other / Gigs

## Step 3: Seed Initial 20 Jobs (FREE)

**Important**: Make sure `DATABASE_URL` is set in your environment or `.env.local` file.

```bash
# Set your database URL if not already in .env.local
export DATABASE_URL="your_database_url_here"

# Run the seeding script with Perplexity API
npx tsx scripts/seed-jobs-from-perplexity.ts
```

This will:
- Fetch 20 real job listings from Perplexity API for Hudson Valley/Ossining area
- Insert them as FREE listings (no featured charges)
- Set expiration to 30 days from today
- Include diverse job types across all categories

**Fallback**: If API fails, it automatically uses 8 curated fallback jobs.

## Step 4: Configure Stripe (for Featured Listings)

Add to `.env.local` or Netlify dashboard:

```
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
CRON_SECRET=your_secret_here
NEXT_PUBLIC_APP_URL=https://yourdomain.com
```

### Setup Stripe Webhook

1. Go to Stripe Dashboard → Developers → Webhooks
2. Add endpoint: `https://yourdomain.com/api/jobs-payment/webhook`
3. Select event: `checkout.session.completed`
4. Copy webhook secret to `STRIPE_WEBHOOK_SECRET`

## Step 5: Test the Feature

1. **View jobs**: Visit `/jobs`
2. **Search**: Use the search bar
3. **Browse categories**: Click category cards
4. **View details**: Click any job card
5. **Apply**: Click "Apply Now" on a job
6. **Post a job**: Go to `/jobs/post` (requires sign-in)
7. **Dashboard**: Visit `/dashboard/jobs` to manage your listings

## Features Available

✅ **Job Posting**
- Free basic listings (30 days)
- Featured listings ($50 for 30 days)
- All job types (full-time, part-time, contract, gig, internship)

✅ **Job Search**
- Full-text search
- Category filtering
- Location/remote filtering
- Salary range filtering

✅ **Applications**
- External (email/phone/URL)
- On-site application form
- Resume URL submission
- Application management dashboard

✅ **Analytics**
- View tracking
- Click tracking
- Application counts

✅ **Automated Management**
- 30-day expiration (automatic via cron)
- Stripe payment integration
- Application status tracking

## Cron Job Setup

The system includes automatic job expiration. Set up based on your platform:

### Netlify (Already Configured)
The `netlify.toml` includes the cron configuration. Just set `CRON_SECRET` in dashboard.

### Vercel
Add to `vercel.json`:
```json
{
  "crons": [{
    "path": "/api/jobs/expire",
    "schedule": "0 2 * * *"
  }]
}
```

### Manual
Run daily:
```bash
npx tsx scripts/expire-jobs.ts
```

## First 20 Jobs Policy

The first 20 jobs seeded are **completely FREE**:
- ✅ Listed for 30 days
- ✅ No featured charges
- ✅ All features enabled
- ✅ Great way to launch with content

After the initial 20, new jobs follow normal pricing:
- **Free Basic**: Standard visibility
- **Featured**: $50 for top placement

## URLs to Test

- Homepage: `/jobs`
- Search: `/jobs/search?q=software`
- Category: `/jobs/category/technology-it`
- Job Detail: `/jobs/[slug]`
- Apply: `/jobs/[slug]/apply`
- Post Job: `/jobs/post`
- My Jobs: `/dashboard/jobs`
- Applications: `/dashboard/jobs/[id]/applications`

## Troubleshooting

### "Jobs not showing up"
1. Check database migration ran: `npx drizzle-kit push`
2. Verify categories seeded: `npx tsx scripts/seed-job-categories.ts`
3. Check jobs seeded: `npx tsx scripts/seed-jobs-from-perplexity.ts`
4. Verify `status = 'active'` in database

### "Can't post jobs"
1. Make sure you're signed in (Clerk auth required)
2. Check `/jobs/post` page loads
3. Verify API route works: `/api/jobs-post`

### "Applications not working"
1. Check job has `enableOnSiteApplications = true`
2. Verify `/api/jobs-apply` endpoint works
3. Check database `job_applications` table exists

### "Featured payment failing"
1. Verify Stripe keys are set correctly
2. Check webhook secret is configured
3. Test with Stripe test cards
4. Check webhook endpoint: `/api/jobs-payment/webhook`

## Support

See full documentation: `docs/features/jobs-directory.md`

For implementation details: `JOBS-DIRECTORY-IMPLEMENTATION.md`

