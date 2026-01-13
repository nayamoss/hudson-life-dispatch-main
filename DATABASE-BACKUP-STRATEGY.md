# Hudson Life Dispatch Database Strategy

## Current State (Jan 13, 2026)

**Production Database:** `hudson-dispatch-db-v2` (PostgreSQL on Fly.io)

**Backend Connection:** `DATABASE_URL` env var points to `hudson-dispatch-db-v2.internal`

**Data Restored:**
- 27 Hudson Life Dispatch events
- 569 scraping resources  
- 3 blog posts
- 3 newsletters
- User account(s)

---

## Lessons Learned from Data Loss

**What went wrong:**
1. Ran migrations on production database without backup
2. YNAP test data overwrote Hudson Life Dispatch content  
3. Destroyed database when trying to restore from corrupted snapshot
4. Snapshot restoration had boot issues
5. No clear backup strategy documented

**What went right:**
- Backup files in `storage/app/private/backups/` saved us
- Markdown source files in `hudson-life-dispatch-marketing/content/` as backup
- JSON backup of resources allowed full recovery

---

## Prevention Strategy

### 1. Weekly Automated Backups

Create a seeder that runs weekly via Laravel scheduler to backup critical tables:

```bash
# Every Sunday at 2 AM UTC
php artisan schedule:work
```

**Backup files stored in:** `storage/app/private/backups/`

**Tables backed up:**
- blog_posts → `blog_posts.json`
- newsletters → `newsletters.json`
- events → `events.json`
- resources → `resources.json`
- users → `users.json`

### 2. Backup Rotation

Keep last 4 weekly backups:
- Week 1 (oldest)
- Week 2
- Week 3
- Week 4 (newest)

Delete older backups automatically.

### 3. Backup Verification

After each backup, verify:
- JSON files are valid (parseable)
- Record counts match database
- Files are readable and not corrupted

### 4. Source Control Backups

**Content in Git (always):**
- Blog posts as markdown: `hudson-life-dispatch-marketing/content/`
- Newsletters as markdown: `hudson-life-dispatch-marketing/content/`
- Drafts and research: `hudson-life-dispatch-marketing/drafts/`

**Always commit content before changes!**

### 5. Emergency Procedures

**If production database is corrupted:**

1. **Option A: Restore from backup (fast)**
   ```bash
   fly ssh console -a hudson-dispatch-api
   php artisan db:seed RestoreProductionDataSeeder --force
   php artisan db:seed ImportContentFromMarkdownSeeder --force
   ```

2. **Option B: Restore from source files (safe)**
   - Revert markdown files from git history
   - Run ImportContentFromMarkdownSeeder
   - Manually recreate any lost data

3. **Option C: Start fresh (last resort)**
   - Create new database
   - Run migrations
   - Restore from oldest backup

### 6. Database Naming Convention

**Current:** `hudson-dispatch-db-v2` ← Keep this, it's production

**Never create:**
- `hudson-dispatch-db-v3` (leads to confusion)
- Multiple databases with same data
- Databases without clear purpose

**If you need a test database:**
```
Name: hudson-dispatch-db-staging
Purpose: For testing migrations/changes
Access: Only from local machine via SSH
Note: NOT production data
```

---

## Checklist: Before Making Changes

### Before running migrations:
- [ ] Backup production database locally
- [ ] Test migration on staging database first
- [ ] Have rollback plan documented
- [ ] Notify team of downtime window

### Before deleting/modifying data:
- [ ] Confirm you're in correct environment (staging NOT prod)
- [ ] Export data as JSON backup
- [ ] Store backup in multiple places
- [ ] Test that backup can be restored

### After any major operation:
- [ ] Verify data integrity
- [ ] Test API endpoints return data
- [ ] Check frontend displays content
- [ ] Commit changes to git

---

## Database Health Check Script

Run weekly to verify database health:

```bash
# Check in SSH console
php artisan tinker

# Count records in each table
>>> App\Models\BlogPost::count()
>>> App\Models\Newsletter::count()
>>> App\Models\Event::count()
>>> App\Models\Resource::count()

# Check recent posts
>>> App\Models\BlogPost::latest()->first()
>>> App\Models\Newsletter::latest()->first()
```

---

## Backup File Locations

**Automatic backups:**
```
/app/storage/app/private/backups/
  └── backup-YYYY-MM-DD_HH-MM-SS/
      ├── metadata.json
      ├── blog_posts.json
      ├── newsletters.json
      ├── events.json
      ├── resources.json
      └── users.json
```

**Source files (Git):**
```
hudson-life-dispatch-marketing/
  ├── content/
  │   ├── blog-post-1.md
  │   ├── blog-post-2.md
  │   ├── blog-post-3.md
  │   ├── newsletter-1.md
  │   ├── newsletter-2.md
  │   └── newsletter-3.md
  └── drafts/
      └── [research and drafts]
```

---

## Never Do This Again

❌ **Don't:**
- Run migrations without testing on staging first
- Create multiple databases with same data
- Delete databases without backups
- Overwrite production data with test data
- Skip backup verification
- Make changes without git commits

✅ **Do:**
- Keep one production database (`hudson-dispatch-db-v2`)
- Backup to JSON before major changes
- Store content in git (markdown)
- Test in staging environment
- Document all database operations
- Verify backups work before deleting original

---

## Emergency Contact Procedure

If database issues occur:

1. **Stop the bleeding** - disable writes to prevent further data loss
2. **Assess damage** - what data was affected?
3. **Restore from backup** - use oldest available backup
4. **Verify** - count records, check API endpoints
5. **Rebuild content** - re-import from markdown if needed
6. **Document** - write incident report and prevent recurrence

---

## Todo: Implement Automated Backups

- [ ] Create BackupDatabaseCommand
- [ ] Add to Laravel schedule
- [ ] Test backup/restore cycle
- [ ] Set up Slack notifications for backups
- [ ] Document recovery procedures
- [ ] Train team on procedures
