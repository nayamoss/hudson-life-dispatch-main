# 🖥️ SETUP GUIDE FOR YOUR OTHER MAC - AUTOMATED SCRAPER

## 📋 What Is This?

**Hudson Life Dispatch** is a local news and community resource aggregator for Hudson Valley, NY. 

This scraper automatically collects data from 88+ sources:
- **Local events**: concerts, festivals, museum exhibitions, library programs (Eventbrite, Meetup, RSS)
- **Job postings**: schools, government, local businesses (API feeds)
- **Pet adoptions**: animal rescues, shelters (Petfinder, RescueGroups)
- **Real estate**: homes, rentals, open houses (MLS feeds, Zillow)
- **Community news**: local papers, town announcements (RSS/Atom feeds)

Instead of manually checking 100+ websites daily, this system does it automatically and stores everything in your Postgres database (hosted on Fly.io) that feeds your Laravel backend and marketing website.

---

## 🎯 What This Guide Does

Sets up your **OTHER Mac** to automatically scrape **88 high-value resources** every day:
- 4 RSS feeds (news)
- 19 Event APIs (Eventbrite, Meetup)
- 15 Job APIs
- 9 Pet adoption APIs
- 38 Real estate APIs
- 3 News APIs

**Schedule:** Every 4 hours (6am, 10am, 2pm, 6pm, 10pm) + Daily 2am catch-up  
**Cost:** ~$3-5/month electricity  
**Compute:** Very light (88 scrapes/day = ~0.5% CPU usage)

---

## ✅ Prerequisites

Before starting, make sure you have on your OTHER Mac:
- [ ] Homebrew installed (`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`)
- [ ] PHP & Composer installed (`brew install php composer`)
- [ ] Fly.io CLI installed (`brew install flyctl`)
- [ ] Logged into Fly.io (`fly auth login`)
- [ ] Git installed (comes with macOS, or `brew install git`)
- [ ] Access to your GitHub repos (SSH key or personal access token)

---

## STEP 1: Clone All Repos (Identical Structure)

Your current Mac has this structure:
```
hudson-life-dispatch-main/
  ├── hudson-life-dispatch-backend/     (Laravel backend - separate repo)
  ├── hudson-life-dispatch-frontend/    (React frontend - separate repo)
  ├── hudson-life-dispatch-marketing/   (Marketing site - separate repo)
  └── (documentation, configs, etc.)
```

Let's recreate this EXACTLY on your other Mac:

```bash
# Open Terminal on your OTHER Mac

# Navigate to where you want the project
mkdir -p ~/GitHub/sites
cd ~/GitHub/sites

# Create the main folder
mkdir hudson-life-dispatch-main
cd hudson-life-dispatch-main

# Clone BACKEND repo
git clone https://github.com/nayamoss/hudson-life-dispatch-backend.git

# Clone FRONTEND repo  
git clone https://github.com/nayamoss/hudson-life-dispatch-frontend.git

# Clone MARKETING repo
git clone https://github.com/nayamoss/hudson-life-dispatch-marketing.git

# Clone MAIN repo content (docs and configs)
git init
git remote add origin https://github.com/nayamoss/hudson-life-dispatch-main.git
git pull origin main
```

**Verify the structure matches:**

```bash
ls -la
# Should see:
# - hudson-life-dispatch-backend/
# - hudson-life-dispatch-frontend/
# - hudson-life-dispatch-marketing/
# - README.md, SETUP-OTHER-MAC.md, etc.
```

---

## STEP 2: Install Backend Dependencies

```bash
# Navigate to backend
cd ~/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend

# Install PHP dependencies via Composer
composer install

# This will take 1-2 minutes
```

---

## STEP 3: Configure Database Connection (Using Fly.io)

Your Postgres database is hosted on Fly.io. Let's connect to it from your local Mac:

```bash
cd ~/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend

# Get your Fly.io database credentials
fly secrets list -a hudson-life-dispatch-backend
```

**Copy the output and create your .env file:**

```bash
# Copy the example .env
cp .env.example .env

# Edit .env
nano .env
```

**Add these values from `fly secrets list` output:**

```env
APP_NAME="Hudson Life Dispatch"
APP_ENV=production
APP_KEY=base64:your-app-key-here
APP_DEBUG=false
APP_URL=https://hudson-life-dispatch-backend.fly.dev

# Database - GET THESE FROM FLY.IO SECRETS
DB_CONNECTION=pgsql
DB_HOST=[copy from fly secrets]
DB_PORT=5432
DB_DATABASE=[copy from fly secrets]
DB_USERNAME=[copy from fly secrets]
DB_PASSWORD=[copy from fly secrets]

# Queue connection (uses database driver)
QUEUE_CONNECTION=database
```

**Save and exit:** `Ctrl+X`, then `Y`, then `Enter`

