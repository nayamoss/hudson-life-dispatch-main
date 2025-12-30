# Admin Services Architecture - Explained Simply

## What Did We Just Build?

I created a **custom service layer** for your admin operations. Think of it like hiring a team of specialized workers, where each worker handles one specific job.

## The Team (Services)

### 1. **EventService** - The Event Manager
- **What it does**: Manages all event operations
- **Examples**:
  - Get all events with filters (search, status, town, category)
  - Create, update, delete events
  - Approve or reject submitted events
  - Toggle featured status
  - Get event statistics

### 2. **BusinessService** - The Business Manager
- **What it does**: Manages business directory listings
- **Examples**:
  - List all businesses with filters
  - Verify businesses
  - Handle business claims (when owners claim their listing)
  - Toggle premium status
  - Get business statistics

### 3. **RealEstateService** - The Jobs/Listings Manager  
- **What it does**: Manages job postings and real estate listings
- **Examples**:
  - Create, update, delete job listings
  - Mark jobs as expired or filled
  - Toggle featured jobs
  - Get job statistics

### 4. **NewsletterService** - The Newsletter Manager
- **What it does**: Manages newsletter campaigns and subscribers
- **Examples**:
  - Create and schedule newsletter campaigns
  - Manage subscribers
  - Export subscriber list to CSV
  - Get newsletter metrics (open rates, click rates)

### 5. **ScrapingService** - The Automation Manager
- **What it does**: Runs automated scraping scripts
- **Examples**:
  - Trigger event scraper
  - Trigger business discovery
  - Check scraper status
  - Get scraper logs

### 6. **TownService** - The Town Manager
- **What it does**: Manages town data and settings
- **Examples**:
  - List all towns
  - Activate/deactivate towns
  - Update town settings
  - Get town-specific statistics

### 7. **AnalyticsService** - The Data Analyst
- **What it does**: Provides analytics and insights
- **Examples**:
  - Dashboard overview statistics
  - Event metrics (views, clicks)
  - Business metrics
  - User growth data
  - Top content reports

### 8. **UserService** - The User Manager
- **What it does**: Manages users and permissions
- **Examples**:
  - List all users
  - Update user roles
  - Export users to CSV
  - Get user activity logs

## The Boss (AdminServiceManager)

The **AdminServiceManager** is like the boss who coordinates all these services. Instead of calling each service individually, you can call the manager:

```php
// Get the manager
$admin = app(AdminServiceManager::class);

// Access any service through the manager
$admin->events->getAll();
$admin->businesses->verify($id);
$admin->analytics->getOverview();
```

## How Do You Use This?

### Via API Endpoints

All these services are connected to API endpoints at:

```
http://admin.hudsonlifedispatch.com/api/admin/
```

**Examples:**

```bash
# Get all events
GET /api/admin/events

# Approve an event
POST /api/admin/events/{id}/approve

# Get analytics overview
GET /api/admin/analytics/overview

# Run event scraper
POST /api/admin/scraping/run-events

# Get business statistics
GET /api/admin/businesses/stats
```

### Via Code (in Laravel)

You can also use these services directly in your Laravel code:

```php
use App\Services\Admin\EventService;

class SomeController extends Controller
{
    public function __construct(
        private EventService $eventService
    ) {}

    public function myMethod()
    {
        // Get all published events
        $events = $this->eventService->getAll(['status' => 'published']);

        // Approve an event
        $event = $this->eventService->approve($eventId);

        // Get statistics
        $stats = $this->eventService->getStats();
    }
}
```

## Security

All admin routes are protected by:
1. **Authentication** - User must be logged in (Sanctum)
2. **Authorization** - User must have 'admin' role (IsAdmin middleware)

## File Structure

