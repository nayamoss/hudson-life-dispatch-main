# Content Display Fix - Events Not Showing

## Problem

- Homepage sidebar shows only 1 upcoming event
- Events page (/events) also shows only upcoming events
- But database has 27 total events (21 future + 6 past)
- Events from homepage don't match events page

## Root Cause

`/api/events/upcoming` endpoint filters: `date >= now()`

Most events are in January 2026, but some might be marked as past. The issue is that 26 events aren't being returned.

## Solution

### Option 1: Show All Events (Recommended)

Change both pages to show all events, not just upcoming:

**File: `app/page.tsx` (homepage)**
```typescript
// Change from fetching specific events
// The homepage already shows posts/newsletters in the Explore section
// Just need to ensure the sidebar shows all available events
```

**File: `components/home-sidebar.tsx`**
```typescript
// Line 28 - Change from:
const response = await fetch(`${API_URL}/events/upcoming?limit=5`)
// To:
const response = await fetch(`${API_URL}/events?limit=5`)
```

**File: `app/events/page.tsx`**
```typescript
// Line 41 - Change from:
const response = await fetch(`${API_URL}/events/upcoming`, {
// To:
const response = await fetch(`${API_URL}/events`, {
```

### Option 2: Fix the API to Return All Events

The EventController defaults to filtering by `date >= now()` even when not requested. Fix this in the backend:

**File: `app/Http/Controllers/Api/EventController.php`**

Change lines 45-47 from:
```php
// Default to upcoming events
if (!$request->has('upcoming') && !$request->has('featured')) {
    $query->where('date', '>=', now());
}
```

To:
```php
// Only filter by date if explicitly requested
if ($request->get('upcoming') === 'true') {
    $query->where('date', '>=', now());
}
```

## Current Status

Database:
- ✅ 27 events total
- ✅ 21 future events (Jan 30, 31 and beyond)
- ✅ 6 past events (before Jan 13, 2026)
- ✅ Data intact in hudson-dispatch-db-v2

## To Implement

1. Choose Option 1 or 2 above
2. Update files mentioned
3. Deploy backend (if Option 2) or redeploy frontend (if Option 1)
4. Test: visit homepage and /events page
5. Both should now show consistent data

## For Database Management

You can now:
✅ Add new events via Laravel admin (TBD - need to set up admin login)
✅ Edit existing events
✅ Delete old events
✅ Create new posts and newsletters

Access the admin panel at: `https://admin.hudsonlifedispatch.com` (once admin setup is complete)
