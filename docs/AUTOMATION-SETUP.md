# Content Automation Setup

## Overview

Automated pipeline for discovering, reviewing, and publishing content for Hudson Life Dispatch newsletter.

**⚠️ All code is in the frontend repo:** `/Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/frontend`

This file is for documentation only.

## Architecture

```
Scrapers → Database → Admin Review → Newsletter Generator → Email
```

## Components

### 1. Data Collection Scripts

**Location:** `hudson-life-dispatch-marketing/frontend/scripts/scrapers/`

- `business-discovery.ts` - Perplexity API business finder
- `eventbrite-to-db.ts` - Eventbrite events scraper
- `facebook-to-db.ts` - Facebook events scraper
- `real-estate.ts` - Real estate listings scraper
- `scraper-config.ts` - Shared configuration

### 2. Newsletter System

**Location:** `hudson-life-dispatch-marketing/frontend/`
- `lib/newsletter-generator.ts` - Database queries for content
- `scripts/newsletter/generate-weekly.ts` - Newsletter generation script

### 3. Database Schema

**Location:** `hudson-life-dispatch-marketing/frontend/lib/db/`
- `index.ts` - Database connection setup
- `schema.ts` - Table definitions (towns, events, businesses, real_estate_listings)
- `query-optimizer.ts` - Performance monitoring utilities

## Environment Variables

Add to `.env.local` and GitHub Secrets:

```bash
# Database
DATABASE_URL=postgresql://...

# API Keys
PERPLEXITY_API_KEY=pplx-xxxxx
FIRECRAWL_API_KEY=fc-xxxxx
EVENTBRITE_API_KEY=xxxxx
FACEBOOK_ACCESS_TOKEN=xxxxx (optional)
RESEND_API_KEY=re-xxxxx

# Agent API (optional)
AGENT_API_KEY=xxxxx
```

## Manual Commands

**Run from:** `hudson-life-dispatch-marketing/frontend/`

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/frontend

# Scrape content manually
npm run scrape:events         # Eventbrite + Facebook
npm run scrape:businesses     # New businesses via Perplexity
npm run scrape:real-estate    # Real estate listings
npm run scrape:all           # Run all scrapers

# Generate newsletter
npm run newsletter:generate   # Query database and generate content

# Seed initial data
npm run seed:towns           # Add 9 Hudson River towns
```

## Automation Schedule

**Daily (7am EST):**
- Scrape events from Eventbrite
- Scrape events from Facebook (if configured)

**Weekly Monday (8am EST):**
- Discover new businesses via Perplexity API

**Weekly Thursday (10am EST):**
- Generate newsletter preview for review

**Weekly Friday (6am EST):**
- Send newsletter (manual trigger for now)

## Workflow

### Content Discovery
1. Scrapers run manually or via automation
2. Content saved to database with `status='pending'`
3. Admin reviews via marketing site dashboard

### Review Process
1. Admin logs into marketing site dashboard
2. Reviews pending items
3. Approves or rejects content
4. Approved items change to `status='published'` or `status='approved'`

### Newsletter Generation
1. Run `npm run newsletter:generate` to create newsletter
2. Review generated content
3. Send to subscribers via email platform

## Database Tables

- `events` - Events from all sources
- `businesses` - Local businesses
- `real_estate_listings` - Property listings
- `towns` - 9 Hudson River towns

## API Costs

- Perplexity: ~$5/week ($20/month)
- Firecrawl: ~$12/week ($50/month)
- Eventbrite: Free
- Facebook: Free
- Resend: $20/month (after 1K subscribers)

**Total:** ~$90/month

## Success Metrics

After 4 weeks:
- 50+ events/week discovered automatically
- 5-10 new businesses/month
- 20+ real estate listings/week
- <30 min/week admin review time
- Weekly newsletter auto-sends Friday 6am

## Next Steps

1. Add API keys to environment
2. Test scrapers manually
3. Review first batch of content
4. Configure GitHub Actions secrets
5. Enable automation
6. Monitor for 2 weeks
7. Adjust as needed

## Support

See individual script files for detailed documentation and configuration options.

