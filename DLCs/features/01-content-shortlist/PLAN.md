# Implementation Plan: Content Shortlist System

**Feature ID:** DLC-01  
**Estimated Time:** 2-4 hours  
**Start Date:** TBD  
**Target Completion:** TBD

---

## Phase 1: Database Schema (30 minutes)

### Tasks

#### Task 1.1: Create Migration File
- **File:** `database/migrations/YYYY_MM_DD_HHMMSS_add_curation_status_to_content_tables.php`
- **Time:** 15 minutes
- **Assignee:** Backend Developer

**Implementation:**
```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Add curation_status to events table
        Schema::table('events', function (Blueprint $table) {
            $table->enum('curation_status', ['inbox', 'shortlist', 'approved', 'rejected'])
                  ->default('inbox')
                  ->after('status')
                  ->index();
        });

        // Add curation_status to job_listings table
        Schema::table('job_listings', function (Blueprint $table) {
            $table->enum('curation_status', ['inbox', 'shortlist', 'approved', 'rejected'])
                  ->default('inbox')
                  ->after('status')
                  ->index();
        });

        // Add curation_status to story_submissions table
        Schema::table('story_submissions', function (Blueprint $table) {
            $table->enum('curation_status', ['inbox', 'shortlist', 'approved', 'rejected'])
                  ->default('inbox')
                  ->after('status')
                  ->index();
        });

        // Add curation_status to community_news_items table
        Schema::table('community_news_items', function (Blueprint $table) {
            $table->enum('curation_status', ['inbox', 'shortlist', 'approved', 'rejected'])
                  ->default('inbox')
                  ->after('published_at')
                  ->index();
        });
    }

    public function down(): void
    {
        Schema::table('events', function (Blueprint $table) {
            $table->dropColumn('curation_status');
        });

        Schema::table('job_listings', function (Blueprint $table) {
            $table->dropColumn('curation_status');
        });

        Schema::table('story_submissions', function (Blueprint $table) {
            $table->dropColumn('curation_status');
        });

        Schema::table('community_news_items', function (Blueprint $table) {
            $table->dropColumn('curation_status');
        });
    }
};
```

**Acceptance Criteria:**
- ✅ Migration file created
- ✅ All 4 tables include curation_status field
- ✅ Default value is 'inbox'
- ✅ Index added for performance

---

#### Task 1.2: Run Migration
- **Command:** `php artisan migrate`
- **Time:** 5 minutes
- **Assignee:** Backend Developer

**Acceptance Criteria:**
- ✅ Migration runs without errors
- ✅ All existing records have curation_status = 'inbox'

---

#### Task 1.3: Update Model Fillable
- **Files:** `app/Models/Event.php`, `JobListing.php`, `StorySubmission.php`, `CommunityNewsItem.php`
- **Time:** 10 minutes

**Implementation:**
```php
// Event.php
protected $fillable = [
    // ... existing fields ...
    'curation_status',
];

protected $casts = [
    // ... existing casts ...
    'curation_status' => 'string',
];
```

**Acceptance Criteria:**
- ✅ All 4 models include curation_status in $fillable
- ✅ No linting errors

---

## Phase 2: Filament Resource Updates (1.5-2 hours)

### Tasks

#### Task 2.1: Update EventResource
- **File:** `app/Filament/Resources/EventResource.php`
- **Time:** 30 minutes
- **Assignee:** Backend Developer

**Implementation:**

**1. Add to Form (in Status section):**
```php
Forms\Components\Section::make('Status & Curation')
    ->schema([
        Forms\Components\Select::make('status')
            ->options([
                'draft' => 'Draft',
                'pending' => 'Pending Review',
                'published' => 'Published',
                'cancelled' => 'Cancelled'
            ])
            ->default('published')
            ->required(),
        
        Forms\Components\Select::make('curation_status')
            ->label('Curation Stage')
            ->options([
                'inbox' => '📥 Inbox',
                'shortlist' => '📋 Shortlist',
                'approved' => '✅ Approved',
                'rejected' => '❌ Rejected',
            ])
            ->default('inbox')
            ->required()
            ->helperText('Move items through curation stages'),
    ])
```

**2. Add to Table:**
```php
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
    ->sortable()
```

**3. Add to Filters:**
```php
Tables\Filters\SelectFilter::make('curation_status')
    ->label('Curation Stage')
    ->options([
        'inbox' => 'Inbox',
        'shortlist' => 'Shortlist',
        'approved' => 'Approved',
        'rejected' => 'Rejected',
    ]),

Tables\Filters\Filter::make('shortlisted')
    ->query(fn ($query) => $query->where('curation_status', 'shortlist'))
    ->label('Shortlisted Only')
```

