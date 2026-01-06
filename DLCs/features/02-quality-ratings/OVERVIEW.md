# Feature: Quality Ratings System

**Feature ID:** DLC-02  
**Priority:** High  
**Estimated Time:** 2-4 hours  
**Status:** Not Started

---

## Problem Statement

Editors have no way to rate content quality. This makes it hard to:
- Remember why something was shortlisted
- Sort items by quality
- Track improvement in content sources over time
- Decide between similar items

---

## Solution

Add a 1-5 star rating system for all content types. Editors can rate content during review and filter/sort by rating.

---

## User Stories

**As an editor, I want to:**
- Rate content with 1-5 stars
- See ratings at a glance in tables
- Sort by highest-rated items
- Filter to show only 4-5 star content
- Add notes explaining rating

---

## Success Metrics

- 80%+ of approved content has a rating
- Editors use ratings to prioritize newsletter picks
- Average rating of newsletter content is 4+ stars

---

## Technical Scope

**Backend:**
- Add `quality_score` (1-5) and `curation_notes` fields
- Update Filament resources with rating UI
- Add sorting and filtering by rating

**Frontend:**
- No changes needed (admin-only feature)

---

## Dependencies

- Works well with DLC-01 (Shortlist) but not required

---

## Risks

- **Low Risk:** Simple integer field addition
- **No Breaking Changes:** Nullable field, no required data

---

## Files Affected

**Backend:**
- 1 migration file
- 4 Filament resources

**Total:** ~5 files

---

## Related Documents

- [PRD.md](./PRD.md) - Full product requirements
- [PLAN.md](./PLAN.md) - Implementation plan with tasks

