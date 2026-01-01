## How to Connect Modal Scraper → Fly.io Database

Your scraper successfully saves events to Modal, but they don't automatically reach your database.

### The Fix (2 options):

#### Option 1: Modal POSTs directly to API (AUTOMATED)

Update your Modal scraper to POST to the new endpoint:

```python
# In hudson_life_dispatch_complete.py
import requests
import os

def send_to_database(events):
    """Send scraped events directly to Fly.io database"""
    api_url = "https://hudson-dispatch-api.fly.dev/api/admin/events/bulk-import"
    api_key = os.environ.get("HUDSON_API_KEY")  # Set this in Modal secrets
    
    response = requests.post(
        api_url,
        json={
            "scraped_at": datetime.now().isoformat(),
            "events_count": len(events),
            "events": events
        },
        headers={"X-API-Key": api_key}
    )
    
    return response.json()

# After scraping:
events = scrape_events()
result = send_to_database(events)
print(f"✅ Imported {result['imported']} events, skipped {result['skipped']} duplicates")
```

#### Option 2: Laravel Cron Job checks Modal (FALLBACK)

If Modal can't POST (firewall/network issues), Laravel can pull from Modal:

```php
// app/Console/Commands/ImportFromModal.php
protected $signature = 'modal:import-events';

public function handle()
{
    // Download from Modal volume via API
    // Parse JSON
    // Import as pending
}
```

### Deploy the Fix

```bash
cd hudson-life-dispatch-backend
fly deploy --remote-only
```

Then set the API key:
```bash
fly secrets set SCRAPER_API_KEY="your-secure-key-here" -a hudson-dispatch-api
```

In Modal, set the secret:
```bash
modal secret create hudson-api-key HUDSON_API_KEY="your-secure-key-here"
```

### Test It

```bash
# Test the endpoint works:
curl -X POST https://hudson-dispatch-api.fly.dev/api/admin/events/bulk-import \
  -H "X-API-Key: your-secure-key-here" \
  -H "Content-Type: application/json" \
  -d '{
    "events_count": 1,
    "events": [{
      "title": "Test Event",
      "date": "2026-01-15",
      "time": "10:00 AM",
      "venue": "Test Venue",
      "description": "Testing the pipeline",
      "source": "test"
    }]
  }'
```

### The Complete Flow (After Fix)

```
1. Modal Scraper runs (Friday 6am)
   ↓
2. Scrapes 20+ events
   ↓
3. **NEW:** POST to /api/admin/events/bulk-import
   ↓
4. Events enter database as "pending"
   ↓
5. You see them in Filament dashboard
   ↓
6. You approve the good ones
   ↓
7. Frontend shows approved events
   ↓
8. Newsletter pulls approved events
```

**No manual steps!** The $7 you spend on scraping automatically flows into your database.

