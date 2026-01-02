# 🖥️ SETUP GUIDE FOR YOUR OTHER MAC - AUTOMATED SCRAPER

Copy this entire guide to your **OTHER Mac** and follow it step by step.

---

## What This Will Do

Your other Mac will automatically scrape **88 high-value resources** every day:
- 4 RSS feeds (news)
- 19 Event APIs (Eventbrite, Meetup)
- 15 Job APIs
- 9 Pet adoption APIs
- 38 Real estate APIs
- 3 News APIs

**Schedule:** Every 4 hours (6am, 10am, 2pm, 6pm, 10pm) + Daily 2am catch-up  
**Cost:** ~$3-5/month electricity  
**Compute:** Very light (88 scrapes/day)

---

## STEP 1: Get the Code

```bash
# Open Terminal on your OTHER Mac

# Navigate to where you want the project
cd ~/GitHub/sites

# Clone or copy the project (adjust path as needed)
# If you already have it, skip to Step 2

# Install dependencies
cd hudson-life-dispatch-main/hudson-life-dispatch-backend
composer install
```

---

## STEP 2: Configure Database Connection

```bash
# Edit .env file
nano .env
```

Make sure it points to your Postgres database:
```
DB_CONNECTION=pgsql
DB_HOST=your-database-host
DB_PORT=5432
DB_DATABASE=your-database-name
DB_USERNAME=your-username
DB_PASSWORD=your-password
```

Test connection:
```bash
php artisan migrate --pretend
# Should show migrations without errors
```

---

## STEP 3: Keep Mac Awake 24/7 (Display Can Sleep)

```bash
# Prevent system sleep
sudo pmset -a disablesleep 1
sudo pmset -a disablesystemsleep 1

# Allow display to sleep after 10 minutes (saves power)
sudo pmset -a displaysleep 10

# Disable other sleep features
sudo pmset -a autopoweroff 0
sudo pmset -a powernap 0
sudo pmset -a hibernatemode 0

# Verify settings
pmset -g
```

---

## STEP 4: Set Up Queue Worker (Auto-Starts on Boot)

**Create the launchd daemon:**

```bash
sudo nano /Library/LaunchDaemons/com.hudsonlife.scraper.plist
```

**Paste this (UPDATE THE PATHS for your username):**

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

**IMPORTANT:** Replace `YOUR-USERNAME` with your actual Mac username (find it with `whoami`)

**Save and exit:** `Ctrl+X`, then `Y`, then `Enter`

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

You should see a process running!

---

## STEP 5: Set Up Laravel Scheduler (Triggers Scraping)

```bash
# Open cron editor
crontab -e
```

**Add this line (press `i` to insert, UPDATE THE PATH):**

```
* * * * * cd /Users/YOUR-USERNAME/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend && /opt/homebrew/bin/php artisan schedule:run >> /tmp/laravel-cron.log 2>&1
```

**Save and exit:** Press `Esc`, type `:wq`, press `Enter`

**Verify it was added:**

```bash
crontab -l
```

---

## STEP 6: Test Everything

**Test 1: Check if queue worker is alive**

```bash
sudo launchctl list | grep hudsonlife
```

Should show status with a PID number.

**Test 2: Check Laravel schedule**

```bash
cd ~/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend
php artisan schedule:list
```

Should show:
- `scrape:resources --limit=25` every 4 hours
- `scrape:resources --limit=30` daily at 2am
- `resources:rank` weekly on Sunday

**Test 3: Manually trigger a scrape**

```bash
php artisan scrape:resources --limit=5
```

Wait 10 seconds, then check logs:

```bash
tail -20 storage/logs/queue-daemon.log
```

Should see jobs being processed!

---

## STEP 7: Monitor It (Optional)

**Check logs anytime:**

```bash
cd ~/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend

# Scraper activity log
tail -f storage/logs/scraper-phase1.log

# Queue worker log
tail -f storage/logs/queue-daemon.log

# Laravel app log
tail -f storage/logs/laravel.log
```

**Check status:**

```bash
php artisan scrape:status
```

---

## Troubleshooting

### Queue worker not running?

```bash
# Check if it's loaded
sudo launchctl list | grep hudsonlife

# If not, load it
sudo launchctl load /Library/LaunchDaemons/com.hudsonlife.scraper.plist

# If loaded but not running, start it
sudo launchctl start com.hudsonlife.scraper
```

### Scheduler not working?

```bash
# Check if cron is set up
crontab -l

# Check cron log
tail -20 /tmp/laravel-cron.log

# Manually test schedule
php artisan schedule:run
```

### Mac went to sleep?

```bash
# Re-apply pmset settings
sudo pmset -a disablesleep 1
pmset -g
```

---

## What Happens Automatically

Once set up:

**Every 4 hours (6am-10pm):**
1. Laravel scheduler wakes up
2. Checks which resources are due to scrape
3. Dispatches ~15 jobs to queue
4. Queue worker processes them
5. Data gets stored in database

**Daily at 2am:**
- Catch-up scrape for any missed resources

**Weekly (Sunday 1am):**
- Recalculates priority scores

**If queue worker crashes:**
- launchd automatically restarts it (KeepAlive)

**If Mac reboots:**
- Everything auto-starts (RunAtLoad)

---

## To Stop Everything (If Needed)

```bash
# Stop queue worker
sudo launchctl stop com.hudsonlife.scraper

# Disable auto-start
sudo launchctl unload /Library/LaunchDaemons/com.hudsonlife.scraper.plist

# Remove cron
crontab -e
# Delete the laravel-cron line, save and exit
```

---

## Summary

After following these steps, your OTHER Mac will:
- ✅ Stay awake 24/7 (display sleeps)
- ✅ Run queue worker constantly (auto-restart)
- ✅ Scrape 88 resources daily automatically
- ✅ Store events, jobs, pets, news in database
- ✅ Cost ~$3-5/month electricity

**That's it! Let it run and forget about it.** 🎉

Check back in a week to see hundreds of events, jobs, and news articles collected automatically.