```
backend/
├── app/
│   ├── Models/                      ← Data models
│   │   ├── Event.php
│   │   ├── Business.php
│   │   ├── Job.php
│   │   ├── Town.php
│   │   └── MeetingVideo.php
│   │
│   ├── Services/Admin/              ← Business logic (THE MAGIC)
│   │   ├── AdminServiceManager.php  ← The boss
│   │   ├── EventService.php
│   │   ├── BusinessService.php
│   │   ├── RealEstateService.php
│   │   ├── NewsletterService.php
│   │   ├── ScrapingService.php
│   │   ├── TownService.php
│   │   ├── AnalyticsService.php
│   │   └── UserService.php
│   │
│   ├── Http/
│   │   ├── Controllers/Admin/       ← API endpoints
│   │   │   ├── AdminEventController.php
│   │   │   ├── AdminAnalyticsController.php
│   │   │   └── ... (8 total)
│   │   │
│   │   └── Middleware/
│   │       └── IsAdmin.php          ← Security check
│   │
│   └── Providers/
│       └── AppServiceProvider.php   ← Registers all services
│
└── routes/
    └── api.php                      ← All admin routes defined
```

## Key Concepts

### 1. Service Layer Pattern
Instead of putting business logic in controllers, we put it in **service classes**. This makes code:
- **Reusable** - Use the same logic in multiple places
- **Testable** - Easy to test business logic separately
- **Organized** - Each service handles one domain

### 2. Dependency Injection
Laravel automatically creates and injects these services for you:

```php
// Laravel automatically creates EventService and injects it
public function __construct(private EventService $eventService) {}
```

### 3. Single Responsibility
Each service has ONE job:
- EventService only deals with events
- BusinessService only deals with businesses
- etc.

## Quick Start Example

Let's say you want to approve 10 pending events:

**Step 1: Call the API**
```bash
POST /api/admin/events/bulk-approve
{
  "ids": ["event-id-1", "event-id-2", ..., "event-id-10"]
}
```

**Step 2: What Happens Behind The Scenes**
1. Request hits `AdminEventController`
2. Controller calls `EventService->bulkApprove($ids)`
3. EventService updates all events in database
4. Returns success response

**Step 3: Get Results**
```json
{
  "success": true,
  "message": "10 events approved"
}
```

## Common Tasks

### Get Dashboard Statistics
```bash
GET /api/admin/analytics/overview
```

### Approve a Pending Event
```bash
POST /api/admin/events/123/approve
```

### Run Event Scraper
```bash
POST /api/admin/scraping/run-events
```

### Export Subscribers
```bash
GET /api/admin/newsletters/subscribers/export
```

### Toggle Business Premium Status
```bash
POST /api/admin/businesses/456/toggle-premium
```

## Why Is This Better Than Filament?

### Filament (What You Had):
- ✅ Great for basic CRUD
- ❌ Limited for complex business logic
- ❌ Harder to customize
- ❌ Tied to the UI

### Custom Services (What We Built):
- ✅ Full control over business logic
- ✅ Reusable across different interfaces
- ✅ Can be called from API, CLI, cron jobs, etc.
- ✅ Easy to test
- ✅ Can coexist with Filament!

## Next Steps

1. **Add Authentication** - Get an API token from Laravel Sanctum
2. **Test Endpoints** - Use Postman or curl to test admin endpoints
3. **Build Admin Frontend** - Create a React/Vue admin panel that calls these APIs
4. **Add More Features** - Extend services with new methods as needed

## Questions?

- **Q: Can I still use Filament?**  
  A: Yes! These services work alongside Filament.

- **Q: How do I add a new admin feature?**  
  A: Add a method to the appropriate service, then add a route + controller method.

- **Q: Do I need to know Laravel?**  
  A: Basic understanding helps, but the structure is straightforward.

- **Q: Where are the admin controllers?**  
  A: `backend/app/Http/Controllers/Admin/`

- **Q: How do I see all available endpoints?**  
  A: Look at `backend/routes/api.php` starting at line 283

## Summary

You now have a **professional, scalable admin system** with:
- ✅ 8 specialized services
- ✅ 1 central manager
- ✅ Complete API endpoints
- ✅ Role-based access control
- ✅ Clean, organized code
- ✅ Easy to extend

**The services handle ALL the business logic, and controllers just coordinate between the API and services.**

