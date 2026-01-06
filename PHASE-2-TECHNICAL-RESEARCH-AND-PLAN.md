# Phase 2: Technical Research & Implementation Plan
## Ad Inventory Calendar - Filament Admin Interface

**Date**: January 5, 2026  
**Tech Stack**: Laravel 11 + Filament 3 + Livewire 3 + Alpine.js + SQLite/MySQL  
**Research Goal**: Determine best approach for building calendar UI in Filament

---

## 🔍 Research Summary

After analyzing available options for calendar implementations in the Laravel/Filament ecosystem, here are the viable approaches ranked by recommendation:

---

## Option 1: Custom Filament Page with FullCalendar.js ⭐ **RECOMMENDED**

### Why This Approach?
- **Most Control**: Complete customization of calendar behavior
- **Best Integration**: Works seamlessly with Filament's theming and Livewire
- **Industry Standard**: FullCalendar is the most mature calendar library
- **Drag & Drop**: Built-in drag-and-drop support
- **Multiple Views**: Day, week, month views out of the box

### Technical Stack
```
Filament Custom Page
  ├── Blade View (calendar.blade.php)
  ├── Livewire Component (CalendarWidget.php)
  ├── FullCalendar.js (via CDN or npm)
  ├── Alpine.js (for interactions)
  └── Tailwind CSS (styling)
```

### Implementation Plan

#### Step 1: Install FullCalendar (if using npm)
```bash
npm install @fullcalendar/core @fullcalendar/daygrid @fullcalendar/interaction @fullcalendar/timegrid
```

Or use CDN in blade template:
```html
<link href='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.9/index.global.min.css' rel='stylesheet' />
<script src='https://cdn.jsdelivr.net/npm/fullcalendar@6.1.9/index.global.min.js'></script>
```

#### Step 2: Create Filament Custom Page
```php
// app/Filament/Pages/AdInventoryCalendar.php
namespace App\Filament\Pages;

use Filament\Pages\Page;
use App\Models\AdSlot;

class AdInventoryCalendar extends Page
{
    protected static ?string $navigationIcon = 'heroicon-o-calendar';
    protected static string $view = 'filament.pages.ad-inventory-calendar';
    protected static ?string $navigationLabel = 'Ad Calendar';
    protected static ?int $navigationSort = 2;
    
    public function getSlots()
    {
        return AdSlot::with(['publication', 'placement', 'sponsor'])
            ->upcoming()
            ->get()
            ->map(fn($slot) => [
                'id' => $slot->id,
                'title' => $slot->placement->name ?? 'Ad Slot',
                'start' => $slot->slot_date->toIso8601String(),
                'backgroundColor' => $this->getColorForStatus($slot->status),
                'borderColor' => $this->getColorForStatus($slot->status),
                'extendedProps' => [
                    'status' => $slot->status,
                    'publication' => $slot->publication->name,
                    'placement' => $slot->placement->name,
                    'sponsor' => $slot->sponsor->company_name ?? 'Available',
                    'price' => $slot->getFormattedPrice(),
                ],
            ]);
    }
    
    protected function getColorForStatus(string $status): string
    {
        return match($status) {
            'available' => '#10b981',     // green
            'reserved' => '#f59e0b',      // amber
            'booked' => '#3b82f6',        // blue
            'in_production' => '#8b5cf6', // purple
            'ready' => '#06b6d4',         // cyan
            'published' => '#6366f1',     // indigo
            'completed' => '#64748b',     // slate
            'cancelled' => '#ef4444',     // red
            'blocked' => '#9ca3af',       // gray
            default => '#6b7280',
        };
    }
}
```

