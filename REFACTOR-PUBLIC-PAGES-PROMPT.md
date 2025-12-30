# AI Agent Task: Refactor Public Pages to Use Laravel API

## Mission

Remove direct database access from Next.js frontend public pages and replace with Laravel API calls. The frontend should ONLY display data, never touch the database directly.

## Architecture Overview

### CURRENT (WRONG)
```
User Browser → Next.js Frontend → Direct Database Access (via Drizzle ORM)
```

### TARGET (CORRECT)
```
User Browser → Next.js Frontend → Laravel API → Laravel Database
```

**Key Principle:** The Next.js frontend is a DISPLAY LAYER ONLY. All data access must go through the Laravel backend API.

## Your Working Directory

```
/Users/nierda/GitHub/sites/hudson-life-dispatch-main/
├── hudson-life-dispatch-frontend/  (Next.js - where you'll work)
└── hudson-life-dispatch-backend/   (Laravel - API endpoints you'll call)
```

## Files to Refactor (Batch 1 - Public Pages Only)

Work on these 9 files in order:

1. `hudson-life-dispatch-frontend/app/blog/page.tsx` - Blog list page
2. `hudson-life-dispatch-frontend/app/blog/[slug]/page.tsx` - Blog detail page
3. `hudson-life-dispatch-frontend/app/events/page.tsx` - Events list page
4. `hudson-life-dispatch-frontend/app/events/[id]/page.tsx` - Event detail page
5. `hudson-life-dispatch-frontend/app/jobs/page.tsx` - Jobs list page
6. `hudson-life-dispatch-frontend/app/jobs/[id]/page.tsx` - Job detail page
7. `hudson-life-dispatch-frontend/app/newsletter/page.tsx` - Newsletter list page
8. `hudson-life-dispatch-frontend/app/newsletter/[slug]/page.tsx` - Newsletter detail page
9. `hudson-life-dispatch-frontend/app/directory/page.tsx` - Business directory page

## Available Laravel API Endpoints

These endpoints already exist in `hudson-life-dispatch-backend/routes/api.php`:

### Blogs
- `GET /api/blogs` - List all blog posts
- `GET /api/blogs/{slug}` - Get single blog post

### Events
- `GET /api/events` - List all events
- `GET /api/events/{slug}` - Get single event
- `GET /api/events/featured` - Get featured events
- `GET /api/events/upcoming` - Get upcoming events

### Jobs
- `GET /api/jobs` - List all jobs
- `GET /api/jobs/{id}` - Get single job

### Newsletters
- `GET /api/newsletters` - List all newsletters
- `GET /api/newsletters/{id}` - Get newsletter by ID or slug
- `GET /api/newsletters/latest` - Get latest newsletter

### Towns
- `GET /api/towns` - List all towns

### Partners (for directory)
- `GET /api/partners` - List all partners
- `GET /api/partners/{slug}` - Get single partner

### Response Format
Laravel returns data in this format:
```json
{
  "data": [...array of items...],
  "success": true
}
```

Or for single items:
```json
{
  "data": {...single item...},
  "success": true
}
```

## Refactoring Pattern

### BEFORE (Current - Direct Database)
```typescript
import { db } from '@/lib/db'
import { blogPosts } from '@/lib/db/schema'
import { eq, desc } from 'drizzle-orm'

export default async function BlogPage() {
  const posts = await db
    .select()
    .from(blogPosts)
    .where(eq(blogPosts.status, 'published'))
    .orderBy(desc(blogPosts.publishedAt))
    .limit(50)
  
  return (
    <div>
      {posts.map(post => (
        <div key={post.id}>{post.title}</div>
      ))}
    </div>
  )
}
```

### AFTER (Target - API Call)
```typescript
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'

export default async function BlogPage() {
  const response = await fetch(`${API_URL}/api/blogs`, {
    next: { revalidate: 60 } // Cache for 60 seconds
  })
  
  if (!response.ok) {
    throw new Error('Failed to fetch blog posts')
  }
  
  const { data: posts } = await response.json()
  
  return (
    <div>
      {posts.map(post => (
        <div key={post.id}>{post.title}</div>
      ))}
    </div>
  )
}
```

## Step-by-Step Process for Each File

### Step 1: Read and Understand Current File
- Identify what database tables are being queried
- Note what filters/conditions are applied
- Understand what data fields are needed

### Step 2: Identify Laravel Endpoint
- Match the query to an available endpoint from the list above
- If endpoint doesn't exist, add it to "Blockers" list and skip this file

### Step 3: Remove Database Imports
Delete these lines:
```typescript
import { db } from '@/lib/db'
import { blogPosts, events, jobs, etc } from '@/lib/db/schema'
import { eq, desc, asc, and, or, etc } from 'drizzle-orm'
```

