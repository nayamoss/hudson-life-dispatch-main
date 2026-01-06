# Implementation Plan: Quality Ratings System

**Feature ID:** DLC-02  
**Estimated Time:** 2-4 hours  
**Dependencies:** None (can implement standalone or after DLC-01)

---

## Phase 1: Database Schema (30 minutes)

### Task 1.1: Create Migration
- **File:** `database/migrations/YYYY_MM_DD_add_quality_rating_to_content_tables.php`
- **Time:** 20 minutes

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        // Events
        Schema::table('events', function (Blueprint $table) {
            $table->unsignedTinyInteger('quality_score')->nullable()->after('curation_status');
            $table->text('curation_notes')->nullable()->after('quality_score');
            $table->index('quality_score');
        });

        // Job Listings
        Schema::table('job_listings', function (Blueprint $table) {
            $table->unsignedTinyInteger('quality_score')->nullable()->after('status');
            $table->text('curation_notes')->nullable()->after('quality_score');
            $table->index('quality_score');
        });

        // Story Submissions
        Schema::table('story_submissions', function (Blueprint $table) {
            $table->unsignedTinyInteger('quality_score')->nullable()->after('status');
            $table->text('curation_notes')->nullable()->after('quality_score');
            $table->index('quality_score');
        });

        // Community News Items
        Schema::table('community_news_items', function (Blueprint $table) {
            $table->unsignedTinyInteger('quality_score')->nullable()->after('published_at');
            $table->text('curation_notes')->nullable()->after('quality_score');
            $table->index('quality_score');
        });
    }

    public function down(): void
    {
        Schema::table('events', fn (Blueprint $table) => 
            $table->dropColumn(['quality_score', 'curation_notes']));
        Schema::table('job_listings', fn (Blueprint $table) => 
            $table->dropColumn(['quality_score', 'curation_notes']));
        Schema::table('story_submissions', fn (Blueprint $table) => 
            $table->dropColumn(['quality_score', 'curation_notes']));
        Schema::table('community_news_items', fn (Blueprint $table) => 
            $table->dropColumn(['quality_score', 'curation_notes']));
    }
};
```

### Task 1.2: Update Models
- **Time:** 10 minutes

```php
// Add to all 4 models
protected $fillable = [
    // ...existing...
    'quality_score',
    'curation_notes',
];

protected $casts = [
    'quality_score' => 'integer',
];
```

**Checklist:**
- [ ] Migration created
- [ ] Migration runs successfully
- [ ] All 4 models updated
- [ ] No linting errors

---

## Phase 2: Filament Resources (1.5-2 hours)

### Task 2.1: Update EventResource
- **File:** `app/Filament/Resources/EventResource.php`
- **Time:** 30 minutes

**1. Add Form Section:**
```php
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
            ->searchable(false)
            ->helperText('Rate quality for newsletter inclusion'),
        
        Forms\Components\Textarea::make('curation_notes')
            ->label('Curation Notes (Internal)')
            ->placeholder('Why this rating? What makes it good/bad?')
            ->rows(3)
            ->helperText('Visible only to admins, helps remember decision rationale')
    ])
    ->collapsible()
    ->collapsed(fn ($record) => !$record || !$record->quality_score)
```

**2. Add Table Column:**
```php
Tables\Columns\TextColumn::make('quality_score')
    ->label('Quality')
    ->formatStateUsing(function ($state, $record) {
        if (!$state) {
            return '—';
        }
        $stars = str_repeat('⭐', (int)$state);
        $label = match((int)$state) {
            5 => ' Excellent',
            4 => ' Good',
            3 => ' Average',
            2 => ' Below Avg',
            1 => ' Poor',
            default => '',
        };
        return $stars . $label;
    })
    ->sortable()
    ->searchable()
    ->tooltip(fn ($record) => $record->curation_notes ?? 'No notes')
```

**3. Add Filters:**
```php
Tables\Filters\SelectFilter::make('quality_score')
    ->label('Quality Rating')
    ->options([
        '5' => '⭐⭐⭐⭐⭐ Excellent',
        '4' => '⭐⭐⭐⭐ Good',
        '3' => '⭐⭐⭐ Average',
        '2' => '⭐⭐ Below Average',
        '1' => '⭐ Poor',
    ]),

Tables\Filters\Filter::make('high_quality')
    ->query(fn ($query) => $query->whereIn('quality_score', [4, 5]))
    ->label('High Quality (4-5 stars)'),

