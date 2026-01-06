# Hudson Life Dispatch - DLC Features

**DLC** = Downloadable Content (features that enhance the core application)

This directory contains spec-driven development plans for features identified as missing from the newsletter curation best practices analysis.

> **⚠️ IMPORTANT:** For accurate implementation prompts with correct tech stack info, see [CORRECTED-PROMPTS.md](./CORRECTED-PROMPTS.md)

## Tech Stack
- **Backend:** Laravel (PHP 8.2+) with Filament - localhost:8000/admin
- **Frontend:** Next.js 15 (TypeScript) - localhost:3000
- **Database:** SQLite (database/database.sqlite)
- **Email:** Resend API

---

## Overview

Based on a comprehensive codebase audit comparing our implementation against newsletter industry best practices, we identified **4 missing features** that would complete our curation workflow:

1. **Content Shortlist System** - "Maybe" option for curation workflow
2. **Quality Ratings System** - 1-5 star ratings for content
3. **Referral Rewards System** - Milestone-based prizes for referrals
4. **Partner Newsletter Cross-Promotions** - Newsletter swap system

---

## Implementation Status

| Feature ID | Feature Name | Priority | Time Estimate | Status |
|------------|-------------|----------|---------------|--------|
| DLC-01 | Content Shortlist | High | 2-4 hours | ⏳ Not Started |
| DLC-02 | Quality Ratings | High | 2-4 hours | ⏳ Not Started |
| DLC-03 | Referral Rewards | Medium | 3-6 hours | ⏳ Not Started |
| DLC-04 | Cross-Promotions | Medium | 3-5 hours | ⏳ Not Started |

**Total Estimated Time:** 10-19 hours

---

## Feature Details

### DLC-01: Content Shortlist System

**Problem:** Editors can only approve/reject content. No "maybe" option for borderline items.

**Solution:** Add a "Shortlist" curation status that creates a three-stage workflow (Inbox → Shortlist → Approved/Rejected).

**Files:**
- [features/01-content-shortlist/OVERVIEW.md](./features/01-content-shortlist/OVERVIEW.md)
- [features/01-content-shortlist/PRD.md](./features/01-content-shortlist/PRD.md)
- [features/01-content-shortlist/PLAN.md](./features/01-content-shortlist/PLAN.md)

**Key Benefits:**
- Defer decisions on borderline content
- Build curated list of newsletter candidates
- Compare multiple items before deciding
- 20% faster newsletter curation

---

### DLC-02: Quality Ratings System

**Problem:** No way to rate content quality, making it hard to prioritize best items.

**Solution:** Add 1-5 star rating system with optional curation notes.

**Files:**
- [features/02-quality-ratings/OVERVIEW.md](./features/02-quality-ratings/OVERVIEW.md)
- [features/02-quality-ratings/PRD.md](./features/02-quality-ratings/PRD.md)
- [features/02-quality-ratings/PLAN.md](./features/02-quality-ratings/PLAN.md)

**Key Benefits:**
- Track content source quality over time
- Filter/sort by highest-rated items
- Improve newsletter content quality
- Data-driven curation decisions

---

### DLC-03: Referral Rewards System

**Problem:** Referral tracking exists but no rewards configured, limiting growth potential.

**Solution:** Milestone-based rewards system (3, 5, 10, 25, 50+ referrals earn prizes).

**Files:**
- [features/03-referral-rewards/OVERVIEW.md](./features/03-referral-rewards/OVERVIEW.md)
- [features/03-referral-rewards/PRD.md](./features/03-referral-rewards/PRD.md)
- [features/03-referral-rewards/PLAN.md](./features/03-referral-rewards/PLAN.md)

**Key Benefits:**
- Increase referral rate from <5% to 20%+
- Drive 50%+ growth in subscriber signups
- Build community engagement
- Partner with local businesses for rewards

---

### DLC-04: Partner Newsletter Cross-Promotions

**Problem:** No system for cross-promoting with partner newsletters, missing growth opportunity.

**Solution:** Partner management system with scheduled promos, tracking links, and analytics.

**Files:**
- [features/04-cross-promotions/OVERVIEW.md](./features/04-cross-promotions/OVERVIEW.md)
- [features/04-cross-promotions/PRD.md](./features/04-cross-promotions/PRD.md)
- [features/04-cross-promotions/PLAN.md](./features/04-cross-promotions/PLAN.md)

**Key Benefits:**
- 10%+ of new subscribers from partner referrals
- Zero-cost acquisition (vs. $5-20 paid ads)
- Build local newsletter coalition
- Establish 5+ active partnerships