**Test connection:**

```bash
php artisan migrate --pretend
# Should show migrations without errors

# If successful, run migrations for real:
php artisan migrate
```

---

## STEP 4: Keep Mac Awake 24/7 (Display Can Sleep)

```bash
# Prevent system sleep (but allow display to sleep to save power)
sudo pmset -a disablesleep 1
sudo pmset -a disablesystemsleep 1

# Allow display to sleep after 10 minutes
sudo pmset -a displaysleep 10

# Disable power-saving features that might interfere
sudo pmset -a autopoweroff 0
sudo pmset -a powernap 0
sudo pmset -a hibernatemode 0

# Verify settings
pmset -g
# Should show: sleep 0, disksleep 10, displaysleep 10
```

---

## STEP 5: Set Up Queue Worker (Auto-Starts on Boot)

The queue worker processes scraping jobs in the background.

**Create the launchd daemon:**

```bash
sudo nano /Library/LaunchDaemons/com.hudsonlife.scraper.plist
```

**Paste this XML (IMPORTANT: Replace YOUR-USERNAME with your actual Mac username):**

Run `whoami` first to get your username, then replace it below:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.hudsonlife.scraper</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/php</string>
        <string>/Users/YOUR-USERNAME/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend/artisan</string>
        <string>queue:work</string>
        <string>--queue=scraping</string>
        <string>--tries=3</string>
        <string>--sleep=3</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/YOUR-USERNAME/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend/storage/logs/queue-daemon.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/YOUR-USERNAME/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend/storage/logs/queue-error.log</string>
    <key>WorkingDirectory</key>
    <string>/Users/YOUR-USERNAME/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend</string>
</dict>
</plist>
```

**Save and exit:** `Ctrl+X`, then `Y`, then `Enter`

**Set correct permissions:**

```bash
sudo chmod 644 /Library/LaunchDaemons/com.hudsonlife.scraper.plist
sudo chown root:wheel /Library/LaunchDaemons/com.hudsonlife.scraper.plist
```

**Load and start the queue worker:**

```bash
# Load the daemon
sudo launchctl load /Library/LaunchDaemons/com.hudsonlife.scraper.plist

# Start it
sudo launchctl start com.hudsonlife.scraper

# Verify it's running
sudo launchctl list | grep hudsonlife
ps aux | grep "queue:work"
```

You should see a process running with the command `php artisan queue:work`!

---

## STEP 6: Set Up Laravel Scheduler (Triggers Scraping)

The scheduler checks every minute to see if any scraping jobs need to run.

```bash
# Open cron editor
crontab -e
```

**If this is your first time using crontab, it will ask you to choose an editor. Choose nano (option 1).**

**Press `i` to enter insert mode, then add this line:**

**IMPORTANT: Replace YOUR-USERNAME with your actual Mac username:**

```
* * * * * cd /Users/YOUR-USERNAME/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend && /opt/homebrew/bin/php artisan schedule:run >> /tmp/laravel-cron.log 2>&1
```

**Save and exit:** Press `Esc`, type `:wq`, press `Enter`

**Verify it was added:**

```bash
crontab -l
# Should show your cron job
```

---

## STEP 7: Initialize Scrape Times (One-Time Setup)

This staggers the initial scraping times so not all 88 resources get scraped at once:

```bash
cd ~/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend

# Initialize next_scrape_at for all resources
php artisan scrape:initialize-times

# This spreads out scraping over the next 24 hours
```

---

## STEP 8: Test Everything

**Test 1: Check if queue worker is alive**

```bash
sudo launchctl list | grep hudsonlife
# Should show: com.hudsonlife.scraper with a PID number
```

**Test 2: Check Laravel schedule**

```bash
cd ~/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend
php artisan schedule:list
```

Should show:
- `scrape:resources --limit=25` - Every 4 hours between 6:00-22:00
- `scrape:resources --limit=30` - Daily at 2:00am
- `resources:rank` - Weekly on Sunday at 1:00am

**Test 3: Check scraper status**

```bash
php artisan scrape:status
```

Should show:
- Total resources
- Active resources
- Success/fail counts

**Test 4: Manually trigger a test scrape**

```bash
# Scrape 5 resources to test
php artisan scrape:resources --limit=5

# Wait 30 seconds for queue to process
sleep 30

# Check logs
tail -30 storage/logs/queue-daemon.log
```

Should see:
- Jobs being dispatched
- Resources being scraped
- Success messages

**Test 5: Check cron is working**

```bash
# Wait 1 minute, then check cron log
sleep 60
tail -20 /tmp/laravel-cron.log

# Should see "No scheduled commands are ready to run" every minute
```

---

## STEP 9: Monitor It (Optional but Recommended)

**Check logs anytime:**

```bash
cd ~/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend

