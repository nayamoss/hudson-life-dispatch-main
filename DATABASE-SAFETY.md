# 🚨 DATABASE SAFETY RULES - READ THIS BEFORE ANY MIGRATION

## ⚠️ CRITICAL: NEVER RUN THESE COMMANDS WITHOUT EXPLICIT USER PERMISSION

### ❌ FORBIDDEN COMMANDS:
```bash
php artisan migrate:fresh      # DROPS ALL TABLES
php artisan migrate:refresh     # DROPS ALL TABLES
php artisan migrate:reset       # DROPS ALL TABLES
php artisan db:wipe            # DROPS ALL TABLES
```

### ✅ SAFE COMMANDS:
```bash
php artisan migrate            # Only adds new tables/columns
php artisan db:backup          # Creates backup
php artisan db:restore         # Restores from backup
```

---

## 📦 BACKUP SYSTEM

### Create a Backup (ALWAYS DO THIS FIRST!)
```bash
php artisan db:backup
```

This creates a timestamped backup in `storage/app/backups/` with:
- All table data as JSON
- Metadata file with record counts
- Timestamp and environment info

### List Available Backups
```bash
ls -lh storage/app/backups/
```

### Restore from Backup
```bash
# Restore everything
php artisan db:restore backup-2026-01-02_01-42-08 --force

# Restore specific tables only
php artisan db:restore backup-2026-01-02_01-42-08 --table=events --table=resources --force
```

---

## 🔄 PROPER WORKFLOW FOR SCHEMA CHANGES

### CORRECT Way:
```bash
# 1. ALWAYS BACKUP FIRST
php artisan db:backup

# 2. Create migration
php artisan make:migration add_column_to_table

# 3. Edit migration to ONLY add new columns/tables

# 4. Run migration (safe - doesn't drop anything)
php artisan migrate

# 5. If something goes wrong, restore
php artisan db:restore backup-XXXX --force
```

### ❌ WRONG Way (What Keeps Happening):
```bash
# DON'T DO THIS - WIPES EVERYTHING
php artisan migrate:fresh  # ← This is what keeps fucking us
```

---

## 📋 CURRENT BACKUP

**Latest Backup:** `backup-2026-01-02_01-42-08`
- **Events:** 18 records
- **Resources:** 569 records  
- **Users:** 1 record
- **Total:** 588 records

**Location:** `/Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend/storage/app/backups/backup-2026-01-02_01-42-08/`

---

## 🚀 AUTOMATED BACKUPS

### Option 1: Cron Job (Local Development)
Add to crontab:
```bash
# Backup every hour
0 * * * * cd /Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend && php artisan db:backup
```

### Option 2: Laravel Scheduler (Production)
Add to `app/Console/Kernel.php`:
```php
protected function schedule(Schedule $schedule)
{
    $schedule->command('db:backup')->hourly();
}
```

Then run on server:
```bash
* * * * * cd /path/to/app && php artisan schedule:run >> /dev/null 2>&1
```

### Option 3: Pre-Migration Hook
Add to `composer.json`:
```json
"scripts": {
    "pre-migrate": [
        "@php artisan db:backup"
    ]
}
```

---

## 🔒 PRODUCTION BACKUPS (Fly.io)

### Enable Fly.io Postgres Backups
```bash
flyctl postgres backup enable --app hudson-dispatch-db
```

### Create Manual Backup
```bash
flyctl postgres backup create --app hudson-dispatch-db
```

### List Backups
```bash
flyctl postgres backup list --app hudson-dispatch-db
```

### Download Backup
```bash
flyctl postgres backup download --app hudson-dispatch-db
```

---

## 🆘 EMERGENCY RESTORE

If data is lost:

1. **Check for backups:**
   ```bash
   ls -lh storage/app/backups/
   ```

2. **Find JSON files in storage:**
   ```bash
   find . -name "*events*.json" -o -name "*resources*.json"
   ```

3. **Restore from most recent backup:**
   ```bash
   php artisan db:restore backup-XXXX --force
   ```

4. **Or manually import:**
   ```bash
   php artisan newsletter:import-events all-22-events.json
   ```

---

## 📝 DATA LOSS INCIDENTS (NEVER AGAIN)

### Incident 1: Lost events and jobs
- **Cause:** `migrate:fresh` during scraper setup
- **Solution:** Manually re-imported from JSON

### Incident 2: Lost approved events  
- **Cause:** Switched databases, lost production data
- **Solution:** Connected to correct Postgres instance

### Incident 3: Lost events AGAIN (TODAY)
- **Cause:** `migrate:fresh` while adding resources table
- **Solution:** Restored from `all-22-events.json`

---

## ✅ COMMITMENT

**FROM NOW ON:**
1. ✅ ALWAYS backup before ANY schema change
2. ✅ NEVER use `migrate:fresh` or `migrate:refresh`
3. ✅ ONLY use `migrate` to add new tables/columns
4. ✅ Keep backups in Git (JSON files are small)
5. ✅ Test restore process regularly

---

**REMEMBER: Data is precious. Backups are cheap. Data loss is expensive.**