#### Step 3: Create Blade View
```blade
{{-- resources/views/filament/pages/ad-inventory-calendar.blade.php --}}
<x-filament-panels::page>
    <div class="space-y-4">
        {{-- Filters --}}
        <div class="flex gap-4 items-center">
            <x-filament::input.wrapper>
                <x-filament::input.select wire:model.live="selectedPublication">
                    <option value="">All Publications</option>
                    @foreach($publications as $pub)
                        <option value="{{ $pub->id }}">{{ $pub->name }}</option>
                    @endforeach
                </x-filament::input.select>
            </x-filament::input.wrapper>
            
            {{-- Status Legend --}}
            <div class="flex gap-2 ml-auto">
                <span class="flex items-center gap-1 text-sm">
                    <span class="w-3 h-3 rounded-full bg-green-500"></span>
                    Available
                </span>
                <span class="flex items-center gap-1 text-sm">
                    <span class="w-3 h-3 rounded-full bg-blue-500"></span>
                    Booked
                </span>
                <span class="flex items-center gap-1 text-sm">
                    <span class="w-3 h-3 rounded-full bg-slate-500"></span>
                    Completed
                </span>
            </div>
        </div>
        
        {{-- Calendar Container --}}
        <div class="bg-white dark:bg-gray-800 rounded-lg shadow p-4">
            <div id="calendar" wire:ignore></div>
        </div>
    </div>
    
    @push('scripts')
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var calendarEl = document.getElementById('calendar');
            
            var calendar = new FullCalendar.Calendar(calendarEl, {
                initialView: 'dayGridMonth',
                headerToolbar: {
                    left: 'prev,next today',
                    center: 'title',
                    right: 'dayGridMonth,timeGridWeek,timeGridDay'
                },
                editable: true,
                droppable: true,
                events: @json($this->getSlots()),
                
                // Event click handler
                eventClick: function(info) {
                    @this.call('openSlotDetails', info.event.id);
                },
                
                // Drag and drop handler
                eventDrop: function(info) {
                    @this.call('updateSlotDate', {
                        slotId: info.event.id,
                        newDate: info.event.start.toISOString()
                    });
                },
                
                // Styling
                eventContent: function(arg) {
                    return {
                        html: `
                            <div class="fc-event-main-frame">
                                <div class="fc-event-title-container">
                                    <div class="fc-event-title fc-sticky">
                                        ${arg.event.title}
                                    </div>
                                </div>
                                <div class="text-xs opacity-75">
                                    ${arg.event.extendedProps.publication}
                                </div>
                            </div>
                        `
                    };
                }
            });
            
            calendar.render();
            
            // Listen for Livewire updates
            Livewire.on('refreshCalendar', () => {
                calendar.refetchEvents();
            });
        });
    </script>
    @endpush
</x-filament-panels::page>
```

#### Step 4: Add Livewire Actions
```php
// In AdInventoryCalendar.php - add these methods

public function openSlotDetails($slotId)
{
    $this->dispatch('open-modal', id: 'slot-details-modal', parameters: ['slotId' => $slotId]);
}

public function updateSlotDate($data)
{
    $slot = AdSlot::find($data['slotId']);
    if ($slot && $slot->isAvailable()) {
        $slot->update(['slot_date' => $data['newDate']]);
        $this->dispatch('refreshCalendar');
        
        Notification::make()
            ->title('Slot date updated')
            ->success()
            ->send();
    }
}
```

---

## Option 2: Filament Table with Custom Styling ⭐ **EASY START**

### Why This Approach?
- **Quick to Implement**: Use existing Filament Table features
- **No JavaScript Required**: Pure Livewire/PHP
- **Filament Native**: Feels integrated with admin panel
- **Good for List View**: Better for bulk operations

### Implementation

```php
// app/Filament/Resources/AdSlotResource.php
public static function table(Table $table): Table
{
    return $table
        ->columns([
            TextColumn::make('slot_date')
                ->date('M j, Y')
                ->sortable()
                ->searchable(),
                
            TextColumn::make('publication.name')
                ->sortable()
                ->searchable(),
                
            TextColumn::make('placement.name')
                ->sortable(),
                
            BadgeColumn::make('status')
                ->colors([
                    'success' => 'available',
                    'warning' => 'reserved',
                    'primary' => 'booked',
                    'info' => 'in_production',
                    'gray' => 'completed',
                    'danger' => 'cancelled',
                ])
                ->icons([
                    'heroicon-o-check-circle' => 'available',
                    'heroicon-o-clock' => 'reserved',
                    'heroicon-o-bookmark' => 'booked',
                    'heroicon-o-cog' => 'in_production',
                    'heroicon-o-check-badge' => 'completed',
                    'heroicon-o-x-circle' => 'cancelled',
                ]),
                
            TextColumn::make('sponsor.company_name')
                ->default('Available')
                ->placeholder('Available'),
                
            TextColumn::make('price')
                ->money('usd')
                ->sortable(),
                
            TextColumn::make('copy_due_date')
                ->date('M j')
                ->color(fn($record) => $record->isCopyOverdue() ? 'danger' : null)
                ->icon(fn($record) => $record->isCopyOverdue() ? 'heroicon-o-exclamation-triangle' : null),
        ])
        ->filters([
            SelectFilter::make('publication')
                ->relationship('publication', 'name'),
                
            SelectFilter::make('status')
                ->options([
                    'available' => 'Available',
                    'reserved' => 'Reserved',
                    'booked' => 'Booked',
                    'completed' => 'Completed',
                ]),
                
            Filter::make('upcoming')
                ->query(fn($query) => $query->upcoming())
                ->label('Upcoming Only'),
        ])
        ->actions([
            Tables\Actions\EditAction::make(),
            
            Action::make('book')
                ->icon('heroicon-o-bookmark')
                ->color('primary')
                ->visible(fn($record) => $record->isAvailable())
                ->form([
                    Select::make('sponsor_profile_id')
                        ->relationship('sponsor', 'company_name')
                        ->required()
                        ->searchable(),
                    Select::make('ad_id')
                        ->relationship('ad', 'title')
                        ->required()
                        ->searchable(),
                ])
                ->action(function($record, array $data) {
                    $record->book($data['ad_id'], $data['sponsor_profile_id']);
                    Notification::make()->success()->title('Slot booked')->send();
                }),
        ])
        ->bulkActions([
            Tables\Actions\BulkActionGroup::make([
                Tables\Actions\DeleteBulkAction::make(),
                
                BulkAction::make('changeStatus')
                    ->label('Change Status')
                    ->icon('heroicon-o-arrow-path')
                    ->form([
                        Select::make('status')
                            ->options([
                                'available' => 'Available',
                                'blocked' => 'Blocked',
                                'cancelled' => 'Cancelled',
                            ])
                            ->required(),
                    ])
                    ->action(function(Collection $records, array $data) {
                        $records->each->update(['status' => $data['status']]);
                        Notification::make()->success()->title('Status updated')->send();
                    }),
            ]),
        ])
        ->defaultSort('slot_date', 'asc');
}
```