# Watch scraper activity in real-time
tail -f storage/logs/laravel.log

# Watch queue worker
tail -f storage/logs/queue-daemon.log

# Check for errors
tail -f storage/logs/queue-error.log
```

**Check status anytime:**

```bash
php artisan scrape:status
```

**View recent scrapes:**

```bash
php artisan tinker
# Then run:
Resource::whereNotNull('last_scraped_at')->orderBy('last_scraped_at', 'desc')->take(10)->get(['name', 'last_scraped_at', 'scrape_success_count']);
```

---

## Troubleshooting

### Queue worker not running?

```bash
# Check if it's loaded
sudo launchctl list | grep hudsonlife

# If nothing shows, load it:
sudo launchctl load /Library/LaunchDaemons/com.hudsonlife.scraper.plist

# If loaded but not running, start it:
sudo launchctl start com.hudsonlife.scraper

# Check logs for errors:
tail -50 ~/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend/storage/logs/queue-error.log
```

### Scheduler not working?

```bash
# Check if cron is set up
crontab -l

# If empty, go back to Step 6

# Check cron log
tail -50 /tmp/laravel-cron.log

# Manually test schedule
cd ~/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend
php artisan schedule:run
```

### Mac went to sleep?

```bash
# Re-apply pmset settings
sudo pmset -a disablesleep 1
sudo pmset -a disablesystemsleep 1
pmset -g
```

### Database connection errors?

```bash
# Test connection
cd ~/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend
php artisan tinker
# Run:
DB::connection()->getPdo();
# Should return connection object

# If it fails, recheck your .env DB_* values against:
fly secrets list -a hudson-life-dispatch-backend
```

### Nothing being scraped?

```bash
# Check if resources are ready to scrape
php artisan tinker
# Run:
Resource::readyToScrape()->count();

# If 0, reinitialize scrape times:
php artisan scrape:initialize-times
```

---

## What Happens Automatically

Once set up, your Mac will run on autopilot:

### Every 4 hours (6am, 10am, 2pm, 6pm, 10pm):
1. Laravel scheduler wakes up
2. Checks which resources need scraping (based on `next_scrape_at`)
3. Dispatches ~15-25 jobs to the queue
4. Queue worker picks up jobs and scrapes them
5. Data gets stored in Fly.io Postgres database
6. Updates `last_scraped_at`, `content_hash`, `next_scrape_at`

### Daily at 2am:
- Catch-up scrape for any missed resources (limit 30)

### Weekly (Sunday 1am):
- Recalculates priority scores for all resources

### If queue worker crashes:
- launchd automatically restarts it (KeepAlive setting)

### If Mac reboots:
- Queue worker auto-starts on boot (RunAtLoad setting)
- Cron resumes automatically

---

## To Stop Everything (If Needed)

```bash
# Stop queue worker
sudo launchctl stop com.hudsonlife.scraper

# Disable auto-start
sudo launchctl unload /Library/LaunchDaemons/com.hudsonlife.scraper.plist

# Remove cron job
crontab -e
# Delete the laravel-cron line, save and exit

# Allow Mac to sleep again
sudo pmset -a disablesleep 0
```

---

## Performance & Cost

**Daily Activity:**
- 88 resources scraped
- ~15-25 per run (every 4 hours)
- ~30 seconds of CPU time per run
- ~1-2 minutes total CPU time per day
- ~0.5% average CPU usage

**Monthly Cost:**
- Electricity: ~$3-5/month (Mac Mini uses ~10-20W)
- Fly.io database: Already paid for
- **Total: $3-5/month**

**Compare to alternatives:**
- DigitalOcean VPS: $6/month
- Kamatera VPS: $4/month
- AWS/GCP: $10-20/month

Your home Mac is the CHEAPEST option! 💰

---

## Summary

After following these steps, your OTHER Mac will:
- ✅ Stay awake 24/7 (display sleeps to save power)
- ✅ Run queue worker constantly with auto-restart
- ✅ Scrape 88 resources automatically every day
- ✅ Store events, jobs, pets, news, real estate in Fly.io database
- ✅ Adapt scraping frequency based on content changes
- ✅ Cost only ~$3-5/month in electricity
- ✅ Auto-recover from crashes and reboots

**That's it! Let it run and forget about it.** 🎉

Check back in a week to see hundreds of events, job listings, pet adoptions, and news articles automatically collected!

---

## Next Steps (After 1 Week)

Once Phase 1 is running smoothly:

1. **Review performance**: `php artisan scrape:status`
2. **Check data quality**: Look at scraped events/jobs in your database
3. **Deploy Phase 2**: Add 296 weekly resources (museums, schools, government)
4. **Deploy Phase 3**: Add 77 monthly resources (annual reports, calendars)
5. **Scale to 500+ total resources**

But for now, just let Phase 1 run and prove itself! 🚀
