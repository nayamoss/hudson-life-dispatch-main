# AGENTS.md - Hudson Life Dispatch

## Repository Rules

**⚠️ CRITICAL: This repo is for DOCUMENTATION ONLY**

- NO code files (.ts, .tsx, .js, .py, etc.)
- NO package.json
- NO node_modules
- NO lib/ or scripts/ folders with code
- ONLY .md files and folders for organization

## 🔗 ADMIN URLS (NEVER FORGET THIS!)

**⚠️ NO /admin PATH ON EITHER URL!**

**Production admin:**
```
https://admin.hudsonlifedispatch.com
```

**Development admin:**
```
http://localhost:8000
```

**WRONG:**
- ❌ `https://admin.hudsonlifedispatch.com/admin` (NO /admin path!)
- ❌ `http://localhost:8000/admin` (NO /admin path!)
- ❌ `https://hudsonlifedispatch.com/admin` (wrong domain!)

**RIGHT:**
- ✅ Production: `https://admin.hudsonlifedispatch.com`
- ✅ Development: `http://localhost:8000`

**NO /admin PATH ON EITHER ONE!**

## Where is the Code?

All code is in the frontend repository:

```
/Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/frontend
```

## Running Automation Scripts

**Always run from the frontend directory:**

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/frontend

npm run scrape:events        # Scrape events
npm run scrape:businesses    # Discover businesses
npm run newsletter:generate  # Generate newsletter
npm run seed:towns          # Seed database
```

### Full Script List

```bash
# Individual scrapers
npm run scrape:events         # Eventbrite + Facebook events
npm run scrape:businesses     # Discover new businesses via Perplexity
npm run scrape:real-estate    # Real estate listings
npm run scrape:all           # Run all scrapers at once

# Newsletter
npm run newsletter:generate   # Generate weekly newsletter content

# Database
npm run seed:towns           # Add Hudson River towns to database
```

## Project Structure

```
hudson-life-dispatch-main/              (THIS REPO - DOCS ONLY)
├── AGENTS.md                          (This file)
├── REPO-STRUCTURE.md                  (Structure documentation)
├── AUTOMATION-SETUP.md                (How automation works)
├── MARKETING-PLAN.md                  (Marketing strategy)
└── (other .md files)

hudson-life-dispatch-marketing/         (CODE REPO)
├── frontend/                          (Next.js - ALL CODE HERE)
│   ├── app/                          (Next.js app routes)
│   ├── components/                   (React components)
│   ├── lib/                          (Database, newsletter generator)
│   │   ├── db/                      (Database schema & connection)
│   │   └── newsletter-generator.ts  (Newsletter content generation)
│   └── scripts/                      (Automation scripts)
│       ├── scrapers/                (Content scrapers)
│       ├── newsletter/              (Newsletter scripts)
│       ├── import-coffee-shops.ts
│       └── seed-hudson-river-towns.ts
└── backend/                          (Laravel API - PHP)
```

## Environment Setup

Before running scripts, ensure you have:

```bash
# In frontend/.env.local
DATABASE_URL=postgresql://...
EVENTBRITE_API_KEY=...
PERPLEXITY_API_KEY=...
FACEBOOK_ACCESS_TOKEN=...
RESEND_API_KEY=...
```

## Key Files in Frontend

- `lib/db/schema.ts` - Database tables (towns, events, businesses, real_estate_listings)
- `lib/db/index.ts` - Database connection
- `lib/newsletter-generator.ts` - Newsletter content queries
- `scripts/scrapers/eventbrite-to-db.ts` - Event scraping
- `scripts/scrapers/business-discovery.ts` - Business discovery
- `scripts/newsletter/generate-weekly.ts` - Newsletter generation

## Documentation in This Repo

- `AUTOMATION-SETUP.md` - Detailed automation documentation
- `MARKETING-PLAN.md` - 12-month marketing strategy
- `MARKETING-QUICK-START.md` - 30-day action plan
- `SEO-STRATEGY-HUDSON-LIFE-DISPATCH.md` - SEO implementation
- `REPO-STRUCTURE.md` - Repository organization

## Agent Instructions

When working on Hudson Life Dispatch:

1. **Check which repo you're in**
   - `-main` = documentation only
   - `-marketing/frontend` = all code

2. **For code changes:**
   - Navigate to: `/Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/frontend`
   - Edit code there
   - Never add code to `-main` repo

3. **For documentation:**
   - Edit .md files in `-main` repo
   - Keep references pointing to frontend repo

4. **Running scripts:**
   - Always `cd` to frontend directory first
   - Use npm scripts defined in frontend/package.json

## Quick Commands Reference

```bash
# Switch to code repo
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/frontend

# Check what scripts are available
npm run

# Run full automation pipeline
npm run scrape:all && npm run newsletter:generate

# Test database connection
npm run seed:towns
```

