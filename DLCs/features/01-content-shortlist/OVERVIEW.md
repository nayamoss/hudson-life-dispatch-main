# Feature: Content Shortlist System

**Feature ID:** DLC-01  
**Priority:** High  
**Estimated Time:** 2-4 hours  
**Status:** Not Started

---

## Problem Statement

Currently, editors can only approve or reject content (events, jobs, stories). There's no way to mark items as "maybe" or "review later." This makes it hard to:
- Build a shortlist of candidates for the newsletter
- Come back to review borderline items
- Compare multiple items before making final decisions

---

## Solution

Add a "Shortlist" status that sits between "Pending" and "Approved/Rejected." This creates a three-stage workflow:

1. **Inbox** (Pending) - New submissions
2. **Shortlist** (Maybe) - Items under consideration
3. **Final Decision** (Approved/Rejected) - Final state

---

## User Stories

**As an editor, I want to:**
- Mark items as "shortlist" so I can review them together later
- See all shortlisted items in one view
- Move items from shortlist to approved/rejected easily
- Filter content by shortlist status

---

## Success Metrics

- Editors use shortlist status on 30%+ of content
- Time to curate newsletter decreases by 20%
- Editors report easier decision-making in feedback

---

## Technical Scope

**Backend:**
- Add `curation_status` enum field to 4 tables
- Update Filament resources with new status option
- Add bulk actions for shortlist operations

**Frontend:**
- No changes needed (admin-only feature)

---

## Dependencies

- None (standalone feature)

---

## Risks

- **Low Risk:** Simple enum field addition
- **No Breaking Changes:** Existing content defaults to "inbox"

---

## Files Affected

**Backend:**
- 1 migration file
- 4 Filament resources (Event, JobListing, StorySubmission, CommunityNewsItem)

**Total:** ~5 files

---

## Related Documents

- [PRD.md](./PRD.md) - Full product requirements
- [PLAN.md](./PLAN.md) - Implementation plan with tasks

