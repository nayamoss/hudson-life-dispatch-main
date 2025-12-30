# Modal Database Setup

## Create Laravel Database Secret

You need to create a Modal secret with your Laravel Postgres database URL:

```bash
modal secret create laravel-db DATABASE_URL=postgresql://username:password@host:port/database
```

## Get Your Database URL

From your Fly.io Laravel app:

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend
fly postgres connect -a your-postgres-app-name
```

Or check your `.env` file for `DATABASE_URL`

## Format

```
DATABASE_URL=postgresql://username:password@hostname.fly.dev:5432/database_name
```

## After Creating Secret

Deploy the scraper:

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-frontend/scripts/newsletter
modal deploy hudson_valley_scraper.py
```

## What It Does

The scraper will now:
1. Scrape all 9 towns (Sunday & Wednesday 10am EST)
2. Save events directly to your Laravel PostgreSQL database
3. Keep a backup JSON file in Modal volume
4. Events appear in your Filament admin panel immediately

## Database Schema

Events are saved to the `events` table with:
- `title` - Event title
- `description` - Event description  
- `date` - Event date
- `time` - Event time
- `location` - Location string
- `venue` - Venue name
- `town_id` - Foreign key to towns table
- `source_type` - 'firecrawl'
- `source_url` - Original URL
- `status` - 'pending' (for admin review)

## Viewing Events

Go to your Filament admin panel:
```
https://admin.hudsonlifedispatch.com/events
```

All scraped events will be there with status "pending" for you to review and publish.

