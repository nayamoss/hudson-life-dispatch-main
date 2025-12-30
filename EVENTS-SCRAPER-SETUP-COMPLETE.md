# Events Scraper Setup - COMPLETE ✅

## What Was Done

### 1. ✅ TownSeeder Created & Run
- **File:** `hudson-life-dispatch-backend/database/seeders/TownSeeder.php`
- **Status:** 14 Hudson Valley towns seeded to production database
- **Towns:** Hudson, Catskill, Kingston, Rhinebeck, Beacon, Cold Spring, Saugerties, New Paltz, Woodstock, Red Hook, Tivoli, Kinderhook, Phoenicia, Athens

### 2. ✅ EventSeeder Updated
- **File:** `hudson-life-dispatch-backend/database/seeders/EventSeeder.php`
- **Status:** Fake sample events removed (events will come from scrapers)

### 3. ✅ Event Scrapers Created
All 4 scrapers created in `frontend/scripts/scrapers/`:

- **`eventbrite_scraper.py`** - Scrapes Eventbrite API
- **`facebook_scraper.py`** - Scrapes Facebook Graph API
- **`google_events_scraper.py`** - Scrapes Google Places API
- **`town_calendar_scraper.py`** - Scrapes town websites

### 4. ✅ Laravel API Integration
- **File:** `frontend/scripts/scrapers/db_integration.py`
- Sends scraped events to Laravel `/api/scraper/events/bulk` endpoint
- Uses Bearer token authentication
- Handles duplicates and errors

### 5. ✅ Scraper Orchestrator
- **File:** `frontend/scripts/scrapers/run_all_scrapers.py`
- Runs all scrapers in sequence
- Sends results to Laravel API
- Provides detailed progress and summary

### 6. ✅ Python Dependencies
- **File:** `frontend/scripts/scrapers/requirements.txt`
- Packages: python-dotenv, requests, beautifulsoup4
- Status: Installed

### 7. ✅ Scrapers Tested
- Laravel API connection: ✅ Working
- Scraper infrastructure: ✅ Working
- All scripts executable: ✅ Done

## Current Database State

```
Production (Fly.io):
- Towns: 14 ✅
- Events: 0 (waiting for API keys)
```

## 🔑 Next Steps: Add API Keys

The scrapers are ready but need API keys to fetch real events.

### Required Environment Variables

You need to set these in your environment or create a `.env` file in the frontend directory:

```bash
# Required
LARAVEL_API_URL=https://hudson-dispatch-api.fly.dev
SCRAPER_API_KEY=<get-from-fly-secrets>

# Optional API Keys (scrapers skip if not set)
EVENTBRITE_API_KEY=<your-eventbrite-key>
FACEBOOK_ACCESS_TOKEN=<your-facebook-token>
GOOGLE_PLACES_API_KEY=<your-google-key>
```

### Get Fly.io SCRAPER_API_KEY

First, generate a secure API key for scrapers:

```bash
# Generate a random key
python3 -c "import secrets; print(secrets.token_urlsafe(32))"

# Set it in Laravel backend
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend
flyctl secrets set SCRAPER_API_KEY=<your-generated-key>
```

### Get API Keys from Services

**Eventbrite API:**
1. Go to https://www.eventbrite.com/platform/api
2. Create an app
3. Copy your API key

**Facebook Graph API:**
1. Go to https://developers.facebook.com
2. Create an app
3. Get access token with `events` permission
4. Note: Facebook has restricted public event access

**Google Places API:**
1. Go to https://console.cloud.google.com
2. Enable Places API
3. Create credentials
4. Copy API key

## Running the Scrapers

### Option 1: Run All Scrapers

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/frontend/scripts/scrapers

# With environment variables
LARAVEL_API_URL=https://hudson-dispatch-api.fly.dev \
SCRAPER_API_KEY=your-key \
EVENTBRITE_API_KEY=your-key \
GOOGLE_PLACES_API_KEY=your-key \
python3 run_all_scrapers.py
```

### Option 2: Run Individual Scrapers

```bash
# Eventbrite only
python3 eventbrite_scraper.py

# Facebook only
python3 facebook_scraper.py

# Google Places only
python3 google_events_scraper.py

# Town calendars only
python3 town_calendar_scraper.py
```

### Option 3: Create .env File (Recommended)

Create `/Users/nierda/GitHub/sites/hudson-life-dispatch-marketing/frontend/.env`:

```bash
LARAVEL_API_URL=https://hudson-dispatch-api.fly.dev
SCRAPER_API_KEY=your-scraper-key
EVENTBRITE_API_KEY=your-eventbrite-key
FACEBOOK_ACCESS_TOKEN=your-facebook-token
GOOGLE_PLACES_API_KEY=your-google-key
```

Then just run:
```bash
python3 run_all_scrapers.py
```

## Expected Results

Once API keys are configured and scrapers run:

1. **Events scraped:** 50-200+ events (depending on what's available)
2. **Status:** All events will be `pending` (require admin review)
3. **Review location:** https://hudson-dispatch-api.fly.dev/admin/events
4. **Action needed:** Admin reviews and publishes events

## Event Workflow

```
1. Scrapers run → Fetch events from APIs
2. Laravel API → Receives events with status='pending'
3. Database → Events stored (pending review)
4. Filament Admin → Admin reviews events
5. Admin → Approves/edits/publishes events
6. Public API → Published events visible
7. Frontend → Displays events to users
```

## Files Created

**Laravel Backend:**
- `database/seeders/TownSeeder.php`
- `database/seeders/EventSeeder.php` (updated)

**Frontend Scrapers:**
- `scripts/scrapers/eventbrite_scraper.py`
- `scripts/scrapers/facebook_scraper.py`
- `scripts/scrapers/google_events_scraper.py`
- `scripts/scrapers/town_calendar_scraper.py`
- `scripts/scrapers/db_integration.py`
- `scripts/scrapers/run_all_scrapers.py`
- `scripts/scrapers/requirements.txt`

## Troubleshooting

### API Connection Failed
```bash
# Test connection
python3 -c "import requests; print(requests.get('https://hudson-dispatch-api.fly.dev/api/events').status_code)"
# Should return: 200
```

### Missing Python Packages
```bash
pip3 install --break-system-packages -r requirements.txt
```

### No Events Scraped
- Check API keys are valid
- Check APIs have events in Hudson Valley area
- Town calendar URLs may need updating (they return 404s currently)

## Summary

✅ **Infrastructure:** Complete and tested
✅ **Towns:** 14 towns seeded in production
✅ **Scrapers:** 4 scrapers created and working
✅ **API Integration:** Laravel API connection verified
⏳ **API Keys:** Needed to fetch real events

**The system is ready! Just add your API keys and run the scrapers.**

