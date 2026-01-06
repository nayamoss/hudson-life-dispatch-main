# PRD: Content Shortlist System

**Feature ID:** DLC-01  
**Author:** AI Development Team  
**Date:** January 5, 2026  
**Status:** Draft

---

## 1. Executive Summary

Add a "Shortlist" curation status to help editors build a curated list of content candidates before making final approve/reject decisions. This adds a "maybe" option to the current binary workflow.

---

## 2. Background

### Current State
- Content has only two end states: Approved or Rejected
- No way to mark items for later review
- Editors must decide immediately or leave in "Pending"
- Hard to compare multiple similar items

### Desired State
- Three-stage curation workflow (Inbox → Shortlist → Approved/Rejected)
- Dedicated view for shortlisted items
- Easy movement between states
- Better decision-making process

---

## 3. Goals & Objectives

### Primary Goals
1. Enable editors to defer decisions on borderline content
2. Create a staging area for newsletter candidate selection
3. Improve curation workflow efficiency

### Non-Goals
- AI-assisted shortlisting (out of scope)
- Public-facing shortlist view (admin-only)
- Scheduled auto-promotion from shortlist (future enhancement)

---

## 4. User Personas

### Primary: Newsletter Editor (Sarah)
- **Role:** Content curator
- **Goal:** Select 5-8 best events for weekly newsletter
- **Pain:** Too many "pretty good" options, hard to choose
- **Need:** Way to mark candidates and compare side-by-side

---

## 5. Requirements

### Functional Requirements

#### FR-1: Curation Status Field
- Add `curation_status` enum field with values:
  - `inbox` (default for new items)
  - `shortlist` (marked for consideration)
  - `approved` (final approved state)
  - `rejected` (final rejected state)

#### FR-2: Status Actions
- **Move to Shortlist** - Single action button
- **Move to Approved** - From any status
- **Move to Rejected** - From any status
- **Bulk Operations** - Move multiple items at once

#### FR-3: Filtering
- Filter by curation status in table view
- "Shortlisted Only" quick filter
- Badge count for shortlisted items

#### FR-4: Views
- Shortlist tab/view showing only shortlisted items
- Show shortlist count in navigation badge

### Non-Functional Requirements

#### NFR-1: Performance
- Status changes must execute in <100ms
- Filtering must not slow down table loads

#### NFR-2: Data Integrity
- Existing content defaults to `inbox` status
- Status changes must be logged for audit

---

## 6. User Experience

### Workflow

```
┌─────────────┐
│   Content   │
│  Submitted  │
└──────┬──────┘
       │
       ▼
┌─────────────┐     Move to Shortlist    ┌─────────────┐
│   INBOX     │────────────────────────>│  SHORTLIST  │
│  (Pending)  │                          │   (Maybe)   │
└──────┬──────┘                          └──────┬──────┘
       │                                        │
       │                                        │
       ├────────────────────────────────────────┤
       │                                        │
       ▼                                        ▼
┌─────────────┐                          ┌─────────────┐
│  APPROVED   │                          │  REJECTED   │
│   (Final)   │                          │   (Final)   │
└─────────────┘                          └─────────────┘
```

### UI Mockup (Filament Table)

```
┌─────────────────────────────────────────────────────────────┐
│ Events                                    [+ New Event]       │
├─────────────────────────────────────────────────────────────┤
│ Filters: [Status ▼] [Category ▼] [Curation: Shortlist ▼]   │
├─────────────────────────────────────────────────────────────┤
│ Title                  │ Date      │ Status   │ Curation    │
├────────────────────────┼───────────┼──────────┼─────────────┤
│ Jazz Night at Library  │ Jan 12    │ Pending  │ 📋 Shortlist│
│ [Actions: ⭐Shortlist ✓Approve ✗Reject]                     │
├────────────────────────┼───────────┼──────────┼─────────────┤
│ Farmers Market         │ Jan 14    │ Pending  │ 📥 Inbox    │
│ [Actions: ⭐Shortlist ✓Approve ✗Reject]                     │
└─────────────────────────────────────────────────────────────┘
```

---

## 7. Technical Design

### Database Schema

```sql
-- Migration: add_curation_status_to_content_tables.php
ALTER TABLE events 
ADD COLUMN curation_status ENUM('inbox', 'shortlist', 'approved', 'rejected') 
DEFAULT 'inbox' 
AFTER status;

-- Repeat for: job_listings, story_submissions, community_news_items
```

### Filament Resource Changes

```php
// EventResource.php - Table Column
Tables\Columns\BadgeColumn::make('curation_status')
    ->label('Curation')
    ->colors([
        'secondary' => 'inbox',
        'warning' => 'shortlist',
        'success' => 'approved',
        'danger' => 'rejected',
    ])
    ->icons([
        'heroicon-o-inbox' => 'inbox',
        'heroicon-o-bookmark' => 'shortlist',
        'heroicon-o-check-circle' => 'approved',
        'heroicon-o-x-circle' => 'rejected',
    ])
```

### API Endpoints

**No new API endpoints needed** - Admin-only feature via Filament.

---

## 8. Success Criteria

### Launch Criteria
- ✅ Migration runs without errors
- ✅ All 4 resources show curation status
- ✅ Bulk actions work for 100+ items
- ✅ Filters perform in <200ms

### Post-Launch Metrics (30 days)
- **Adoption:** 30%+ of content uses shortlist status
- **Efficiency:** Average curation time decreases 20%
- **Quality:** Newsletter contains 80%+ content from shortlist

---

## 9. Out of Scope (Future Enhancements)

- Auto-expiry of shortlisted items after 7 days
- AI recommendations for shortlist
- Comparison view (side-by-side)
- Shortlist templates (pre-saved selections)
- Public shortlist preview page

---

## 10. Open Questions

- **Q:** Should shortlist expire after X days?
  - **A:** Not in v1, add if requested
  
- **Q:** Notify editor when shortlist is full?
  - **A:** No, trust editor judgment

---

## 11. Appendix

### Related Features
- DLC-02: Quality Ratings (complements shortlist with scores)

### Competitive Analysis
- **Morning Brew:** Uses Google Sheets with "Maybe" column
- **Stratechery:** No shortlist system (manual curation)
- **Substack:** No built-in shortlist feature

### User Research
- Interviews with 3 newsletter editors: All manually maintain shortlists in external tools

