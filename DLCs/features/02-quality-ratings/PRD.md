# PRD: Quality Ratings System

**Feature ID:** DLC-02  
**Author:** AI Development Team  
**Date:** January 5, 2026  
**Status:** Draft

---

## 1. Executive Summary

Add a 1-5 star quality rating system for content (events, jobs, stories, community news). This helps editors prioritize high-quality content and track source quality over time.

---

## 2. Background

### Current State
- No way to rate content quality
- Editors rely on memory for quality assessments
- Can't easily compare items by quality
- No metrics for content source quality

### Desired State
- Quick star rating (1-5) for all content
- Sortable and filterable by rating
- Optional notes to explain rating
- Quality analytics over time

---

## 3. Goals & Objectives

### Primary Goals
1. Enable quality-based content prioritization
2. Track content source quality trends
3. Improve newsletter content quality

### Non-Goals
- Public-facing ratings (admin-only)
- AI-generated ratings (manual only for v1)
- Average ratings across multiple raters (single-rater for v1)

---

## 4. User Personas

### Primary: Newsletter Editor (Sarah)
- **Role:** Content curator
- **Goal:** Pick only highest-quality content for newsletter
- **Pain:** Hard to remember which items were best
- **Need:** Quick rating system with visual indicators

---

## 5. Requirements

### Functional Requirements

#### FR-1: Rating Field
- `quality_score` integer field (1-5)
- Nullable (not required)
- Show as star icons in UI

#### FR-2: Rating Input
- Star selector in form (1-5 stars)
- Quick-rate buttons in table actions
- Bulk rating capability

#### FR-3: Curation Notes
- `curation_notes` text field
- Optional reasoning for rating
- Visible only to admins

#### FR-4: Filtering & Sorting
- Filter by rating (4-5 stars, 3+ stars, etc.)
- Sort by rating (highest first)
- Show average rating per source

#### FR-5: Visual Indicators
- Display stars in table column (⭐⭐⭐⭐⭐)
- Color-coded badges
- "Unrated" indicator

### Non-Functional Requirements

#### NFR-1: Performance
- Rating updates execute in <100ms
- Sorting by rating must be indexed

#### NFR-2: Analytics
- Track rating distribution
- Show average rating by content type
- Show average rating by source

---

## 6. User Experience

### Rating Workflow

```
1. Editor reviews content
2. Clicks star rating (or selects 1-5)
3. Optionally adds notes
4. Saves rating
5. Rating appears in table view
```

### UI Mockup (Filament Form)

```
┌─────────────────────────────────────────────┐
│ Quality Assessment                          │
├─────────────────────────────────────────────┤
│ Quality Rating                              │
│ [⭐] [⭐] [⭐] [⭐] [⭐]  (Excellent)        │
│                                             │
│ Curation Notes (optional)                   │
│ ┌─────────────────────────────────────────┐ │
│ │ Great event, unique activity, well-     │ │
│ │ organized, perfect for families         │ │
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

### UI Mockup (Filament Table)

```
┌──────────────────────────────────────────────────────┐
│ Title              │ Category  │ Quality │ Status    │
├────────────────────┼───────────┼─────────┼───────────┤
│ Jazz Night         │ Music     │ ⭐⭐⭐⭐⭐ │ Approved │
│ Farmers Market     │ Community │ ⭐⭐⭐⭐   │ Shortlist│
│ Bingo Night        │ Family    │ ⭐⭐⭐    │ Inbox    │
│ Parking Lot Event  │ Other     │ ⭐       │ Rejected │
│ [Unrated Event]    │ Business  │ —       │ Inbox    │
└──────────────────────────────────────────────────────┘
```

---

## 7. Technical Design

### Database Schema

```sql
-- Migration: add_quality_rating_to_content_tables.php
ALTER TABLE events 
ADD COLUMN quality_score INT(1) UNSIGNED NULL 
AFTER curation_status,
ADD COLUMN curation_notes TEXT NULL 
AFTER quality_score,
ADD INDEX idx_quality_score (quality_score);