Tables\Filters\Filter::make('unrated')
    ->query(fn ($query) => $query->whereNull('quality_score'))
    ->label('Unrated')
```

**4. Add Quick Rate Actions:**
```php
Tables\Actions\Action::make('quickRate5')
    ->label('5⭐')
    ->icon('heroicon-o-star')
    ->color('success')
    ->action(function (Event $record) {
        $record->update(['quality_score' => 5]);
        Notification::make()
            ->success()
            ->title('Rated 5 stars')
            ->send();
    })
    ->visible(fn ($record) => $record->quality_score !== 5),

Tables\Actions\Action::make('quickRate4')
    ->label('4⭐')
    ->icon('heroicon-o-star')
    ->color('success')
    ->action(function (Event $record) {
        $record->update(['quality_score' => 4]);
        Notification::make()->success()->title('Rated 4 stars')->send();
    })
    ->visible(fn ($record) => $record->quality_score !== 4),

Tables\Actions\Action::make('quickRate3')
    ->label('3⭐')
    ->icon('heroicon-o-star')
    ->color('warning')
    ->action(function (Event $record) {
        $record->update(['quality_score' => 3]);
        Notification::make()->info()->title('Rated 3 stars')->send();
    })
    ->visible(fn ($record) => $record->quality_score !== 3)
```

**5. Add Bulk Rating:**
```php
Tables\Actions\BulkAction::make('bulkRate')
    ->label('Rate Selected')
    ->icon('heroicon-o-star')
    ->form([
        Forms\Components\Select::make('quality_score')
            ->label('Quality Rating')
            ->options([
                5 => '⭐⭐⭐⭐⭐ Excellent',
                4 => '⭐⭐⭐⭐ Good',
                3 => '⭐⭐⭐ Average',
                2 => '⭐⭐ Below Average',
                1 => '⭐ Poor',
            ])
            ->required(),
        
        Forms\Components\Textarea::make('curation_notes')
            ->label('Notes (optional)')
            ->rows(2)
    ])
    ->action(function (Collection $records, array $data) {
        $records->each->update([
            'quality_score' => $data['quality_score'],
            'curation_notes' => $data['curation_notes'] ?? null,
        ]);
        
        $count = $records->count();
        Notification::make()
            ->success()
            ->title('Rated ' . $count . ' events')
            ->send();
    })
    ->deselectRecordsAfterCompletion()
```

**Checklist:**
- [ ] Form section added
- [ ] Table column shows stars
- [ ] Filters work correctly
- [ ] Quick rate actions work
- [ ] Bulk rating works

---

### Tasks 2.2-2.4: Update Other Resources
**Repeat for:**
- JobListingResource (20 min)
- StorySubmissionResource (20 min)
- CommunityNewsItemResource (20 min)

Same implementation, just adjust model names.

---

## Phase 3: Analytics Widget (Optional, 1 hour)

### Task 3.1: Create Quality Analytics Widget
- **File:** `app/Filament/Widgets/QualityAnalyticsWidget.php`
- **Time:** 40 minutes

```php
<?php

namespace App\Filament\Widgets;

use App\Models\Event;
use App\Models\JobListing;
use App\Models\StorySubmission;
use Filament\Widgets\StatsOverviewWidget as BaseWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Facades\DB;

