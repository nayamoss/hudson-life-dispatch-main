# 💰 CHEAPEST OPTIONS FOR RUNNING YOUR SCRAPER 24/7

Research-backed comparison (Perplexity AI, January 2025)

## Quick Answer: Your Best Options

### 🏆 BEST: VPS ($4-6/month)
- **Kamatera**: $4/month
- **DigitalOcean**: $6/month (1GB RAM)
- **IONOS**: $1/month first year

### 💻 FREE: Your Other Computer at Home
- **Cost**: $0 setup + ~$5-10/month electricity
- **Best if**: You have an old Mac/PC that stays on anyway

### ❌ AVOID: Free Cloud Tiers
- Railway, Render, Fly.io free tiers **sleep after inactivity**
- Kills queue workers = broken scraping

---

## Detailed Comparison

### Option 1: VPS (Virtual Private Server) - $4-6/month ⭐

**Providers:**
- **Kamatera**: $4/month (basic)
- **DigitalOcean Droplet**: $6/month (1GB RAM, 1 vCPU, 25GB SSD)
- **IONOS**: $1/month intro pricing
- **InMotion**: $3.59/month

**Pros:**
✅ 99.9%+ uptime SLA  
✅ Persistent - never sleeps  
✅ Full root/SSH access  
✅ Built-in backups  
✅ Scalable (upgrade RAM/CPU anytime)  
✅ Professional setup  
✅ Different IP (won't affect your home network)  

**Cons:**
❌ $4-6/month cost  
❌ Need to set up (install PHP, Postgres, etc.)  

**Setup Time:** 1-2 hours initial setup

**Best For:** Production reliability, professional use

---

### Option 2: Your Other Computer (Mac/PC) - ~$5-10/month electricity ⭐

**Requirements:**
- Old Mac Mini, MacBook Pro, or any PC
- Stays plugged in 24/7
- Stable internet connection

**Actual Costs (2025):**
- **Mac Mini M4**: ~30W average = **$45/year** ($3.75/month)
- **MacBook Pro**: ~40W average = **$60/year** ($5/month)
- **Old PC**: ~50-100W = **$75-150/year** ($6-12/month)

**Pros:**
✅ $0 upfront (you own the hardware)  
✅ Full control  
✅ No monthly bills to cloud providers  
✅ Can access locally for debugging  
✅ Unlimited bandwidth  

**Cons:**
❌ Power/internet outages = downtime  
❌ No automatic backups  
❌ Uses your home IP (could get rate-limited)  
❌ Heat/noise in your home  
❌ Manual maintenance (OS updates, etc.)  
❌ Not 99.9% reliable  

**Setup:** See detailed guide below

**Best For:** Side projects, learning, when you have spare hardware

---

### Option 3: Cheap VPS Under $5 - Various Options

| Provider | Price | RAM | CPU | Storage | Notes |
|----------|-------|-----|-----|---------|-------|
| **Kamatera** | $4/mo | 1GB | 1 vCPU | 20GB | Best value |
| **DigitalOcean** | $6/mo | 1GB | 1 vCPU | 25GB | Most popular |
| **IONOS** | $1/mo | Varies | Shared | 10GB | First year only |
| **Hostinger VPS** | $4.99/mo | 1GB | 1 vCPU | 20GB | Good support |

---

### Option 4: ❌ FREE Cloud Tiers - NOT RECOMMENDED

**Railway, Render, Fly.io Free Tiers:**

**Problems:**
- ❌ Apps **sleep after 5-30 min inactivity**
- ❌ Kills your queue workers
- ❌ Strict RAM limits (512MB)
- ❌ Limited hours/month (500-750 hours)

**Verdict:** Only good for testing, NOT production

---

## Your Actual Needs

For **400-500 scrapes/day** (staggered over 24 hours):
- ~20 scrapes/hour
- ~1 scrape every 3 minutes
- Very low CPU usage
- ~100-200MB RAM needed

**This is TINY workload** - even the cheapest options work!

---

## Recommended Setup: Your Other Computer at Home

### Step-by-Step Setup (macOS)

#### 1. Keep Mac Awake 24/7 (Display Off)
```bash
sudo pmset -a disablesleep 1
sudo pmset -a disablesystemsleep 1
sudo pmset -a displaysleep 10  # Display sleeps after 10 min
sudo pmset -a autopoweroff 0
sudo pmset -a powernap 0
```

Verify:
```bash
pmset -g
```

#### 2. Auto-Start Queue Workers on Boot (using launchd)

Create: `/Library/LaunchDaemons/com.hudsonlife.scraper.plist`

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
        <string>/Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend/artisan</string>
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
    <string>/Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend/storage/logs/queue-daemon.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend/storage/logs/queue-error.log</string>
    <key>WorkingDirectory</key>
    <string>/Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend</string>
</dict>
</plist>
```

Load it:
```bash
sudo launchctl load /Library/LaunchDaemons/com.hudsonlife.scraper.plist
sudo launchctl start com.hudsonlife.scraper
```

Check status:
```bash
sudo launchctl list | grep hudsonlife
```

#### 3. Set Up Laravel Scheduler (cron)

```bash
crontab -e
```

Add this line:
```
* * * * * cd /Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend && /opt/homebrew/bin/php artisan schedule:run >> /tmp/laravel-cron.log 2>&1
```

#### 4. Handle Reboots/Power Failures

✅ **launchd automatically restarts** queue workers on boot  
✅ **KeepAlive** restarts workers if they crash  
✅ **cron** starts on boot automatically  

To test: `sudo reboot`

#### 5. Monitoring

Check if workers are running:
```bash
sudo launchctl list | grep hudsonlife
ps aux | grep "queue:work"
```

Check logs:
```bash
tail -f ~/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend/storage/logs/queue-daemon.log
```

---

## Cost Comparison Summary

| Option | Setup Cost | Monthly Cost | Yearly Cost | Reliability |
|--------|------------|--------------|-------------|-------------|
| **Your Mac at home** | $0 | $3-5 | $36-60 | 95-98% |
| **Kamatera VPS** | $0 | $4 | $48 | 99.9% |
| **DigitalOcean** | $0 | $6 | $72 | 99.9% |
| **Free tier** | $0 | $0 | $0 | 50-70% ❌ |

---

## My Recommendation

### For You:

**Start with your other computer at home** ($3-5/month electricity):
- You already have the hardware
- 400-500 scrapes/day is tiny workload
- Save $48-72/year
- Can always move to VPS later if needed

**Upgrade to VPS ($4-6/month) if:**
- Home internet/power is unreliable
- You need 99.9% uptime
- Getting rate-limited from your home IP
- Want professional setup

---

## Setup Script for Home Mac

Want me to create an automated setup script that:
1. Configures pmset to keep Mac awake
2. Creates launchd daemon for queue workers
3. Sets up cron for Laravel scheduler
4. Tests everything and shows status

Just say "yes" and I'll create it!

---

**Bottom Line:**  
For your 400-500 scrapes/day, **use your other Mac** ($3-5/month). It's plenty reliable for this workload and costs 50% less than a VPS.