-- Repeat for: job_listings, story_submissions, community_news_items
```

### Filament Implementation

```php
// Form Component
Forms\Components\Section::make('Quality Assessment')
    ->schema([
        Forms\Components\Select::make('quality_score')
            ->label('Quality Rating')
            ->options([
                5 => '⭐⭐⭐⭐⭐ Excellent - Must include',
                4 => '⭐⭐⭐⭐ Good - Strong candidate',
                3 => '⭐⭐⭐ Average - Maybe',
                2 => '⭐⭐ Below Average - Probably not',
                1 => '⭐ Poor - Do not include',
            ])
            ->placeholder('Not rated yet')
            ->helperText('Rate quality for newsletter inclusion'),
        
        Forms\Components\Textarea::make('curation_notes')
            ->label('Curation Notes')
            ->placeholder('Why this rating? What makes it good/bad?')
            ->rows(3)
            ->helperText('Internal notes visible only to admins')
    ])

// Table Column
Tables\Columns\TextColumn::make('quality_score')
    ->label('Quality')
    ->formatStateUsing(fn ($state) => $state 
        ? str_repeat('⭐', (int)$state) 
        : '—'
    )
    ->sortable()
    ->tooltip(fn ($record) => $record->curation_notes ?? 'No notes')
```

---

## 8. Success Criteria

### Launch Criteria
- ✅ Rating works for all 4 content types
- ✅ Sorting by rating is fast (<200ms)
- ✅ Bulk rating actions work

### Post-Launch Metrics (30 days)
- **Adoption:** 80%+ of approved content has rating
- **Quality:** Average rating in newsletters is 4+ stars
- **Consistency:** Rating variance decreases over time

---

## 9. Analytics & Reporting

### Metrics to Track

#### Content Quality Metrics
```sql
-- Average rating by content type
SELECT 
    'events' as type,
    AVG(quality_score) as avg_rating,
    COUNT(*) as total_rated
FROM events 
WHERE quality_score IS NOT NULL;

-- Distribution of ratings
SELECT 
    quality_score,
    COUNT(*) as count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM events
WHERE quality_score IS NOT NULL
GROUP BY quality_score
ORDER BY quality_score DESC;

-- Top-rated content by source
SELECT 
    source_type,
    AVG(quality_score) as avg_rating,
    COUNT(*) as count
FROM events
WHERE quality_score IS NOT NULL
GROUP BY source_type
ORDER BY avg_rating DESC;
```

### Dashboard Widgets (Future Enhancement)
- Quality score distribution chart
- Average rating by source
- Trending quality over time
- Unrated content count

---

## 10. Out of Scope (Future Enhancements)

- AI-suggested ratings based on content analysis
- Multi-rater consensus (average of multiple editors)
- Public ratings (user feedback on quality)
- Rating impact on search ranking
- Automatic quality scoring for scraped content

---

## 11. Open Questions

- **Q:** Should ratings be editable after approval?
  - **A:** Yes, editors can update anytime
  
- **Q:** Show ratings to content submitters?
  - **A:** No, internal only for v1

- **Q:** Required field or optional?
  - **A:** Optional, not blocking approval

---

## 12. Appendix

### Rating Guidelines for Editors

**⭐⭐⭐⭐⭐ (5 stars) - Excellent**
- Unique, can't-miss event
- Perfect fit for target audience
- High production value
- Must include in newsletter

**⭐⭐⭐⭐ (4 stars) - Good**
- Strong event worth featuring
- Good fit for audience
- Well-organized and professional

**⭐⭐⭐ (3 stars) - Average**
- Decent event, maybe include
- Fits audience but not special
- Backup option if space available

**⭐⭐ (2 stars) - Below Average**
- Weak event, probably skip
- Marginal audience fit
- Better options available

**⭐ (1 star) - Poor**
- Do not include
- Wrong audience or low quality
- Keep for reference only