---

## How to Use These Specs

Each feature folder contains three documents:

### 1. OVERVIEW.md
- Quick summary of the feature
- Problem statement
- High-level solution
- Success metrics
- Files affected estimate

**Use when:** Getting quick context or deciding priority

### 2. PRD.md (Product Requirements Document)
- Executive summary
- Detailed requirements (functional & non-functional)
- User personas and stories
- Technical design
- UI/UX mockups
- Success criteria
- Competitive analysis

**Use when:** Understanding full scope before building

### 3. PLAN.md (Implementation Plan)
- Phase-by-phase breakdown
- Specific tasks with time estimates
- Code samples for each task
- Acceptance criteria/checklists
- Testing plan
- Deployment steps

**Use when:** Actually implementing the feature

---

## Recommended Implementation Order

### Option A: Ship Now, Iterate Later
Current feature completeness: **92%**

**Recommendation:** Launch newsletter now, add DLCs based on user feedback.

**Order:**
1. Launch with current features ✅
2. Gather user feedback (30 days)
3. Implement DLC-01 & DLC-02 (improve curation UX)
4. Monitor growth, decide on DLC-03 & DLC-04

---

### Option B: Build Quick Wins First
Add highest-value features before launch.

**Recommended Order:**
1. **DLC-01: Content Shortlist** (2-4 hours)
   - Immediate curation workflow improvement
   - Low risk, high editor satisfaction
   
2. **DLC-02: Quality Ratings** (2-4 hours)
   - Complements shortlist perfectly
   - Better newsletter content quality

3. **Launch newsletter** ✅

4. **DLC-03: Referral Rewards** (3-6 hours)
   - Drive subscriber growth post-launch
   - Requires some subscribers first

5. **DLC-04: Cross-Promotions** (3-5 hours)
   - Best after establishing base audience
   - Needs partners to be valuable

**Total Time Before Launch:** 4-8 hours (DLC-01 + DLC-02)

---

### Option C: Complete Before Launch
Implement all 4 DLCs for 100% feature parity.

**Timeline:** 10-19 hours total
**Pros:** Full feature set from day one
**Cons:** Delayed launch, might overbuild

**Only choose this if:**
- You have 2-3 full days available
- Users are already asking for these features
- Competitive pressure requires feature parity

---

## Current Application Status

### ✅ Already Implemented (92%)

**Core Newsletter System:**
- Automated content sourcing (scrapers, APIs)
- AI-generated summaries (GPT integration)
- Newsletter templates with TipTap editor
- Email sending via Resend
- Subscriber management with referral tracking
- Admin dashboard (Filament)
- Public frontend (Next.js)
- Analytics and reporting

**Content Management:**
- Events, jobs, stories, community news
- Approval workflows (pending → approved/rejected)
- Category tagging and filtering
- Featured content promotion
- Newsletter assignment

**Advanced Features:**
- Ad inventory calendar
- Sponsor management
- Referral tracking and leaderboard
- Email templates
- Scheduled publishing
- Dark mode, i18n, SEO

### ❌ Missing (8%) - These DLCs

1. Shortlist/"maybe" curation status
2. Quality rating system (1-5 stars)
3. Referral rewards configuration
4. Partner newsletter cross-promotions

---

## Success Metrics

After implementing all DLCs, track these metrics:

**Content Curation (DLC-01, DLC-02):**
- Time to curate newsletter: 20% decrease
- Editor satisfaction: 8+/10
- Newsletter quality: 4+ star average
- Shortlist usage: 30%+ of content

**Growth (DLC-03, DLC-04):**
- Referral rate: 20%+ of subscribers
- Partner-driven signups: 10%+ of new subscribers
- Subscriber growth rate: 50%+ increase
- Cost per acquisition: $0 (vs. $5-20 paid ads)

---

## Questions?

For questions about specific features, see the individual feature folders.

For general questions about the DLC system, contact the development team.

---

## Changelog

- **2026-01-05:** Initial DLC specs created (4 features)

---

## Related Documents

- [REAL-FEATURE-GAP-ANALYSIS.md](../REAL-FEATURE-GAP-ANALYSIS.md) - Full codebase audit
- [FEATURES-TO-ADD-NOW.md](../FEATURES-TO-ADD-NOW.md) - Original action plan
- [hudson-life-dispatch-backend/README.md](../hudson-life-dispatch-backend/README.md) - Backend docs
- [hudson-life-dispatch-frontend/README.md](../hudson-life-dispatch-frontend/README.md) - Frontend docs

