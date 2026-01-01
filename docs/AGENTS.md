# AGENTS.MD - Hudson Life Dispatch

## 🚨 CRITICAL ARCHITECTURE RULE

### Frontend = Display + Submit + Profile ONLY
### Backend = EVERYTHING ELSE

## Repository Structure

```
hudson-life-dispatch-main/              (THIS REPO - DOCS ONLY)
├── AGENTS.md                          (This file)
├── Documentation files (.md)

hudson-life-dispatch-frontend/         (Next.js - PUBLIC DISPLAY)
├── AGENTS.md                          (Frontend rules)
├── app/                               (Display pages only)
├── components/                        (Display components)
└── Public submission forms & user profiles

hudson-life-dispatch-backend/          (Laravel + Filament - ALL ADMIN)
├── AGENTS.md                          (Backend rules)
├── app/Filament/                      (ALL admin panels)
├── app/Http/Controllers/Api/          (Public APIs)
└── ALL business logic, CRUD, admin features
```

## ⚠️ Where Does Code Go?

### Frontend (Next.js) - `hudsonlifedispatch.com`

**✅ ALLOWED:**
- Display blog posts, events, businesses (read from API)
- Public submission forms (POST to Laravel API)
- User profile management (users managing their own data)
- Client-side analytics tracking
- Public pages, landing pages

**❌ FORBIDDEN:**
- Admin dashboards
- Admin CRUD interfaces
- Content management
- User management (admin level)
- Analytics dashboards
- Data processing
- Direct database access
- ANY admin features

### Backend (Laravel) - `admin.hudsonlifedispatch.com`

**✅ THIS IS WHERE EVERYTHING GOES:**
- ALL Filament admin resources
- ALL admin dashboards
- ALL CRUD operations
- ALL business logic
- ALL data processing
- ALL analytics dashboards
- ALL content management
- ALL user management (admin level)
- Public API endpoints for frontend

## 🎯 Simple Decision Tree

**When implementing a feature, ask:**

1. **Is it displaying data to public users?** → Frontend
2. **Is it a public submission form?** → Frontend (form) + Backend (API endpoint)
3. **Is it user profile management?** → Frontend (UI) + Backend (API endpoint)
4. **Is it ANYTHING admin-related?** → Backend ONLY
5. **Is it managing data?** → Backend ONLY
6. **Is it business logic?** → Backend ONLY

## 📋 Examples

### ✅ Frontend Examples
- Show list of blog posts
- Display event calendar
- Story submission form at `/share-story`
- User dashboard showing their own submissions
- Contact form
- Newsletter signup form
- Search results page

### ✅ Backend Examples
- Filament resource for managing blog posts
- Filament resource for managing story submissions
- Analytics dashboard in Filament
- API endpoint: `GET /api/blog-posts`
- API endpoint: `POST /api/story-submissions`
- Email newsletter generation
- Content scraping scripts
- User role management

## 🚫 Common Mistakes to Avoid

**❌ WRONG:** Creating admin routes in Next.js (`/admin/*`)
**✅ RIGHT:** All admin is in Laravel Filament at `admin.hudsonlifedispatch.com`

**❌ WRONG:** Building CRUD interfaces in Next.js
**✅ RIGHT:** Use Filament resources in Laravel

**❌ WRONG:** Direct database access from Next.js
**✅ RIGHT:** Next.js calls Laravel API, Laravel handles database

**❌ WRONG:** Analytics dashboard in Next.js
**✅ RIGHT:** Analytics dashboard is a Filament widget in Laravel

**❌ WRONG:** Content management in Next.js
**✅ RIGHT:** Content management via Filament resources in Laravel

## 🔄 Data Flow

```
User Request
    ↓
Next.js Frontend (Display Layer)
    ↓
Laravel API Endpoint
    ↓
Laravel Backend (Business Logic)
    ↓
Database
```

## 📝 API Communication

**Frontend makes API calls to Backend:**

```typescript
// Frontend - Fetch data
const response = await fetch('https://admin.hudsonlifedispatch.com/api/story-categories');
const categories = await response.json();

// Frontend - Submit form
const response = await fetch('https://admin.hudsonlifedispatch.com/api/story-submissions', {
  method: 'POST',
  body: JSON.stringify(formData)
});
```

**Backend provides API endpoints:**

```php
// routes/api.php
Route::get('/story-categories', [StoryCategoryController::class, 'index']);
Route::post('/story-submissions', [StorySubmissionController::class, 'store']);
```

## 🎓 Remember

The Next.js frontend is a **thin display layer**. It's like a beautiful storefront window - it shows the products (data) but all the inventory management, orders, and business operations happen in the back (Laravel).

**When in doubt: Put it in Laravel Backend.**

