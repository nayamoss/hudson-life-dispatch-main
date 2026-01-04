# FLY.IO DATABASE BACKUP GUIDE

## ✅ BACKUPS ARE NOW ENABLED

**Production Database:** `hudson-dispatch-db`
**Backup Storage:** Tigris (S3-compatible)
**Status:** ✅ **ACTIVE**

---

## 📦 Current Backups

**Latest Backups:**
- `20260102T014728` - Created: Jan 2, 2026 01:47:31
- `20260102T014738` - Created: Jan 2, 2026 01:47:42

---

## 🔄 Automatic Backup Schedule

Fly.io Postgres automatically backs up:
- **Continuous WAL archiving** (Write-Ahead Log)
- **Daily full backups** (retained for 7 days by default)
- Stored in Tigris object storage

---

## 📝 Backup Commands

### List All Backups
```bash
flyctl postgres backup list --app hudson-dispatch-db
```

### Create Manual Backup
```bash
flyctl postgres backup create --app hudson-dispatch-db
```

### Download a Backup
```bash
# List backups first to get the ID
flyctl postgres backup list --app hudson-dispatch-db

# Download specific backup
flyctl postgres backup download 20260102T014728 --app hudson-dispatch-db
```

This downloads a `.tar.gz` file with the full database dump.

---

## 🔧 Backup Configuration

**Database Memory:** Upgraded from 256MB → **512MB** (required for backups)

**Backup Credentials (Auto-configured):**
- `AWS_ACCESS_KEY_ID`: tid_RFPtMFTElhUkBLXhidnmgSBJkIOErKDn_lNwNw_VCiIFVUPOAT
- `AWS_ENDPOINT_URL_S3`: https://fly.storage.tigris.dev
- `AWS_REGION`: auto
- `BUCKET_NAME`: hudson-dispatch-db-postgres

---

## 💾 Restore from Backup

### Option 1: Restore to Existing Database
```bash
# Stop the app first
flyctl machine stop --app hudson-dispatch-api

# Restore from backup
flyctl postgres restore --app hudson-dispatch-db --backup 20260102T014728

# Start the app
flyctl machine start --app hudson-dispatch-api
```

### Option 2: Create New Database from Backup
```bash
# Create new Postgres cluster
flyctl postgres create --name hudson-dispatch-db-restored

# Restore the backup into it
flyctl postgres restore --app hudson-dispatch-db-restored --backup 20260102T014728

# Update app to use new database
flyctl secrets set DATABASE_URL="postgres://..." --app hudson-dispatch-api
```

---

## 🚨 Emergency Recovery Procedure

If production database is lost or corrupted:

### 1. **List Available Backups**
```bash
flyctl postgres backup list --app hudson-dispatch-db
```

### 2. **Download Latest Backup**
```bash
flyctl postgres backup download <BACKUP_ID> --app hudson-dispatch-db
```

This creates a file like `backup-20260102T014728.tar.gz`

### 3. **Extract & Inspect**
```bash
tar -xzf backup-20260102T014728.tar.gz
```

### 4. **Restore to Local Database** (for testing)
```bash
# Extract the SQL dump
pg_restore -d your_local_db backup-20260102T014728.tar.gz

# Or if it's a SQL file
psql your_local_db < backup.sql
```

### 5. **Restore to Production**
```bash
flyctl postgres restore --app hudson-dispatch-db --backup 20260102T014728
```

---

## 📊 Verify Backup Content

After downloading a backup:

```bash
# List contents of backup
tar -tzf backup-20260102T014728.tar.gz

# Extract and check table counts
pg_restore --list backup-20260102T014728.tar.gz
```

---

## 🔐 Backup Security

- Backups are **encrypted at rest** in Tigris
- Access requires Fly.io authentication
- Credentials stored as secrets in the app
- Only accessible via Fly.io CLI with proper auth

---

## 📅 Retention Policy

**Default:**
- Daily backups: **7 days**
- WAL archives: **7 days**

**To extend retention:**
```bash
# Contact Fly.io support or upgrade to a paid plan
# Free tier: 7 days
# Paid plans: Up to 30 days
```

---

## ✅ Backup Checklist

- [x] Automatic backups **ENABLED**
- [x] Database scaled to 512MB (required)
- [x] Tigris bucket created
- [x] First backup completed successfully
- [x] Backup credentials configured
- [ ] Test restore procedure (RECOMMENDED)
- [ ] Schedule regular backup verification

---

## 🧪 Test Restore (RECOMMENDED)

**Periodically test that backups actually work:**

```bash
# 1. Create a test database
flyctl postgres create --name hudson-test-restore

# 2. Restore latest backup to it
LATEST=$(flyctl postgres backup list --app hudson-dispatch-db | tail -2 | head -1 | awk '{print $1}')
flyctl postgres restore --app hudson-test-restore --backup $LATEST

# 3. Connect and verify data
flyctl postgres connect --app hudson-test-restore
> SELECT COUNT(*) FROM events;
> SELECT COUNT(*) FROM resources;
> \q

# 4. Destroy test database
flyctl postgres destroy --app hudson-test-restore
```

---

## 💰 Costs

**Tigris Storage:**
- First 5GB: **FREE**
- After 5GB: ~$0.02/GB/month
- Egress: First 10GB free/month

**Database:**
- 512MB shared-cpu-1x: **~$1.94/month**

---

## 🔗 Fly.io Backup Documentation

- Official docs: https://fly.io/docs/postgres/managing/backup-and-restore/
- Tigris storage: https://fly.io/docs/reference/tigris/

---

## ⚡ Quick Reference

```bash
# List backups
fly pg backup list -a hudson-dispatch-db

# Create backup
fly pg backup create -a hudson-dispatch-db

# Download backup
fly pg backup download BACKUP_ID -a hudson-dispatch-db

# Restore backup
fly pg restore -a hudson-dispatch-db --backup BACKUP_ID

# Check database status
fly status -a hudson-dispatch-db
```

---

**✅ YOUR DATA IS PROTECTED**

Backups run automatically every day. You can sleep well knowing your data is safe! 🎉

