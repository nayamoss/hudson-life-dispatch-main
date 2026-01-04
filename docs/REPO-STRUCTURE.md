# Hudson Life Dispatch - Repository Structure

## Repository Purpose

This `-main` repository is for **documentation and planning only**. No code should be stored here.

## Where is the Code?

All code is in the marketing site repository:

```
/Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/
├── frontend/          ← Next.js app (all TypeScript code here)
│   ├── app/          ← Next.js app routes
│   ├── components/   ← React components
│   ├── lib/          ← Database, utils, newsletter generator
│   └── scripts/      ← Automation scripts (scrapers, newsletter, etc.)
└── backend/          ← Laravel API (PHP)
```

## What Goes in This Repo

✅ **ALLOWED:**
- Documentation (.md files)
- Planning documents
- Research notes
- AGENTS.md file
- Folders for organization

❌ **NOT ALLOWED:**
- Code files (.ts, .tsx, .js, .py, etc.)
- package.json
- node_modules
- .github/workflows
- lib/ or scripts/ folders with code

## Running Automation Scripts

All automation scripts run from the frontend repo:

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/frontend

# Scrape content
npm run scrape:events
npm run scrape:businesses
npm run scrape:real-estate
npm run scrape:all

# Generate newsletter
npm run newsletter:generate

# Seed database
npm run seed:towns
```

## Documentation in This Repo

- `AUTOMATION-SETUP.md` - How automation works (points to frontend repo)
- `MARKETING-PLAN.md` - 12-month marketing strategy
- `MARKETING-QUICK-START.md` - 30-day action plan
- `SEO-STRATEGY-HUDSON-LIFE-DISPATCH.md` - SEO implementation
- Other planning documents

## Why This Structure?

1. **Single source of truth** - All code in one place (frontend)
2. **No duplication** - Database schema, utilities shared across app
3. **Easier maintenance** - One package.json, one node_modules
4. **Clear separation** - Planning docs vs working code
5. **No conflicts** - Frontend repo is the authoritative codebase