---

## Option 3: Third-Party Filament Calendar Package

### Available Packages (Research Results)

1. **saade/filament-fullcalendar**
   - Status: Exists but limited documentation
   - Pro: Ready-made solution
   - Con: May not fit exact needs, dependency risk

2. **guava/calendar** 
   - Status: Limited information available
   - Not widely adopted in Filament community

3. **Custom Livewire Calendar Components**
   - **asantibanez/livewire-calendar**
   - Pro: Livewire-first, lightweight
   - Con: Requires customization for Filament styling

### Recommendation: **Build Custom (Option 1)**
Third-party packages for Filament calendar are not mature enough yet. Building custom gives you full control.

---

## Option 4: Separate Next.js Calendar (Frontend)

### Implementation Approach
Build the calendar view in your Next.js frontend instead of Filament admin.

### Pros:
- Better UX for sponsors (public-facing)
- Modern React calendar libraries (react-big-calendar, FullCalendar React)
- Separation of concerns (admin vs public)

### Cons:
- Requires API endpoints
- Two codebases to maintain

### When to Use:
- For **sponsor portal** (Phase 4)
- Keep Filament for **admin management**

---

## 🎯 Final Recommendation: Hybrid Approach

### Phase 2A: Admin Interface (Filament)
**Use Option 2 (Filament Table) FIRST**
- Quick to implement
- Get feedback from team
- Validates data models

**Then Add Option 1 (FullCalendar) for Visual View**
- Custom page for calendar visualization
- Keep table view for bulk operations
- Two views: Calendar + Table

### Phase 2B: Sponsor Portal (Next.js)
**Use react-big-calendar or FullCalendar React**
- Public-facing booking interface
- Better UX for sponsors
- Mobile-responsive

---

## 📋 Implementation Checklist

### Week 1: Table View (Quick Win)
- [ ] Create `AdSlotResource` with table
- [ ] Add color-coded status badges
- [ ] Implement filters (publication, status, date)
- [ ] Add quick actions (book, cancel, reschedule)
- [ ] Bulk operations (status change, delete)

### Week 2: Calendar View
- [ ] Create `AdInventoryCalendar` custom page
- [ ] Integrate FullCalendar.js
- [ ] Wire up Livewire events
- [ ] Add drag-and-drop
- [ ] Implement click-to-edit modal

### Week 3: Supporting Resources
- [ ] Create `PublicationResource`
- [ ] Create `TaskTemplateResource`
- [ ] Create `BlockedDateResource`

### Week 4: Widgets & Dashboard
- [ ] Utilization rate widget
- [ ] Revenue by publication chart
- [ ] Upcoming deadlines widget
- [ ] Quick booking action

---

## 🔧 Code Patterns for Common Features

### 1. Color-Coded Status Badges
```php
BadgeColumn::make('status')
    ->getStateUsing(fn($record) => ucfirst($record->status))
    ->color(fn($state) => match($state) {
        'Available' => 'success',
        'Reserved' => 'warning',
        'Booked' => 'primary',
        'Completed' => 'gray',
        'Cancelled' => 'danger',
        default => 'secondary',
    })
```

