# Implementation Plan: Partner Newsletter Cross-Promotions

**Feature ID:** DLC-04  
**Estimated Time:** 3-5 hours  
**Dependencies:** Newsletter system, Analytics tracking

---

## Phase 1: Database Schema (45 minutes)

### Task 1.1: Create Partner Newsletters Table
- **File:** `database/migrations/YYYY_MM_DD_create_partner_newsletters_table.php`
- **Time:** 15 minutes

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('partner_newsletters', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('slug')->unique();
            $table->string('publisher_name')->nullable();
            $table->string('contact_email')->nullable();
            $table->string('website_url', 500)->nullable();
            $table->string('subscribe_url', 500);
            $table->text('description')->nullable();
            $table->text('audience_focus')->nullable();
            $table->string('geographic_focus')->nullable();
            $table->unsignedInteger('subscriber_count')->nullable();
            $table->enum('frequency', ['daily', 'weekly', 'biweekly', 'monthly'])->default('weekly');
            $table->enum('status', ['prospective', 'active', 'paused', 'ended'])->default('prospective');
            $table->text('agreement_terms')->nullable();
            $table->string('logo_url', 500)->nullable();
            $table->text('notes')->nullable();
            $table->timestamp('activated_at')->nullable();
            $table->timestamps();

            $table->index('status');
            $table->index('slug');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('partner_newsletters');
    }
};
```

### Task 1.2: Create Cross Promotions Table
- **File:** `database/migrations/YYYY_MM_DD_create_cross_promotions_table.php`
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
        Schema::create('cross_promotions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('partner_newsletter_id')->constrained()->onDelete('cascade');
            $table->foreignId('newsletter_edition_id')->nullable()->constrained('newsletters')->onDelete('set null');
            $table->date('scheduled_date');
            $table->enum('promotion_type', ['mention', 'feature', 'full_ad'])->default('feature');
            $table->string('headline')->nullable();
            $table->text('content')->nullable();
            $table->string('cta_text', 100)->nullable();
            $table->string('tracking_link', 500)->nullable();
            $table->string('image_url', 500)->nullable();
            $table->enum('position', ['header', 'mid', 'footer'])->default('mid');
            $table->enum('status', ['draft', 'scheduled', 'sent', 'cancelled'])->default('draft');
            $table->timestamp('sent_at')->nullable();
            $table->unsignedInteger('clicks')->default(0);
            $table->unsignedInteger('conversions')->default(0);
            $table->timestamps();

            $table->index('scheduled_date');
            $table->index('status');
            $table->index('partner_newsletter_id');
            $table->index(['partner_newsletter_id', 'scheduled_date']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('cross_promotions');
    }
};
```

### Task 1.3: Create Partner Clicks Table
- **File:** `database/migrations/YYYY_MM_DD_create_partner_clicks_table.php`
- **Time:** 10 minutes

```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('partner_clicks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('cross_promotion_id')->constrained()->onDelete('cascade');
            $table->foreignId('subscriber_id')->nullable()->constrained()->onDelete('set null');
            $table->timestamp('clicked_at');
            $table->string('ip_address', 45)->nullable();
            $table->text('user_agent')->nullable();
            $table->timestamp('converted_at')->nullable();
            $table->timestamps();

            $table->index('clicked_at');
            $table->index('converted_at');
            $table->index(['cross_promotion_id', 'clicked_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('partner_clicks');
    }
};
```

**Checklist:**
- [ ] All 3 migrations created
- [ ] Migrations run successfully
- [ ] Foreign keys work correctly

---

## Phase 2: Models (30 minutes)

### Task 2.1: Create PartnerNewsletter Model
- **File:** `app/Models/PartnerNewsletter.php`
- **Time:** 15 minutes

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Str;

class PartnerNewsletter extends Model
{
    protected $fillable = [
        'name',
        'slug',
        'publisher_name',
        'contact_email',
        'website_url',
        'subscribe_url',
        'description',
        'audience_focus',
        'geographic_focus',
        'subscriber_count',
        'frequency',
        'status',
        'agreement_terms',
        'logo_url',
        'notes',
        'activated_at',
    ];

    protected $casts = [
        'subscriber_count' => 'integer',
        'activated_at' => 'datetime',
    ];

