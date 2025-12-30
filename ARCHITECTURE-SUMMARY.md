# Hudson Life Dispatch - Correct Architecture

## The Rule: Frontend vs Backend

### Frontend (Next.js) - **DISPLAY, SUBMISSIONS, PROFILES ONLY**
**Location:** `/hudson-life-dispatch-marketing/frontend/`
**Domain:** `hudsonlifedispatch.com`

**What Belongs Here:**
- ✅ Public pages (events calendar, blog posts, newsletter archive)
- ✅ Public submission forms (events, stories, business listings)
- ✅ User profile management
- ✅ Thank you/confirmation pages
- ✅ Public API endpoints for submissions
- ✅ Data display from database

**What Does NOT Belong Here:**
- ❌ Admin dashboards
- ❌ Content approval/rejection
- ❌ Bulk operations
- ❌ Analytics dashboards
- ❌ System settings
- ❌ User management (except own profile)

### Backend (Laravel + Filament) - **ALL ADMIN FUNCTIONALITY**
**Location:** `/hudson-life-dispatch-main/hudson-life-dispatch-backend/`
**Domain:** `admin.hudsonlifedispatch.com`

**What Belongs Here:**
- ✅ ALL admin functionality
- ✅ Content approval/rejection
- ✅ Event management
- ✅ Blog post management
- ✅ User management
- ✅ Analytics dashboards
- ✅ System settings
- ✅ Bulk operations
- ✅ Newsletter management
- ✅ Business directory management

## Event Submission System - How It Works

### 1. User Submits Event (Frontend)
```
User visits: hudsonlifedispatch.com/submit-event
  ↓
Fills form with event details
  ↓
POST to /api/submit-event
  ↓
Validation (Zod + honeypot + rate limiting)
  ↓
Saves to database with status='pending' and source_type='user_submitted'
  ↓
Redirects to: hudsonlifedispatch.com/submit-event/thank-you
```

### 2. Admin Reviews (Backend)
```
Admin visits: admin.hudsonlifedispatch.com
  ↓
Logs into Filament admin panel
  ↓
Sees Events resource in sidebar (with pending count badge)
  ↓
Clicks "Pending Review" tab
  ↓
Reviews submitted events
  ↓
Bulk select or edit individual
  ↓
Clicks "Publish" button
  ↓
Status changes from 'pending' to 'published'
```

### 3. Public Display (Frontend)
```
User visits: hudsonlifedispatch.com/events
  ↓
Frontend queries database for published events
  ↓
Displays event cards
  ↓
User can click to see full details
```

## File Structure

```
hudson-life-dispatch-main/
├── hudson-life-dispatch-backend/       ← LARAVEL + FILAMENT
│   ├── app/
│   │   ├── Models/
│   │   │   └── Event.php              ← Event model
│   │   └── Filament/
│   │       └── Resources/
│   │           └── EventResource/      ← ADMIN EVENT MANAGEMENT
│   │               ├── EventResource.php
│   │               └── Pages/
│   │                   ├── ListEvents.php
│   │                   ├── CreateEvent.php
│   │                   └── EditEvent.php
│   └── routes/
│       └── api.php                     ← Backend API routes
│
└── hudson-life-dispatch-marketing/
    └── frontend/                       ← NEXT.JS
        ├── app/
        │   ├── events/
        │   │   └── page.tsx            ← PUBLIC events display
        │   ├── submit-event/
        │   │   ├── page.tsx            ← PUBLIC submission form
        │   │   └── thank-you/
        │   │       └── page.tsx        ← Confirmation page
        │   └── api/
        │       └── submit-event/
        │           └── route.ts        ← Submission API endpoint
        └── lib/
            └── validations/
                └── event-validation.ts ← Form validation
```

## Commits Made

### Frontend Repository
1. **385e386bb** - ✅ Added public event submission system
2. **75109aea3** - ✅ Removed incorrect Next.js admin page

### Backend Repository  
3. **cb26fb0** - ✅ Added Filament EventResource for admin management

## What This Means for Future Development

### Adding New Features - Follow This Pattern:

**Example: Job Listings**

Frontend (Next.js):
- `/jobs` - Public job listings page
- `/submit-job` - Public job submission form
- `/submit-job/thank-you` - Confirmation
- `/api/submit-job` - Submission endpoint

Backend (Laravel):
- `app/Models/JobListing.php` - Model
- `app/Filament/Resources/JobListingResource.php` - Admin resource
- Admin manages at: `admin.hudsonlifedispatch.com/admin/job-listings`

**Example: Business Directory**

Frontend (Next.js):
- `/directory` - Public business directory
- `/directory/submit` - Claim/submit business
- `/api/directory/submit` - Submission endpoint

Backend (Laravel):
- `app/Models/Business.php` - Model
- `app/Filament/Resources/BusinessResource.php` - Admin resource
- Admin approves at: `admin.hudsonlifedispatch.com/admin/businesses`

## Key Principle

**If it requires authentication and admin privileges → Laravel + Filament**
**If it's public-facing or user submission → Next.js**

## Deployment

### Production URLs:
- **Public site:** `https://hudsonlifedispatch.com` (Next.js)
- **Admin panel:** `https://admin.hudsonlifedispatch.com` (Laravel + Filament)
- **API:** `https://api.hudsonlifedispatch.com` (Laravel API routes)

### Environment Variables:

**Frontend (.env.local):**
```
NEXT_PUBLIC_API_URL=https://api.hudsonlifedispatch.com
DATABASE_URL=postgresql://...
```

**Backend (.env):**
```
APP_URL=https://admin.hudsonlifedispatch.com
DB_CONNECTION=pgsql
DB_DATABASE=hudson_life_dispatch
```

---

**Important:** Always ask yourself: "Is this admin functionality?" If yes → Laravel. If no → Next.js.

**Updated:** December 30, 2025