### 2. Quick Actions in Tables
```php
Action::make('quick_book')
    ->slideOver()
    ->form([
        // form fields
    ])
    ->action(function($record, $data) {
        // action logic
    })
```

### 3. Filters with Relationships
```php
SelectFilter::make('publication')
    ->relationship('publication', 'name')
    ->preload()
    ->searchable()
```

### 4. Custom Widgets
```php
// app/Filament/Widgets/SlotUtilizationWidget.php
class SlotUtilizationWidget extends ChartWidget
{
    protected function getData(): array
    {
        $publications = Publication::with('adSlots')->get();
        
        return [
            'datasets' => [[
                'label' => 'Utilization Rate',
                'data' => $publications->map(fn($p) => 
                    $p->getUtilizationRate(now()->startOfMonth(), now()->endOfMonth())
                ),
            ]],
            'labels' => $publications->pluck('name'),
        ];
    }
}
```

---

## 📚 Resources & Documentation

### FullCalendar
- Docs: https://fullcalendar.io/docs
- Examples: https://fullcalendar.io/docs/initialize-globals
- Livewire Integration: Use `wire:ignore` on calendar div

### Filament
- Custom Pages: https://filamentphp.com/docs/3.x/panels/pages
- Tables: https://filamentphp.com/docs/3.x/tables/getting-started
- Actions: https://filamentphp.com/docs/3.x/actions/overview
- Widgets: https://filamentphp.com/docs/3.x/widgets/overview

### Livewire
- Events: https://livewire.laravel.com/docs/events
- JavaScript: https://livewire.laravel.com/docs/javascript

---

## 🎨 UI/UX Considerations

### Color Scheme for Statuses
```php
'available'     => 'green-500',   // Open for booking
'reserved'      => 'amber-500',   // Temporarily held
'booked'        => 'blue-500',    // Confirmed
'in_production' => 'purple-500',  // Being created
'ready'         => 'cyan-500',    // Ready to publish
'published'     => 'indigo-500',  // Live
'completed'     => 'slate-500',   // Finished
'cancelled'     => 'red-500',     // Cancelled
'blocked'       => 'gray-400',    // Not available
```

### Icons (Heroicons)
- Available: `check-circle`
- Reserved: `clock`
- Booked: `bookmark`
- In Production: `cog`
- Ready: `check-badge`
- Published: `rocket-launch`
- Completed: `check`
- Cancelled: `x-circle`
- Blocked: `no-symbol`

---

## ⚡ Performance Considerations

### 1. Eager Loading
```php
AdSlot::with(['publication', 'placement', 'sponsor', 'ad'])
    ->upcoming()
    ->get();
```

### 2. Caching Calendar Data
```php
Cache::remember('calendar-slots-' . $month, 3600, function() {
    return $this->getSlots();
});
```

### 3. Pagination for Table View
```php
protected static ?int $recordsPerPage = 50;
```

### 4. Indexes (Already in Migrations ✅)
- `ad_slots`: indexed on `slot_date`, `status`, `publication_id`

---

## 🧪 Testing Approach

### Feature Tests
```php
it('can book an available slot', function() {
    $slot = AdSlot::factory()->available()->create();
    $ad = Ad::factory()->create();
    $sponsor = SponsorProfile::factory()->create();
    
    $slot->book($ad->id, $sponsor->id);
    
    expect($slot->fresh())
        ->status->toBe('booked')
        ->ad_id->toBe($ad->id);
});
```

### Browser Tests (Pest + Laravel Dusk)
```php
it('displays calendar with slots', function() {
    $this->browse(function(Browser $browser) {
        $browser->loginAs(User::factory()->admin()->create())
            ->visit('/admin/ad-calendar')
            ->assertSee('Ad Inventory Calendar')
            ->assertPresent('#calendar')
            ->assertSee('January 2026');
    });
});
```

---

## 🚀 Next Steps

1. **Start with Table View** (easiest, fastest value)
2. **Add Calendar View** (visual management)
3. **Build Supporting Resources** (publications, templates)
4. **Create Widgets** (analytics, dashboards)
5. **Polish UX** (notifications, quick actions)

**Estimated Timeline**: 3-4 weeks for complete Phase 2

---

**Status**: Research Complete - Ready to Implement  
**Recommended Path**: Hybrid (Table + FullCalendar Custom Page)  
**Tech Stack Confirmed**: Laravel + Filament 3 + FullCalendar.js + Livewire 3