### Step 4: Add API Configuration
Add at the top of the component:
```typescript
const API_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000'
```

### Step 5: Replace Database Query with Fetch
Replace the `await db.select()...` with:
```typescript
const response = await fetch(`${API_URL}/api/[endpoint]`, {
  next: { revalidate: 60 } // Adjust cache time as needed
})

if (!response.ok) {
  throw new Error('Failed to fetch data')
}

const { data: variableName } = await response.json()
```

### Step 6: Update Variable Names if Needed
- Laravel returns `{ data: [...] }`
- Destructure to keep variable names consistent: `const { data: posts } = ...`

### Step 7: Test the Changes
After each file:
1. Save the file
2. Check the Next.js dev server for errors
3. Visit the page in browser
4. Verify data displays correctly

## Caching Strategy

Use these caching patterns:

### For Mostly Static Content (blogs, events)
```typescript
fetch(url, {
  next: { revalidate: 300 } // 5 minutes
})
```

### For Dynamic Content (jobs, real-time data)
```typescript
fetch(url, {
  cache: 'no-store' // Always fetch fresh
})
```

### For Very Static Content (categories, settings)
```typescript
fetch(url, {
  next: { revalidate: 3600 } // 1 hour
})
```

## Error Handling

Always add error handling:

```typescript
try {
  const response = await fetch(`${API_URL}/api/endpoint`)
  
  if (!response.ok) {
    throw new Error(`HTTP error! status: ${response.status}`)
  }
  
  const { data } = await response.json()
  return data
} catch (error) {
  console.error('Error fetching data:', error)
  // Handle appropriately - show error UI or return empty array
  return []
}
```

## Environment Variables

Ensure this is in `hudson-life-dispatch-frontend/.env.local`:

```bash
# Laravel Backend API URL
NEXT_PUBLIC_API_URL=http://localhost:8000
```

For production deployment, it should be:
```bash
NEXT_PUBLIC_API_URL=https://admin.hudsonlifedispatch.com
```

## Common Patterns

### List Pages (index pages)
```typescript
// Before: db.select().from(table).where(...).orderBy(...)
// After:
const response = await fetch(`${API_URL}/api/items`)
const { data: items } = await response.json()
```

### Detail Pages (single item by slug/id)
```typescript
// Before: db.select().from(table).where(eq(table.slug, slug))
// After:
const response = await fetch(`${API_URL}/api/items/${slug}`)
const { data: item } = await response.json()
```

### Search/Filter Pages
```typescript
// Before: db.select().from(table).where(like(table.field, '%term%'))
// After:
const params = new URLSearchParams({ search: searchTerm })
const response = await fetch(`${API_URL}/api/items?${params}`)
const { data: items } = await response.json()
```

## What NOT to Touch (Important!)

DO NOT modify these during this batch:
- Files in `app/api/admin/` - Admin routes (different batch)
- Files in `app/(authenticated)/admin/` - Admin UI pages (different batch)
- Files in `lib/db/` - Database config (will be removed later)
- `drizzle.config.ts` - Database config (will be removed later)

Only work on the 9 public-facing pages listed above.

## Completion Checklist

For each file you refactor, verify:

- [ ] All database imports removed (`@/lib/db`, `@/lib/db/schema`, `drizzle-orm`)
- [ ] API_URL constant added
- [ ] Database query replaced with fetch() call
- [ ] Response properly destructured to get data
- [ ] Error handling added (response.ok check)
- [ ] Appropriate caching strategy applied
- [ ] File saved without syntax errors
- [ ] Page loads in browser without errors
- [ ] Data displays correctly

## Blockers List

If you encounter a page that needs a Laravel endpoint that doesn't exist, add it here:

**Missing Endpoints:**
- (Add any missing endpoints here with description of what's needed)

## Next Steps After This Batch

After completing these 9 public pages, the next batches will be:

- **Batch 2:** API route proxies (`app/api/towns`, `app/api/partners`, etc.)
- **Batch 3:** Form submission routes (`app/api/stories/submit`, `app/api/submit-event`)
- **Batch 4:** Admin pages (requires architectural decision on Filament vs Next.js admin)

## Questions?

If you're unsure about anything:
1. Check the Laravel API endpoint in `hudson-life-dispatch-backend/routes/api.php`
2. Test the endpoint manually: `curl http://localhost:8000/api/blogs`
3. Look at similar refactored files for patterns
4. Document unclear items in "Blockers List" above

## Success Criteria

This batch is complete when:
1. All 9 public pages no longer import from `@/lib/db`
2. All 9 pages successfully fetch data from Laravel API
3. All pages render correctly in the browser
4. No console errors related to database access
5. The Neon database connection is no longer used by public pages

Good luck! Work methodically, one file at a time, and test as you go.