    protected static function boot()
    {
        parent::boot();
        
        static::creating(function ($partner) {
            if (empty($partner->slug)) {
                $partner->slug = Str::slug($partner->name);
            }
        });
    }

    public function crossPromotions(): HasMany
    {
        return $this->hasMany(CrossPromotion::class);
    }

    public function scopeActive($query)
    {
        return $query->where('status', 'active');
    }

    public function scopeProspective($query)
    {
        return $query->where('status', 'prospective');
    }

    public function getTotalClicksAttribute(): int
    {
        return $this->crossPromotions()->sum('clicks');
    }

    public function getTotalConversionsAttribute(): int
    {
        return $this->crossPromotions()->sum('conversions');
    }

    public function getAverageCtrAttribute(): float
    {
        $promotions = $this->crossPromotions()
            ->where('status', 'sent')
            ->get();
        
        if ($promotions->isEmpty()) {
            return 0.0;
        }

        $totalClicks = $promotions->sum('clicks');
        $totalImpressions = $promotions->count() * 1000; // Assuming ~1K subscribers per send
        
        return $totalImpressions > 0 ? ($totalClicks / $totalImpressions) * 100 : 0.0;
    }

    public function getConversionRateAttribute(): float
    {
        $totalClicks = $this->total_clicks;
        $totalConversions = $this->total_conversions;
        
        return $totalClicks > 0 ? ($totalConversions / $totalClicks) * 100 : 0.0;
    }

    public function activate(): void
    {
        $this->update([
            'status' => 'active',
            'activated_at' => now(),
        ]);
    }
}
```

### Task 2.2: Create CrossPromotion Model
- **File:** `app/Models/CrossPromotion.php`
- **Time:** 10 minutes

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class CrossPromotion extends Model
{
    protected $fillable = [
        'partner_newsletter_id',
        'newsletter_edition_id',
        'scheduled_date',
        'promotion_type',
        'headline',
        'content',
        'cta_text',
        'tracking_link',
        'image_url',
        'position',
        'status',
        'sent_at',
        'clicks',
        'conversions',
    ];

    protected $casts = [
        'scheduled_date' => 'date',
        'sent_at' => 'datetime',
        'clicks' => 'integer',
        'conversions' => 'integer',
    ];

    public function partnerNewsletter(): BelongsTo
    {
        return $this->belongsTo(PartnerNewsletter::class);
    }

    public function newsletterEdition(): BelongsTo
    {
        return $this->belongsTo(Newsletter::class, 'newsletter_edition_id');
    }

    public function partnerClicks(): HasMany
    {
        return $this->hasMany(PartnerClick::class);
    }

    public function scopeScheduled($query)
    {
        return $query->where('status', 'scheduled')
            ->orderBy('scheduled_date', 'asc');
    }

    public function scopeSent($query)
    {
        return $query->where('status', 'sent');
    }

    public function scopeUpcoming($query)
    {
        return $query->where('status', 'scheduled')
            ->where('scheduled_date', '>=', now()->toDateString());
    }

    public function markAsSent(): void
    {
        $this->update([
            'status' => 'sent',
            'sent_at' => now(),
        ]);
    }

    public function getCtrAttribute(): float
    {
        // Assuming newsletter has 1000 subscribers (adjust based on actual)
        $impressions = 1000;
        return $impressions > 0 ? ($this->clicks / $impressions) * 100 : 0.0;
    }

    public function getConversionRateAttribute(): float
    {
        return $this->clicks > 0 ? ($this->conversions / $this->clicks) * 100 : 0.0;
    }
}
```

### Task 2.3: Create PartnerClick Model
- **File:** `app/Models/PartnerClick.php`
- **Time:** 5 minutes

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PartnerClick extends Model
{
    protected $fillable = [
        'cross_promotion_id',
        'subscriber_id',
        'clicked_at',
        'ip_address',
        'user_agent',
        'converted_at',
    ];

    protected $casts = [
        'clicked_at' => 'datetime',
        'converted_at' => 'datetime',
    ];

    public function crossPromotion(): BelongsTo
    {
        return $this->belongsTo(CrossPromotion::class);
    }

    public function subscriber(): BelongsTo
    {
        return $this->belongsTo(Subscriber::class);
    }

    public function isConverted(): bool
    {
        return !is_null($this->converted_at);
    }
}
```

**Checklist:**
- [ ] All 3 models created
- [ ] Relationships defined
- [ ] Accessors/mutators work
- [ ] No linting errors

---

## Phase 3: Service Layer (45 minutes)

### Task 3.1: Create CrossPromotionService
- **File:** `app/Services/CrossPromotionService.php`
- **Time:** 45 minutes

```php
<?php