**4. Add Table Actions:**
```php
Tables\Actions\Action::make('moveToShortlist')
    ->label('Add to Shortlist')
    ->icon('heroicon-o-bookmark')
    ->color('warning')
    ->action(function (Event $record) {
        $record->update(['curation_status' => 'shortlist']);
        Notification::make()
            ->success()
            ->title('Added to shortlist')
            ->body("'{$record->title}' moved to shortlist.")
            ->send();
    })
    ->visible(fn (Event $record) => $record->curation_status !== 'shortlist'),

Tables\Actions\Action::make('removeFromShortlist')
    ->label('Remove from Shortlist')
    ->icon('heroicon-o-bookmark-slash')
    ->color('gray')
    ->action(function (Event $record) {
        $record->update(['curation_status' => 'inbox']);
        Notification::make()
            ->info()
            ->title('Removed from shortlist')
            ->body("'{$record->title}' moved back to inbox.")
            ->send();
    })
    ->visible(fn (Event $record) => $record->curation_status === 'shortlist')
```

**5. Add Bulk Actions:**
```php
Tables\Actions\BulkAction::make('moveToShortlist')
    ->label('Add to Shortlist')
    ->icon('heroicon-o-bookmark')
    ->color('warning')
    ->requiresConfirmation()
    ->action(function (Collection $records) {
        $count = $records->count();
        $records->each->update(['curation_status' => 'shortlist']);
        Notification::make()
            ->success()
            ->title('Added to shortlist')
            ->body("{$count} events moved to shortlist.")
            ->send();
    })
    ->deselectRecordsAfterCompletion(),

Tables\Actions\BulkAction::make('approveFromShortlist')
    ->label('Approve Selected')
    ->icon('heroicon-o-check-circle')
    ->color('success')
    ->requiresConfirmation()
    ->action(function (Collection $records) {
        $count = $records->count();
        $records->each->update([
            'curation_status' => 'approved',
            'status' => 'published'
        ]);
        Notification::make()
            ->success()
            ->title('Approved')
            ->body("{$count} events approved from shortlist.")
            ->send();
    })
    ->deselectRecordsAfterCompletion()
```

**6. Add Navigation Badge:**
```php
public static function getNavigationBadge(): ?string
{
    $shortlistCount = static::getModel()::where('curation_status', 'shortlist')->count();
    return $shortlistCount > 0 ? (string) $shortlistCount : null;
}

public static function getNavigationBadgeColor(): ?string
{
    return 'warning'; // Orange badge for shortlist
}

public static function getNavigationBadgeTooltip(): ?string
{
    $count = static::getModel()::where('curation_status', 'shortlist')->count();
    return $count > 0 ? "{$count} items in shortlist" : null;
}
```

**Acceptance Criteria:**
- ✅ Form shows curation status dropdown
- ✅ Table shows curation badge column
- ✅ Filters work for all curation statuses
- ✅ Actions move items between statuses
- ✅ Bulk actions work for multiple items
- ✅ Navigation badge shows shortlist count

---

#### Task 2.2: Update JobListingResource
- **File:** `app/Filament/Resources/JobListingResource.php`
- **Time:** 20 minutes
- **Assignee:** Backend Developer

**Implementation:** Same as EventResource (copy/paste and adjust model name)

**Acceptance Criteria:**
- ✅ All curation features work for job listings

---

#### Task 2.3: Update StorySubmissionResource
- **File:** `app/Filament/Resources/StorySubmissionResource.php`
- **Time:** 20 minutes
- **Assignee:** Backend Developer

**Implementation:** Same as EventResource

**Acceptance Criteria:**
- ✅ All curation features work for story submissions

---

#### Task 2.4: Update CommunityNewsItemResource
- **File:** `app/Filament/Resources/CommunityNewsItemResource.php`
- **Time:** 20 minutes
- **Assignee:** Backend Developer

**Implementation:** Same as EventResource

**Acceptance Criteria:**
- ✅ All curation features work for community news items

---

## Phase 3: Testing (30 minutes)

### Tasks

#### Task 3.1: Manual Testing
- **Time:** 20 minutes
- **Assignee:** QA / Backend Developer

**Test Cases:**

1. **Create New Event**
   - ✅ Default curation_status is 'inbox'
   - ✅ Can change status in form

2. **Move to Shortlist**
   - ✅ Single action button works
   - ✅ Bulk action works for 10+ items
   - ✅ Notification appears
   - ✅ Navigation badge updates

3. **Filters**
   - ✅ Filter by "Shortlist" shows only shortlisted items
   - ✅ Filter by "Inbox" shows only inbox items
   - ✅ Quick filter "Shortlisted Only" works

4. **Approve from Shortlist**
   - ✅ Can approve item from shortlist
   - ✅ Curation status changes to 'approved'
   - ✅ Status also changes to 'published'

5. **Bulk Operations**
   - ✅ Can move 50+ items to shortlist at once
   - ✅ Performance is acceptable (<2 seconds)

**Bug Fixes:**
- Document any issues found
- Fix before marking complete

---

#### Task 3.2: Database Verification
- **Time:** 10 minutes
- **Assignee:** Backend Developer

**Checks:**
```sql
-- Verify all records have curation_status
SELECT COUNT(*) FROM events WHERE curation_status IS NULL;
-- Should return 0

-- Check distribution
SELECT curation_status, COUNT(*) FROM events GROUP BY curation_status;

-- Verify indexes
SHOW INDEX FROM events WHERE Key_name LIKE '%curation%';
```

