# Hudson Life Dispatch - Documentation Index

Last Updated: January 2, 2026

---

## 📚 Core Documentation

### Getting Started
- **[README.md](README.md)** - Project overview, goals, marketing strategy, quick start guide

### Setup & Deployment
- **[SETUP-OTHER-MAC.md](SETUP-OTHER-MAC.md)** - Complete production setup guide for automated scraping
- **[setup-automated-scraper.sh](setup-automated-scraper.sh)** - Automated setup script
- **[supervisor-scraper-queue.conf](supervisor-scraper-queue.conf)** - Queue worker configuration

### Technical Guides
- **[SCRAPER-GUIDE.md](SCRAPER-GUIDE.md)** - Comprehensive scraping system documentation
  - Smart features (hash detection, adaptive scheduling)
  - Resource categories & strategies
  - Implementation phases (1-4)
  - Commands & monitoring
  - Technology stack

- **[RESOURCES-MANAGEMENT.md](RESOURCES-MANAGEMENT.md)** - Filament admin interface guide
  - How to manage 569+ content sources
  - Admin panel features & workflows
  - Database schema

### Safety & Operations
- **[DATABASE-SAFETY.md](DATABASE-SAFETY.md)** - Critical database safety rules
  - Backup procedures
  - Safe vs forbidden commands
  - Emergency restore procedures

- **[FLY-IO-BACKUP-GUIDE.md](FLY-IO-BACKUP-GUIDE.md)** - Production database backups
  - Automatic backup schedule
  - Backup/restore commands
  - Emergency recovery procedures

---

## 📁 Additional Documentation

### Reference
- **[docs/EVENT-SOURCES-ADDED-2026-01-02.md](docs/EVENT-SOURCES-ADDED-2026-01-02.md)** - Complete inventory of 130+ event sources by town

### Supporting Folders
- **docs/** - Additional project documentation
- **guides/** - Specific how-to guides
- **hudson-life-dispatch-backend/** - Laravel backend code
- **hudson-life-dispatch-frontend/** - React frontend code  
- **hudson-life-dispatch-marketing/** - Marketing website code

---

## 🗑️ Removed Documents (January 2, 2026)

The following redundant documents were deleted and consolidated into **SCRAPER-GUIDE.md**:

1. ~~WHAT-YOU-GOT.md~~ - Session summary (redundant)
2. ~~AUTOMATED-SCRAPER-STATUS.md~~ - Outdated status snapshot
3. ~~SMART-FREQUENCY-SCRAPING.md~~ - Specific fix (covered in main guide)
4. ~~CHEAPEST-SCRAPING-OPTIONS.md~~ - Cost research (decision made)
5. ~~PIPELINE-FIX.md~~ - Specific fix (either done or not relevant)
6. ~~PHASE-1-IMPLEMENTATION.md~~ - Consolidated into SCRAPER-GUIDE.md
7. ~~SCRAPER-IMPLEMENTATION.md~~ - Consolidated into SCRAPER-GUIDE.md
8. ~~RESOURCE-SCRAPING-STRATEGY.md~~ - Consolidated into SCRAPER-GUIDE.md

---

## 📖 Quick Navigation

### I want to...

**...understand the project** → Read [README.md](README.md)

**...set up automated scraping** → Follow [SETUP-OTHER-MAC.md](SETUP-OTHER-MAC.md)

**...understand how scraping works** → Read [SCRAPER-GUIDE.md](SCRAPER-GUIDE.md)

**...manage content sources** → Read [RESOURCES-MANAGEMENT.md](RESOURCES-MANAGEMENT.md)

**...backup the database** → Read [DATABASE-SAFETY.md](DATABASE-SAFETY.md) or [FLY-IO-BACKUP-GUIDE.md](FLY-IO-BACKUP-GUIDE.md)

**...find event sources** → See [docs/EVENT-SOURCES-ADDED-2026-01-02.md](docs/EVENT-SOURCES-ADDED-2026-01-02.md)

---

## 🎯 Documentation Philosophy

This project maintains:
- **Minimal documentation** - Only essential guides, no session summaries
- **Consolidated guides** - One comprehensive doc per topic
- **Actionable content** - Step-by-step instructions, no theory-only docs
- **Living documents** - Updated as systems evolve

---

**Questions?** Start with [README.md](README.md) for project overview.