namespace App\Services;

use App\Models\PartnerNewsletter;
use App\Models\CrossPromotion;
use App\Models\PartnerClick;
use App\Models\Subscriber;
use Illuminate\Support\Facades\Log;

class CrossPromotionService
{
    /**
     * Generate UTM tracking link for partner
     */
    public function generateTrackingLink(PartnerNewsletter $partner, CrossPromotion $promo): string
    {
        $baseUrl = $partner->subscribe_url;
        
        $utmParams = http_build_query([
            'utm_source' => 'hudson-life-dispatch',
            'utm_medium' => 'newsletter',
            'utm_campaign' => $partner->slug,
            'utm_content' => 'promo-' . $promo->id,
        ]);
        
        $separator = parse_url($baseUrl, PHP_URL_QUERY) ? '&' : '?';
        
        return $baseUrl . $separator . $utmParams;
    }

    /**
     * Get upcoming promotion for newsletter edition
     */
    public function getUpcomingPromotion(): ?CrossPromotion
    {
        return CrossPromotion::scheduled()
            ->where('scheduled_date', '<=', now()->toDateString())
            ->with('partnerNewsletter')
            ->first();
    }

    /**
     * Track partner link click
     */
    public function trackClick(int $promoId, ?Subscriber $subscriber = null): void
    {
        try {
            $promo = CrossPromotion::findOrFail($promoId);
            
            // Increment counter
            $promo->increment('clicks');
            
            // Log detailed click
            PartnerClick::create([
                'cross_promotion_id' => $promo->id,
                'subscriber_id' => $subscriber?->id,
                'clicked_at' => now(),
                'ip_address' => request()->ip(),
                'user_agent' => request()->userAgent(),
            ]);

            Log::info('Partner click tracked', [
                'promo_id' => $promoId,
                'partner' => $promo->partnerNewsletter->name,
                'subscriber_id' => $subscriber?->id,
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to track partner click', [
                'promo_id' => $promoId,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Track conversion (when subscriber signs up from partner referral)
     */
    public function trackConversion(Subscriber $newSubscriber, string $partnerSlug): void
    {
        try {
            // Find partner
            $partner = PartnerNewsletter::where('slug', $partnerSlug)->first();
            
            if (!$partner) {
                return;
            }

            // Find recent promotion
            $recentPromo = CrossPromotion::where('partner_newsletter_id', $partner->id)
                ->where('status', 'sent')
                ->where('sent_at', '>=', now()->subDays(30))
                ->orderBy('sent_at', 'desc')
                ->first();

            if (!$recentPromo) {
                return;
            }

            // Find click from last 7 days (attribute window)
            $recentClick = PartnerClick::where('cross_promotion_id', $recentPromo->id)
                ->where('clicked_at', '>=', now()->subDays(7))
                ->whereNull('converted_at')
                ->orderBy('clicked_at', 'desc')
                ->first();

            if ($recentClick) {
                $recentClick->update([
                    'converted_at' => now(),
                    'subscriber_id' => $newSubscriber->id,
                ]);
                
                $recentPromo->increment('conversions');

                Log::info('Partner conversion tracked', [
                    'partner' => $partner->name,
                    'subscriber_id' => $newSubscriber->id,
                ]);
            }
        } catch (\Exception $e) {
            Log::error('Failed to track partner conversion', [
                'subscriber_email' => $newSubscriber->email,
                'partner_slug' => $partnerSlug,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Get analytics for partner
     */
    public function getPartnerAnalytics(PartnerNewsletter $partner): array
    {
        $promotions = $partner->crossPromotions()
            ->where('status', 'sent')
            ->get();

        $totalClicks = $promotions->sum('clicks');
        $totalConversions = $promotions->sum('conversions');
        $totalPromotions = $promotions->count();

        return [
            'total_promotions' => $totalPromotions,
            'total_clicks' => $totalClicks,
            'total_conversions' => $totalConversions,
            'average_ctr' => $partner->average_ctr,
            'conversion_rate' => $partner->conversion_rate,
            'clicks_per_promotion' => $totalPromotions > 0 ? round($totalClicks / $totalPromotions, 1) : 0,
            'conversions_per_promotion' => $totalPromotions > 0 ? round($totalConversions / $totalPromotions, 1) : 0,
        ];
    }

    /**
     * Generate default promo content for partner
     */
    public function generateDefaultContent(PartnerNewsletter $partner): array
    {
        return [
            'headline' => "📮 Check out {$partner->name}",
            'content' => $partner->description ?? "Discover {$partner->name}, your {$partner->frequency} newsletter for {$partner->geographic_focus}.",
            'cta_text' => "Subscribe to {$partner->name} →",
        ];
    }
}
```

**Checklist:**
- [ ] Service created
- [ ] All methods implemented
- [ ] Error handling added
- [ ] Logging included

---

## Phase 4: Filament Admin Resources (1.5 hours)

### Task 4.1: Create PartnerNewsletterResource
- **File:** `app/Filament/Resources/PartnerNewsletterResource.php`
- **Time:** 45 minutes

```php
<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PartnerNewsletterResource\Pages;
use App\Models\PartnerNewsletter;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Notifications\Notification;

class PartnerNewsletterResource extends Resource
{
    protected static ?string $model = PartnerNewsletter::class;
    protected static ?string $navigationIcon = 'heroicon-o-newspaper';
    protected static ?string $navigationGroup = 'Partnerships';
    protected static ?string $navigationLabel = 'Partner Newsletters';
    protected static ?int $navigationSort = 1;

    public static function form(Forms\Form $form): Forms\Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Basic Information')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->required()
                            ->maxLength(255)
                            ->reactive()
                            ->afterStateUpdated(fn ($state, callable $set) => 
                                $set('slug', \Str::slug($state))
                            ),
                        
                        Forms\Components\TextInput::make('slug')
                            ->required()
                            ->unique(ignoreRecord: true)
                            ->helperText('Auto-generated from name'),
                        
                        Forms\Components\TextInput::make('publisher_name')
                            ->label('Publisher/Contact Name')
                            ->maxLength(255),
                        
                        Forms\Components\TextInput::make('contact_email')
                            ->email()
                            ->maxLength(255),
                        
                        Forms\Components\TextInput::make('website_url')
                            ->url()
                            ->maxLength(500),
                        
                        Forms\Components\TextInput::make('subscribe_url')
                            ->label('Subscribe URL')
                            ->required()
                            ->url()
                            ->helperText('Where users subscribe to this newsletter'),
                        
                        Forms\Components\FileUpload::make('logo_url')
                            ->label('Logo')
                            ->image()
                            ->maxSize(2048),
                    ])->columns(2),
                
                Forms\Components\Section::make('Details')
                    ->schema([
                        Forms\Components\Textarea::make('description')
                            ->rows(3)
                            ->helperText('Brief description for promo content'),
                        
                        Forms\Components\Textarea::make('audience_focus')
                            ->rows(2)
                            ->helperText('Who is their target audience?'),
                        
                        Forms\Components\TextInput::make('geographic_focus')
                            ->maxLength(255)
                            ->placeholder('e.g., Catskills, Hudson Valley, NYC'),
                        
                        Forms\Components\TextInput::make('subscriber_count')
                            ->numeric()
                            ->helperText('Approximate subscriber count'),
                        
                        Forms\Components\Select::make('frequency')
                            ->options([
                                'daily' => 'Daily',
                                'weekly' => 'Weekly',
                                'biweekly' => 'Bi-weekly',
                                'monthly' => 'Monthly',
                            ])
                            ->default('weekly'),
                    ])->columns(2),
                
                Forms\Components\Section::make('Partnership')
                    ->schema([
                        Forms\Components\Select::make('status')
                            ->options([
                                'prospective' => 'Prospective',
                                'active' => 'Active',
                                'paused' => 'Paused',
                                'ended' => 'Ended',
                            ])
                            ->required()
                            ->default('prospective'),
                        
                        Forms\Components\Textarea::make('agreement_terms')
                            ->rows(4)
                            ->helperText('e.g., 1:1 swap monthly, same placement type'),
                        
                        Forms\Components\Textarea::make('notes')
                            ->rows(3)
                            ->helperText('Internal notes'),
                    ]),
            ]);
    }

    public static function table(Tables\Table $table): Tables\Table
    {
        return $table
            ->columns([
                Tables\Columns\ImageColumn::make('logo_url')
                    ->label('Logo')
                    ->circular()
                    ->defaultImageUrl(fn() => 'https://ui-avatars.com/api/?name=N&color=7F9CF5&background=EBF4FF'),
                
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable()
                    ->weight('bold'),
                
                Tables\Columns\BadgeColumn::make('status')
                    ->colors([
                        'secondary' => 'prospective',
                        'success' => 'active',
                        'warning' => 'paused',
                        'danger' => 'ended',
                    ]),
                
                Tables\Columns\TextColumn::make('subscriber_count')
                    ->label('Subscribers')
                    ->formatStateUsing(fn ($state) => number_format($state ?? 0))
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('crossPromotions_count')
                    ->label('Promos Sent')
                    ->counts('crossPromotions'),
                
                Tables\Columns\TextColumn::make('total_clicks')
                    ->label('Total Clicks')
                    ->getStateUsing(fn ($record) => $record->total_clicks)
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('total_conversions')
                    ->label('Conversions')
                    ->getStateUsing(fn ($record) => $record->total_conversions)
                    ->badge()
                    ->color('success'),
            ])
            ->defaultSort('name', 'asc')
            ->filters([
                Tables\Filters\SelectFilter::make('status')
                    ->options([
                        'prospective' => 'Prospective',
                        'active' => 'Active',
                        'paused' => 'Paused',
                        'ended' => 'Ended',
                    ]),
            ])
            ->actions([
                Tables\Actions\Action::make('activate')
                    ->label('Activate')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->action(function (PartnerNewsletter $record) {
                        $record->activate();
                        Notification::make()
                            ->success()
                            ->title('Partner activated')
                            ->send();
                    })
                    ->visible(fn ($record) => $record->status !== 'active'),
                
                Tables\Actions\Action::make('viewAnalytics')
                    ->label('Analytics')
                    ->icon('heroicon-o-chart-bar')
                    ->url(fn ($record) => PartnerNewsletterResource::getUrl('analytics', ['record' => $record])),
                
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListPartnerNewsletters::route('/'),
            'create' => Pages\CreatePartnerNewsletter::route('/create'),
            'edit' => Pages\EditPartnerNewsletter::route('/{record}/edit'),
            'analytics' => Pages\PartnerAnalytics::route('/{record}/analytics'),
        ];
    }
}
```

### Task 4.2: Create CrossPromotionResource
- **File:** `app/Filament/Resources/CrossPromotionResource.php`
- **Time:** 45 minutes

*(Implementation similar to above - full code in actual file)*

**Checklist:**
- [ ] PartnerNewsletterResource created
- [ ] CrossPromotionResource created
- [ ] Both resources registered
- [ ] Analytics page created

---

## Phase 5: Testing (30 minutes)

### Manual Test Cases
1. [ ] Create partner newsletter
2. [ ] Schedule cross-promotion
3. [ ] Generate tracking link
4. [ ] Click tracking link
5. [ ] Verify click tracked in database
6. [ ] Simulate conversion
7. [ ] Verify conversion tracked
8. [ ] Check analytics dashboard
9. [ ] Mark promotion as sent
10. [ ] Export partner report

---

## Phase 6: Deployment (15 minutes)

```bash
# Run migrations
php artisan migrate --force

# Clear caches
php artisan cache:clear
php artisan config:clear

# Verify
php artisan tinker
>>> PartnerNewsletter::count()
=> 0
```

---

## Total Time: 3-5 hours

**Success Metrics:**
- 5+ partners within 60 days
- 10%+ of new subscribers from partners
- 2%+ average CTR
- 15%+ conversion rate

---

## Next Steps After Launch
1. Outreach to 10 target partners
2. Schedule first 2-3 promos
3. Monitor performance weekly
4. Optimize promo content based on CTR
5. Build partner coalition (3+ newsletters)