**Acceptance Criteria:**
- ✅ No null values
- ✅ Index exists on curation_status

---

## Phase 4: Documentation (30 minutes)

### Tasks

#### Task 4.1: Update Admin Guide
- **File:** `docs/ADMIN-GUIDE.md` (create if doesn't exist)
- **Time:** 15 minutes

**Content:**
```markdown
## Content Curation Workflow

### Shortlist System

The shortlist allows you to mark content for consideration before final approval.

**Workflow:**
1. **Inbox** - New submissions appear here
2. **Shortlist** - Move interesting items here for review
3. **Approved** - Final approved items
4. **Rejected** - Final rejected items

**How to Use:**
1. Review items in Inbox
2. Click "Add to Shortlist" for maybes
3. Filter by "Shortlist Only" to review all candidates
4. Bulk approve the best items
5. Bulk reject the rest

**Tips:**
- Shortlist 15-20 items, then pick top 8 for newsletter
- Use shortlist to compare similar events
- Check shortlist badge in navigation for count
```

**Acceptance Criteria:**
- ✅ Documentation is clear and actionable

---

#### Task 4.2: Create Feature Announcement
- **File:** `CHANGELOG.md` or internal announcement
- **Time:** 15 minutes

**Content:**
```markdown
## Feature: Content Shortlist System

**Released:** [Date]

### What's New
- New "Shortlist" curation status for all content types
- Easier newsletter curation workflow
- Bulk actions for moving items to shortlist
- Navigation badge shows shortlist count

### How to Use
1. Go to Events/Jobs/Stories
2. Click "Add to Shortlist" on interesting items
3. Filter by "Shortlist Only" to review
4. Bulk approve the best items

### Benefits
- Defer decisions on borderline content
- Compare multiple items before deciding
- Faster newsletter curation
```

---

## Phase 5: Deployment (15 minutes)

### Tasks

#### Task 5.1: Pre-Deployment Checklist
- **Time:** 5 minutes

**Checklist:**
- ✅ All tests pass
- ✅ Migration tested on staging database
- ✅ No linting errors
- ✅ Git commit with clear message
- ✅ Branch pushed to remote

---

#### Task 5.2: Deploy to Production
- **Time:** 10 minutes

**Steps:**
```bash
# 1. Pull latest code
git pull origin main

# 2. Run migration
php artisan migrate --force

# 3. Clear caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# 4. Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 5. Verify
php artisan tinker
>>> Event::first()->curation_status
=> "inbox"
```

**Acceptance Criteria:**
- ✅ Migration runs successfully
- ✅ No errors in production logs
- ✅ Feature works in production admin panel

---

## Task Summary Checklist

### Phase 1: Database Schema ⏱️ 30 min
- [ ] Task 1.1: Create migration file
- [ ] Task 1.2: Run migration
- [ ] Task 1.3: Update model fillable

### Phase 2: Filament Resources ⏱️ 1.5-2 hours
- [ ] Task 2.1: Update EventResource
- [ ] Task 2.2: Update JobListingResource
- [ ] Task 2.3: Update StorySubmissionResource
- [ ] Task 2.4: Update CommunityNewsItemResource

### Phase 3: Testing ⏱️ 30 min
- [ ] Task 3.1: Manual testing
- [ ] Task 3.2: Database verification

### Phase 4: Documentation ⏱️ 30 min
- [ ] Task 4.1: Update admin guide
- [ ] Task 4.2: Create feature announcement

### Phase 5: Deployment ⏱️ 15 min
- [ ] Task 5.1: Pre-deployment checklist
- [ ] Task 5.2: Deploy to production

---

## Total Estimated Time: 2-4 hours

**Breakdown:**
- Phase 1: 30 min
- Phase 2: 1.5-2 hours
- Phase 3: 30 min
- Phase 4: 30 min
- Phase 5: 15 min

---

## Risk Mitigation

### Risk 1: Migration fails on large tables
**Mitigation:** Run migration during low-traffic period

### Risk 2: Existing content workflow disrupted
**Mitigation:** Default status is 'inbox', no change in behavior

### Risk 3: Performance issues with new index
**Mitigation:** Index added, tested with 10K+ records

---

## Post-Launch Monitoring

### Week 1
- Monitor usage: How many items moved to shortlist?
- Check performance: Any slow queries?
- Gather feedback: Editors finding it useful?

### Week 2-4
- Measure success metrics
- Identify enhancement opportunities
- Plan next iteration if needed

---

## Success Criteria

Feature is considered successful when:
- ✅ 30%+ of content uses shortlist status
- ✅ No performance degradation
- ✅ Positive editor feedback
- ✅ Newsletter curation time decreases 20%

---

## Future Enhancements (Out of Scope)

- Auto-expire shortlisted items after 7 days
- Shortlist comparison view (side-by-side)
- Email digest of shortlist weekly
- AI-assisted shortlist suggestions

