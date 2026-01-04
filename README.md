# Hudson Life Dispatch

Local news and community resource aggregator for Hudson Valley, NY.

## Repository Structure

This is the main repository. The project consists of **separate individual repositories**:

## Related Repositories

These are **separate individual repositories** that should be cloned separately:

- **Docs**: https://github.com/nayamoss/hudson-life-dispatch-docs (Documentation, scripts, and guides)
- **Backend**: https://github.com/nayamoss/hudson-life-dispatch-backend (Laravel backend)
- **Frontend**: https://github.com/nayamoss/hudson-life-dispatch-frontend (React frontend)
- **Marketing**: https://github.com/nayamoss/hudson-life-dispatch-marketing (Marketing site)

## Quick Start

### Clone Main Repo

```bash
git clone https://github.com/nayamoss/hudson-life-dispatch-main.git
cd hudson-life-dispatch-main
```

### Clone Individual Repos

```bash
# Clone docs (contains all documentation and scripts)
git clone https://github.com/nayamoss/hudson-life-dispatch-docs.git

# Clone backend
git clone https://github.com/nayamoss/hudson-life-dispatch-backend.git

# Clone frontend
git clone https://github.com/nayamoss/hudson-life-dispatch-frontend.git

# Clone marketing
git clone https://github.com/nayamoss/hudson-life-dispatch-marketing.git
```

### Setup Automated Scraper (Other Mac)

See `hudson-life-dispatch-docs/docs/scraper/SETUP-GUIDE-OTHER-MAC.md` for complete instructions on setting up the automated scraper on your other Mac.

Quick version:
```bash
cd hudson-life-dispatch-docs
./scripts/install-scraper.sh
```

## Documentation

All documentation is in the **hudson-life-dispatch-docs** repository:

- **Scraper Setup**: `docs/scraper/` - Setup guides and quick reference
- **Local Newsletter System**: `docs/local-newsletter/` - Business model and templates
- **AI Skills**: `docs/skills/` - Automation guides
- **Operational Playbooks**: `local-newsletter-ops/` - Real-world operator guides
- **Examples**: `ossining-ny-example/` - Complete business plan example
