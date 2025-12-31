# Fly.io Cost Optimization - December 31, 2025

## ✅ Actions Taken

### Auto-Stop Enabled on Both Databases

**What was done:**
- Enabled auto-stop on `hudson-dispatch-db` (Machine ID: 8e5e6df76593e8)
- Enabled auto-stop on `ynap-db` (Machine ID: 2865993a027de8)

**What this means:**
- Databases will automatically **stop** when idle (no connections for ~5 minutes)
- Databases will automatically **start** when your app needs them
- **You pay ONLY for the hours the database is running** (not 24/7)

## 💰 Cost Breakdown

### Previous Costs (Running 24/7)
- **Per database:** ~$1.94/month (shared-cpu-1x:256MB) + $0.15/month (1GB storage)
- **Total for 2 databases:** ~$4.18/month or **~$0.139/day**
- **For 3 days:** ~$0.42

### Your Actual Charges
You spent **$2.58 in 3 days**, which breaks down to:
- **$0.86/day** across all apps and services
- This includes databases, app instances, and data transfer
- Your apps (hudson-dispatch-api, hudson-dispatch-frontend) were also running

### Expected Costs After Auto-Stop
- **When idle (most of the time):** $0/hour for compute
- **When active:** ~$0.0027/hour per database
- **Storage (always charged):** $0.15/month per database = $0.30/month total
- **Estimated monthly cost:** $0.30-$2.00 (depending on usage)

## 📊 Your Current Setup

```
App: hudson-dispatch-api
Status: suspended (auto-stop enabled)
Cost: Only when running

App: hudson-dispatch-frontend  
Status: suspended (auto-stop enabled)
Cost: Only when running

Database: hudson-dispatch-db
Region: ewr (Newark)
Size: shared-cpu-1x:256MB
Volume: 1GB
Status: Running with AUTO-STOP enabled ✅

Database: ynap-db
Region: iad (Ashburn)  
Size: shared-cpu-1x:256MB
Volume: 1GB
Status: Running with AUTO-STOP enabled ✅
```

## 🎯 Additional Cost Optimization Recommendations

### 1. Consolidate Databases (Save ~$2/month)
If you're not actively using the YNAP project, you could:
- Stop the `ynap-db` database: `flyctl machine stop 2865993a027de8 -a ynap-db`
- Delete it if not needed: `flyctl postgres destroy ynap-db`
- **Savings:** ~$2/month

### 2. Reduce Volume Sizes (Save $0.15-0.30/month)
Your databases have 1GB volumes but are empty. You could:
- Keep current size (1GB is minimum and very cheap at $0.15/month)
- This is already optimal

### 3. Monitor Actual Usage
Check your dashboard regularly:
- View costs: https://fly.io/dashboard/personal/billing
- Set up billing alerts: https://fly.io/dashboard/personal/billing/alerts
- Monitor which apps are consuming resources

### 4. Development vs Production Strategy
For development/testing:
- Use SQLite locally (free)
- Only start Fly.io databases when deploying/testing production features
- Command to start manually: `flyctl machine start <machine-id> -a <app-name>`
- Command to stop manually: `flyctl machine stop <machine-id> -a <app-name>`

## 🚀 How Auto-Stop Works

**Normal Operation:**
1. User visits your website → App starts → Database starts
2. App connects to database
3. User activity keeps database running
4. When all connections close and ~5 minutes pass → Database stops
5. Next user visit → Database auto-starts again (2-5 second delay)

**Cost Impact:**
- If your site gets 10 visits/day, each lasting 5 minutes
- Database might run 1-2 hours/day instead of 24 hours/day
- **Savings:** ~85-95% on compute costs

## 📝 Commands Reference

### Check database status
```bash
flyctl postgres list
flyctl status -a hudson-dispatch-db
flyctl machine list -a hudson-dispatch-db
```

### Manually control databases
```bash
# Stop database manually
flyctl machine stop 8e5e6df76593e8 -a hudson-dispatch-db

# Start database manually  
flyctl machine start 8e5e6df76593e8 -a hudson-dispatch-db

# Check if auto-stop is working
flyctl machine status 8e5e6df76593e8 -a hudson-dispatch-db
```

### Monitor costs
```bash
# View billing dashboard
flyctl dashboard billing

# List all apps and their status
flyctl apps list
```

### Stop YNAP database if not needed
```bash
flyctl machine stop 2865993a027de8 -a ynap-db
```

## ⚠️ Important Notes

1. **First Connection Delay:** When database is stopped, first connection takes 2-5 seconds to start. This is normal.

2. **Storage Costs Persist:** The 1GB volumes cost $0.15/month each even when stopped. This is minimal.

3. **Your Apps Also Have Auto-Stop:** Both frontend and backend apps are already suspended/auto-stop enabled.

4. **Free Tier Allowance:** Fly.io gives you some free resources monthly:
   - 3 shared-cpu-1x VMs (240 hours/month each)
   - 3GB persistent volume storage
   - 160GB outbound data transfer
   - Your current setup should be mostly covered by free tier when auto-stopped!

## 📈 Expected Monthly Bill Going Forward

**Optimistic Scenario (Low Traffic):**
- Storage: $0.30/month (2 x 1GB volumes)
- Compute: $0.10-0.50/month (databases running ~10-30 hours/month)
- Apps: $0.00-0.20/month (mostly covered by free tier)
- **Total: $0.40-$1.00/month**

**Realistic Scenario (Moderate Traffic):**
- Storage: $0.30/month
- Compute: $0.50-1.50/month (databases running more often)
- Apps: $0.20-0.50/month
- **Total: $1.00-$2.30/month**

**High Traffic Scenario:**
- Storage: $0.30/month
- Compute: $2.00-3.00/month (databases running most of the time)
- Apps: $0.50-1.00/month  
- **Total: $2.80-$4.30/month**

Compare this to your previous 24/7 setup: **$4.18/month minimum**

## ✅ Summary

**What Changed:**
- ✅ Auto-stop enabled on both databases
- ✅ Databases will stop when idle
- ✅ You'll only pay for actual usage hours
- ✅ Estimated savings: 50-90% on database costs

**What You Need to Do:**
- Nothing! It's all automatic
- Consider stopping `ynap-db` if you're not using that project
- Monitor your billing dashboard to see the impact

**Questions or Issues?**
- First connection is slow → Normal, database is starting
- Database won't start → Check `flyctl machine status`
- Still high costs → Check which apps are running with `flyctl apps list`