class QualityAnalyticsWidget extends BaseWidget
{
    protected function getStats(): array
    {
        // Average ratings
        $avgEventRating = Event::whereNotNull('quality_score')->avg('quality_score');
        $avgJobRating = JobListing::whereNotNull('quality_score')->avg('quality_score');
        
        // High quality count
        $highQualityCount = Event::whereIn('quality_score', [4, 5])->count();
        
        // Unrated count
        $unratedCount = Event::where('status', 'pending')
            ->whereNull('quality_score')
            ->count();

        return [
            Stat::make('Avg Event Rating', number_format($avgEventRating, 2) . ' ⭐')
                ->description('All rated events')
                ->descriptionIcon('heroicon-o-star')
                ->color('success'),
            
            Stat::make('High Quality Events', $highQualityCount)
                ->description('4-5 star events')
                ->descriptionIcon('heroicon-o-sparkles')
                ->color('warning'),
            
            Stat::make('Unrated Events', $unratedCount)
                ->description('Pending events without rating')
                ->descriptionIcon('heroicon-o-question-mark-circle')
                ->color('danger'),
        ];
    }
}
```

### Task 3.2: Register Widget
- **File:** `app/Providers/Filament/AdminPanelProvider.php`
- **Time:** 5 minutes

```php
->widgets([
    // ...existing widgets...
    Widgets\QualityAnalyticsWidget::class,
])
```

**Checklist:**
- [ ] Widget created
- [ ] Widget shows accurate stats
- [ ] Widget registered in admin panel

---

## Phase 4: Testing (30 minutes)

### Task 4.1: Manual Testing
- **Time:** 20 minutes

**Test Cases:**
1. **Rate New Event**
   - [ ] Can rate 1-5 stars
   - [ ] Can add curation notes
   - [ ] Stars appear in table

2. **Quick Rate Actions**
   - [ ] Quick rate buttons work
   - [ ] Notification appears
   - [ ] Table updates immediately

3. **Filtering**
   - [ ] Filter by specific rating works
   - [ ] "High Quality" filter shows 4-5 stars only
   - [ ] "Unrated" filter shows null values

4. **Sorting**
   - [ ] Sort by quality_score works
   - [ ] Highest rated appears first
   - [ ] Unrated items appear last

5. **Bulk Rating**
   - [ ] Can rate 10+ items at once
   - [ ] All items updated correctly
   - [ ] Performance acceptable

### Task 4.2: Edge Cases
- **Time:** 10 minutes

**Test:**
- [ ] Rating saves null value correctly
- [ ] Can change rating after initial rating
- [ ] Curation notes handle 1000+ characters
- [ ] SQL injection protection on notes field
- [ ] Emoji in notes works correctly

---

## Phase 5: Documentation (20 minutes)

### Task 5.1: Update Admin Guide
**Content:**
```markdown
## Quality Rating System

### How to Rate Content

1. Open any content item (Event, Job, Story, etc.)
2. Scroll to "Quality Assessment" section
3. Select 1-5 stars:
   - ⭐⭐⭐⭐⭐ Excellent - Must include
   - ⭐⭐⭐⭐ Good - Strong candidate
   - ⭐⭐⭐ Average - Maybe
   - ⭐⭐ Below Average - Probably not
   - ⭐ Poor - Do not include
4. Add notes explaining your rating (optional)
5. Save

### Quick Rating
- Click star buttons in table row for instant rating
- Bulk rate multiple items at once

### Using Ratings
- Filter by "High Quality" to see 4-5 star items
- Sort by Quality to prioritize best content
- Check Analytics widget for quality trends
```

**Checklist:**
- [ ] Documentation written
- [ ] Screenshots added
- [ ] Published to team wiki

---

## Phase 6: Deployment (15 minutes)

### Task 6.1: Deploy
**Steps:**
```bash
# Run migration
php artisan migrate --force

# Clear caches
php artisan cache:clear
php artisan config:clear

# Verify
php artisan tinker
>>> Event::first()->quality_score = 5
>>> Event::first()->save()
>>> Event::first()->quality_score
=> 5
```

**Checklist:**
- [ ] Migration successful
- [ ] No errors in logs
- [ ] Feature works in production

---

## Task Summary

### Phase 1: Database (30 min)
- [ ] Task 1.1: Create migration
- [ ] Task 1.2: Update models

### Phase 2: Resources (1.5-2 hours)
- [ ] Task 2.1: EventResource
- [ ] Task 2.2: JobListingResource
- [ ] Task 2.3: StorySubmissionResource
- [ ] Task 2.4: CommunityNewsItemResource

### Phase 3: Analytics (1 hour, optional)
- [ ] Task 3.1: Quality analytics widget
- [ ] Task 3.2: Register widget

### Phase 4: Testing (30 min)
- [ ] Task 4.1: Manual testing
- [ ] Task 4.2: Edge cases

### Phase 5: Documentation (20 min)
- [ ] Task 5.1: Admin guide

### Phase 6: Deployment (15 min)
- [ ] Task 6.1: Deploy

---

## Total Time: 2-4 hours
(3-5 hours with analytics widget)

---

## Success Metrics

**Week 1:**
- 50%+ of reviewed content has rating
- No performance issues
- Positive editor feedback

**Week 4:**
- 80%+ of approved content has rating
- Average newsletter rating is 4+ stars
- Quality trends visible in analytics

---

## Future Enhancements

- AI-suggested ratings
- Rating history/changes log
- Multi-editor consensus ratings
- Source quality rankings
- Automated quality scoring

