# ✅ FIXED: SMART FREQUENCY-BASED SCRAPING

## The Problem You Caught:
❌ **Before**: Scraping 100 resources EVERY HOUR = 2,400 scrapes/day  
✅ **Now**: Only scrapes resources that are ACTUALLY DUE based on their frequency

## Your Resource Distribution:
- **355 Daily** (news, jobs) - Scraped once per day
- **363 Weekly** (events, museums) - Scraped once per week  
- **61 Monthly** (government agendas) - Scraped once per month
- **54 Seasonal** (annual events) - Scraped every 3 months

## New Smart Schedule:

### Every 2 Hours (6am-10pm):
```bash
php artisan scrape:resources --limit=50
```
- Only picks resources where `next_scrape_at <= now()`
- Respects each resource's individual frequency
- **Typical scrapes**: 10-30 resources (not 50!)

### Daily at 3am:
```bash
php artisan scrape:resources --limit=30
```
- Catch-up for any missed resources
- Off-peak timing

### Weekly (Sundays 2am):
```bash
php artisan resources:rank
```
- Recalculates priority scores

## Actual Compute Load:

### Scrapes Per Day (Estimated):
- **Daily resources** (355): ~355 scrapes/day
- **Weekly resources** (363): ~52 scrapes/day (363 ÷ 7)
- **Monthly resources** (61): ~2 scrapes/day (61 ÷ 30)
- **Seasonal resources** (54): ~0.6 scrapes/day (54 ÷ 90)

**Total: ~410 scrapes/day** (instead of 2,400!)

### Per-Check Load:
- Every 2 hours = 8 checks/day
- ~410 ÷ 8 = **~51 scrapes per check**
- Staggered over time, so usually 10-30 at once

## How It Works:

```
Every 2 Hours:
  ↓
Scrape Command checks: Which resources have next_scrape_at <= NOW?
  ↓
Results:
  - Daily resource last scraped 25 hours ago? ✅ DUE
  - Weekly resource last scraped 2 days ago? ❌ SKIP (due in 5 days)
  - Monthly resource last scraped 15 days ago? ❌ SKIP (due in 15 days)
  ↓
Only dispatch jobs for resources that are ACTUALLY DUE
  ↓
After successful scrape:
  - Daily: next_scrape_at = now() + 1 day
  - Weekly: next_scrape_at = now() + 7 days
  - Monthly: next_scrape_at = now() + 30 days
  ↓
Smart Adjustments:
  - If no changes for 4 weeks on "weekly" → becomes "monthly" temporarily
  - If frequent changes on "monthly" → becomes "weekly" temporarily
```

## Current Status:

```
Resources due RIGHT NOW: 18
Resources due in 1 hour: 36
Resources due in 6 hours: 125
Resources due in 24 hours: 409
```

## Verification:

Check anytime:
```bash
cd hudson-life-dispatch-backend

# See how many are actually due
php artisan tinker --execute="
  echo 'Due now: ' . Resource::readyToScrape()->count() . \"\n\";
  echo 'Due in 1h: ' . Resource::where('next_scrape_at', '<=', now()->addHour())->count() . \"\n\";
"

# See scrape schedule
php artisan schedule:list

# View status
php artisan scrape:status
```

## Why This is Better:

1. **83% Less Compute** (410 vs 2,400 scrapes/day)
2. **Respects Server Resources** (museums don't update hourly!)
3. **Polite to Websites** (not hammering them unnecessarily)
4. **Adaptive** (adjusts frequency based on actual changes)
5. **Efficient** (skips unchanged content with SHA-256 hashing)

## Cost: Still $0/month 🎉

Just way smarter now!

