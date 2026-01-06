# Implementation Plan: Referral Rewards System

**Feature ID:** DLC-03  
**Estimated Time:** 3-6 hours  
**Dependencies:** Existing referral tracking system

---

## Phase 1: Database Schema (45 minutes)

### Task 1.1: Create Rewards Table Migration
- **File:** `database/migrations/YYYY_MM_DD_create_rewards_table.php`
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
        Schema::create('rewards', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->unsignedInteger('milestone'); // Number of referrals required
            $table->enum('reward_type', ['badge', 'discount', 'swag', 'feature', 'experience'])
                  ->default('badge');
            $table->text('redemption_instructions')->nullable();
            $table->string('image_url', 500)->nullable();
            $table->string('sponsor_name')->nullable();
            $table->string('sponsor_logo_url', 500)->nullable();
            $table->boolean('active')->default(true);
            $table->integer('sort_order')->default(0);
            $table->timestamps();

            $table->index('milestone');
            $table->index('active');
            $table->index(['active', 'milestone']); // Composite for frequent queries
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rewards');
    }
};
```

### Task 1.2: Create Earned Rewards Table Migration
- **File:** `database/migrations/YYYY_MM_DD_create_earned_rewards_table.php`
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
        Schema::create('earned_rewards', function (Blueprint $table) {
            $table->id();
            $table->foreignId('subscriber_id')->constrained()->onDelete('cascade');
            $table->foreignId('reward_id')->constrained()->onDelete('cascade');
            $table->timestamp('earned_at');
            $table->timestamp('notified_at')->nullable();
            $table->timestamp('redeemed_at')->nullable();
            $table->string('redemption_code', 50)->unique();
            $table->text('redemption_notes')->nullable();
            $table->timestamps();

            // Prevent duplicate reward grants
            $table->unique(['subscriber_id', 'reward_id']);
            $table->index('redeemed_at');
            $table->index(['subscriber_id', 'redeemed_at']); // For user's earned rewards
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('earned_rewards');
    }
};
```

### Task 1.3: Create Seed Data
- **File:** `database/seeders/RewardSeeder.php`
- **Time:** 5 minutes

```php
<?php

namespace Database\Seeders;

use App\Models\Reward;
use Illuminate\Database\Seeder;

class RewardSeeder extends Seeder
{
    public function run(): void
    {
        $rewards = [
            [
                'name' => '🎉 Community Builder',
                'description' => 'Welcome bonus for your first referral!',
                'milestone' => 1,
                'reward_type' => 'badge',
                'redemption_instructions' => 'Automatic digital badge on your profile.',
                'sort_order' => 1,
            ],
            [
                'name' => '☕ Local Love',
                'description' => '$5 gift card to a local coffee shop',
                'milestone' => 3,
                'reward_type' => 'discount',
                'redemption_instructions' => 'Show your redemption code at Birdsall House to claim your $5 credit.',
                'sponsor_name' => 'Birdsall House',
                'sort_order' => 2,
            ],
            [
                'name' => '🎟️ High Five',
                'description' => '2 free tickets to a local event OR $10 restaurant gift card',
                'milestone' => 5,
                'reward_type' => 'experience',
                'redemption_instructions' => 'Email hello@hudsonlifedispatch.com to claim your reward.',
                'sort_order' => 3,
            ],
            [
                'name' => '⭐ VIP Status',
                'description' => 'Exclusive newsletter swag + profile feature',
                'milestone' => 10,
                'reward_type' => 'swag',
                'redemption_instructions' => 'We\'ll email you to collect shipping info for your swag!',
                'sort_order' => 4,
            ],
            [
                'name' => '🏆 Champion',
                'description' => '$50 gift card bundle + VIP lifetime status',
                'milestone' => 25,
                'reward_type' => 'experience',
                'redemption_instructions' => 'Email hello@hudsonlifedispatch.com to claim your Champion reward.',
                'sort_order' => 5,
            ],
            [
                'name' => '👑 Legend',
                'description' => '$100 gift card bundle + dinner with the team + permanent profile',
                'milestone' => 50,
                'reward_type' => 'experience',
                'redemption_instructions' => 'Contact us to schedule your Legend celebration!',
                'sort_order' => 6,
            ],
        ];

        foreach ($rewards as $reward) {
            Reward::create($reward);
        }
    }
}
```

**Checklist:**
- [ ] Rewards migration created
- [ ] Earned rewards migration created
- [ ] Seeder created
- [ ] Migrations run successfully
- [ ] Seed data populated

---

## Phase 2: Models & Services (1 hour)

### Task 2.1: Create Reward Model
- **File:** `app/Models/Reward.php`
- **Time:** 15 minutes

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Reward extends Model
{
    protected $fillable = [
        'name',
        'description',
        'milestone',
        'reward_type',
        'redemption_instructions',
        'image_url',
        'sponsor_name',
        'sponsor_logo_url',
        'active',
        'sort_order',
    ];

    protected $casts = [
        'milestone' => 'integer',
        'active' => 'boolean',
        'sort_order' => 'integer',
    ];

    public function earnedRewards(): HasMany
    {
        return $this->hasMany(EarnedReward::class);
    }

    public function scopeActive($query)
    {
        return $query->where('active', true);
    }

    public function scopeOrderByMilestone($query)
    {
        return $query->orderBy('milestone', 'asc');
    }
}
```

### Task 2.2: Create EarnedReward Model
- **File:** `app/Models/EarnedReward.php`
- **Time:** 15 minutes

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class EarnedReward extends Model
{
    protected $fillable = [
        'subscriber_id',
        'reward_id',
        'earned_at',
        'notified_at',
        'redeemed_at',
        'redemption_code',
        'redemption_notes',
    ];

    protected $casts = [
        'earned_at' => 'datetime',
        'notified_at' => 'datetime',
        'redeemed_at' => 'datetime',
    ];

    public function subscriber(): BelongsTo
    {
        return $this->belongsTo(Subscriber::class);
    }

    public function reward(): BelongsTo
    {
        return $this->belongsTo(Reward::class);
    }

    public function scopePending($query)
    {
        return $query->whereNull('redeemed_at');
    }

    public function scopeRedeemed($query)
    {
        return $query->whereNotNull('redeemed_at');
    }

    public function isRedeemed(): bool
    {
        return !is_null($this->redeemed_at);
    }

    public function markRedeemed(?string $notes = null): void
    {
        $this->update([
            'redeemed_at' => now(),
            'redemption_notes' => $notes,
        ]);
    }
}
```

### Task 2.3: Update Subscriber Model
- **File:** `app/Models/Subscriber.php`
- **Time:** 5 minutes

```php
// Add to Subscriber model
public function earnedRewards(): HasMany
{
    return $this->hasMany(EarnedReward::class);
}

public function hasEarnedReward(Reward $reward): bool
{
    return $this->earnedRewards()
        ->where('reward_id', $reward->id)
        ->exists();
}

public function getReferralCountAttribute(): int
{
    return $this->referrals()->where('verified', true)->count();
}
```

### Task 2.4: Create RewardService
- **File:** `app/Services/RewardService.php`
- **Time:** 25 minutes

```php
<?php

namespace App\Services;

use App\Models\Subscriber;
use App\Models\Reward;
use App\Models\EarnedReward;
use App\Mail\RewardEarnedMail;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;

class RewardService
{
    /**
     * Check if subscriber qualifies for any new rewards
     */
    public function checkAndGrantRewards(Subscriber $subscriber): array
    {
        $referralCount = $subscriber->referrals()->where('verified', true)->count();
        
        $eligibleRewards = Reward::active()
            ->where('milestone', '<=', $referralCount)
            ->orderBy('milestone', 'asc')
            ->get();
        
        $grantedRewards = [];
        
        foreach ($eligibleRewards as $reward) {
            if ($this->grantRewardIfNotEarned($subscriber, $reward)) {
                $grantedRewards[] = $reward;
            }
        }
        
        return $grantedRewards;
    }

    /**
     * Grant a reward to subscriber if they haven't earned it yet
     */
    protected function grantRewardIfNotEarned(Subscriber $subscriber, Reward $reward): bool
    {
        // Check if already earned
        if ($subscriber->hasEarnedReward($reward)) {
            return false;
        }
        
        try {
            // Create earned reward record
            $earnedReward = EarnedReward::create([
                'subscriber_id' => $subscriber->id,
                'reward_id' => $reward->id,
                'earned_at' => now(),
                'redemption_code' => $this->generateRedemptionCode($subscriber, $reward),
            ]);
            
            // Send notification email
            $this->sendRewardNotification($subscriber, $earnedReward);
            
            Log::info('Reward granted', [
                'subscriber_id' => $subscriber->id,
                'reward_id' => $reward->id,
                'reward_name' => $reward->name,
            ]);
            
            return true;
        } catch (\Exception $e) {
            Log::error('Failed to grant reward', [
                'subscriber_id' => $subscriber->id,
                'reward_id' => $reward->id,
                'error' => $e->getMessage(),
            ]);
            
            return false;
        }
    }

    /**
     * Generate unique redemption code
     */
    protected function generateRedemptionCode(Subscriber $subscriber, Reward $reward): string
    {
        $prefix = 'HLD';
        $userPart = strtoupper(substr(str_replace(['@', '.', '-'], '', $subscriber->email), 0, 5));
        $year = date('Y');
        $rewardPart = str_pad($reward->id, 3, '0', STR_PAD_LEFT);
        $random = strtoupper(substr(uniqid(), -3));
        
        return "{$prefix}-{$userPart}-{$year}-{$rewardPart}-{$random}";
    }

    /**
     * Send reward notification email
     */
    protected function sendRewardNotification(Subscriber $subscriber, EarnedReward $earnedReward): void
    {
        try {
            Mail::to($subscriber->email)
                ->send(new RewardEarnedMail($subscriber, $earnedReward));
            
            $earnedReward->update(['notified_at' => now()]);
        } catch (\Exception $e) {
            Log::error('Failed to send reward notification', [
                'subscriber_id' => $subscriber->id,
                'earned_reward_id' => $earnedReward->id,
                'error' => $e->getMessage(),
            ]);
        }
    }

    /**
     * Get next reward for subscriber
     */
    public function getNextReward(Subscriber $subscriber): ?Reward
    {
        $referralCount = $subscriber->referrals()->where('verified', true)->count();
        
        return Reward::active()
            ->where('milestone', '>', $referralCount)
            ->orderBy('milestone', 'asc')
            ->first();
    }

    /**
     * Get progress to next reward
     */
    public function getProgressToNextReward(Subscriber $subscriber): array
    {
        $referralCount = $subscriber->referrals()->where('verified', true)->count();
        $nextReward = $this->getNextReward($subscriber);
        
        if (!$nextReward) {
            return [
                'current' => $referralCount,
                'next_milestone' => null,
                'remaining' => 0,
                'percentage' => 100,
                'next_reward' => null,
            ];
        }
        
        $remaining = $nextReward->milestone - $referralCount;
        $percentage = ($referralCount / $nextReward->milestone) * 100;
        
        return [
            'current' => $referralCount,
            'next_milestone' => $nextReward->milestone,
            'remaining' => max(0, $remaining),
            'percentage' => min(100, round($percentage, 1)),
            'next_reward' => $nextReward,
        ];
    }
}
```

**Checklist:**
- [ ] Reward model created
- [ ] EarnedReward model created
- [ ] Subscriber model updated
- [ ] RewardService created
- [ ] No linting errors

---

## Phase 3: Filament Admin Panel (1 hour)

### Task 3.1: Create RewardResource
- **File:** `app/Filament/Resources/RewardResource.php`
- **Time:** 30 minutes

```php
<?php

namespace App\Filament\Resources;

use App\Filament\Resources\RewardResource\Pages;
use App\Models\Reward;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Tables;

class RewardResource extends Resource
{
    protected static ?string $model = Reward::class;
    protected static ?string $navigationIcon = 'heroicon-o-gift';
    protected static ?string $navigationGroup = 'Marketing';
    protected static ?int $navigationSort = 3;

    public static function form(Forms\Form $form): Forms\Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Reward Details')
                    ->schema([
                        Forms\Components\TextInput::make('name')
                            ->required()
                            ->maxLength(255)
                            ->placeholder('e.g., ☕ Local Love'),
                        
                        Forms\Components\Textarea::make('description')
                            ->rows(3)
                            ->placeholder('Brief description of what user gets'),
                        
                        Forms\Components\TextInput::make('milestone')
                            ->required()
                            ->numeric()
                            ->minValue(1)
                            ->helperText('Number of referrals required to earn this reward'),
                        
                        Forms\Components\Select::make('reward_type')
                            ->required()
                            ->options([
                                'badge' => 'Badge (Digital)',
                                'discount' => 'Discount/Gift Card',
                                'swag' => 'Physical Swag',
                                'feature' => 'Profile Feature',
                                'experience' => 'Experience/Event',
                            ]),
                        
                        Forms\Components\Textarea::make('redemption_instructions')
                            ->rows(4)
                            ->helperText('How user redeems this reward'),
                    ]),
                
                Forms\Components\Section::make('Media & Sponsor')
                    ->schema([
                        Forms\Components\FileUpload::make('image_url')
                            ->label('Reward Image')
                            ->image()
                            ->maxSize(2048),
                        
                        Forms\Components\TextInput::make('sponsor_name')
                            ->maxLength(255)
                            ->placeholder('e.g., Birdsall House'),
                        
                        Forms\Components\FileUpload::make('sponsor_logo_url')
                            ->label('Sponsor Logo')
                            ->image()
                            ->maxSize(1024),
                    ]),
                
                Forms\Components\Section::make('Settings')
                    ->schema([
                        Forms\Components\Toggle::make('active')
                            ->default(true)
                            ->helperText('Only active rewards can be earned'),
                        
                        Forms\Components\TextInput::make('sort_order')
                            ->numeric()
                            ->default(0)
                            ->helperText('Display order (lower numbers first)'),
                    ]),
            ]);
    }

    public static function table(Tables\Table $table): Tables\Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('name')
                    ->searchable()
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('milestone')
                    ->label('Referrals')
                    ->suffix(' refs')
                    ->sortable(),
                
                Tables\Columns\BadgeColumn::make('reward_type')
                    ->label('Type')
                    ->colors([
                        'secondary' => 'badge',
                        'success' => 'discount',
                        'warning' => 'swag',
                        'info' => 'feature',
                        'primary' => 'experience',
                    ]),
                
                Tables\Columns\TextColumn::make('earnedRewards_count')
                    ->label('Times Earned')
                    ->counts('earnedRewards'),
                
                Tables\Columns\IconColumn::make('active')
                    ->boolean()
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('sponsor_name')
                    ->toggleable()
                    ->toggledHiddenByDefault(),
            ])
            ->defaultSort('milestone', 'asc')
            ->filters([
                Tables\Filters\SelectFilter::make('reward_type'),
                Tables\Filters\TernaryFilter::make('active'),
            ])
            ->actions([
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
            'index' => Pages\ListRewards::route('/'),
            'create' => Pages\CreateReward::route('/create'),
            'edit' => Pages\EditReward::route('/{record}/edit'),
        ];
    }
}
```

### Task 3.2: Create EarnedRewardResource
- **File:** `app/Filament/Resources/EarnedRewardResource.php`
- **Time:** 30 minutes

```php
<?php

namespace App\Filament\Resources;

use App\Filament\Resources\EarnedRewardResource\Pages;
use App\Models\EarnedReward;
use Filament\Forms;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Notifications\Notification;

class EarnedRewardResource extends Resource
{
    protected static ?string $model = EarnedReward::class;
    protected static ?string $navigationIcon = 'heroicon-o-trophy';
    protected static ?string $navigationGroup = 'Marketing';
    protected static ?string $navigationLabel = 'Earned Rewards';
    protected static ?int $navigationSort = 4;

    public static function form(Forms\Form $form): Forms\Form
    {
        return $form
            ->schema([
                Forms\Components\Select::make('subscriber_id')
                    ->relationship('subscriber', 'email')
                    ->required()
                    ->searchable(),
                
                Forms\Components\Select::make('reward_id')
                    ->relationship('reward', 'name')
                    ->required(),
                
                Forms\Components\DateTimePicker::make('earned_at')
                    ->required()
                    ->default(now()),
                
                Forms\Components\TextInput::make('redemption_code')
                    ->required()
                    ->maxLength(50),
                
                Forms\Components\DateTimePicker::make('redeemed_at'),
                
                Forms\Components\Textarea::make('redemption_notes')
                    ->rows(3),
            ]);
    }

    public static function table(Tables\Table $table): Tables\Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('subscriber.email')
                    ->searchable()
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('reward.name')
                    ->searchable()
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('earned_at')
                    ->dateTime()
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('redemption_code')
                    ->copyable()
                    ->searchable(),
                
                Tables\Columns\IconColumn::make('redeemed_at')
                    ->label('Redeemed')
                    ->boolean()
                    ->trueIcon('heroicon-o-check-circle')
                    ->falseIcon('heroicon-o-clock')
                    ->trueColor('success')
                    ->falseColor('warning')
                    ->sortable(),
                
                Tables\Columns\TextColumn::make('redeemed_at')
                    ->dateTime()
                    ->toggleable()
                    ->toggledHiddenByDefault(),
            ])
            ->defaultSort('earned_at', 'desc')
            ->filters([
                Tables\Filters\Filter::make('pending')
                    ->query(fn ($query) => $query->whereNull('redeemed_at'))
                    ->label('Pending Redemption'),
                
                Tables\Filters\Filter::make('redeemed')
                    ->query(fn ($query) => $query->whereNotNull('redeemed_at'))
                    ->label('Redeemed'),
                
                Tables\Filters\SelectFilter::make('reward')
                    ->relationship('reward', 'name'),
            ])
            ->actions([
                Tables\Actions\Action::make('markRedeemed')
                    ->label('Mark Redeemed')
                    ->icon('heroicon-o-check')
                    ->color('success')
                    ->form([
                        Forms\Components\Textarea::make('redemption_notes')
                            ->label('Notes')
                            ->rows(2),
                    ])
                    ->action(function (EarnedReward $record, array $data) {
                        $record->markRedeemed($data['redemption_notes'] ?? null);
                        Notification::make()
                            ->success()
                            ->title('Marked as redeemed')
                            ->send();
                    })
                    ->visible(fn (EarnedReward $record) => !$record->isRedeemed()),
                
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkAction::make('markRedeemed')
                    ->label('Mark as Redeemed')
                    ->icon('heroicon-o-check-circle')
                    ->color('success')
                    ->requiresConfirmation()
                    ->action(function ($records) {
                        $records->each->markRedeemed();
                        Notification::make()
                            ->success()
                            ->title('Marked ' . $records->count() . ' rewards as redeemed')
                            ->send();
                    }),
            ]);
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListEarnedRewards::route('/'),
            'create' => Pages\CreateEarnedReward::route('/create'),
            'edit' => Pages\EditEarnedReward::route('/{record}/edit'),
        ];
    }

    public static function getNavigationBadge(): ?string
    {
        $pendingCount = static::getModel()::whereNull('redeemed_at')->count();
        return $pendingCount > 0 ? (string) $pendingCount : null;
    }

    public static function getNavigationBadgeColor(): ?string
    {
        return 'warning';
    }
}
```

**Checklist:**
- [ ] RewardResource created
- [ ] EarnedRewardResource created
- [ ] Resources registered in admin panel
- [ ] Navigation badge shows pending redemptions

---

## Phase 4: Integration & Automation (45 minutes)

### Task 4.1: Hook into Referral System
- **File:** Update wherever new referrals are verified
- **Time:** 15 minutes

```php
// In your existing referral verification logic
// (likely in SubscriberService or similar)

use App\Services\RewardService;

// After verifying a referral
public function verifyReferral($referralCode)
{
    // ... existing verification logic ...
    
    // Check for rewards
    $rewardService = app(RewardService::class);
    $subscriber = Subscriber::where('referral_code', $referralCode)->first();
    
    if ($subscriber) {
        $grantedRewards = $rewardService->checkAndGrantRewards($subscriber);
        
        if (count($grantedRewards) > 0) {
            Log::info('Rewards granted on referral verification', [
                'subscriber_id' => $subscriber->id,
                'rewards_count' => count($grantedRewards),
            ]);
        }
    }
}
```

### Task 4.2: Create Reward Email Template
- **File:** `app/Mail/RewardEarnedMail.php`
- **Time:** 20 minutes

```php
<?php

namespace App\Mail;

use App\Models\Subscriber;
use App\Models\EarnedReward;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class RewardEarnedMail extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(
        public Subscriber $subscriber,
        public EarnedReward $earnedReward
    ) {}

    public function build()
    {
        $reward = $this->earnedReward->reward;
        
        return $this
            ->subject('🎉 You earned a reward!')
            ->markdown('emails.rewards.earned', [
                'subscriber' => $this->subscriber,
                'earnedReward' => $this->earnedReward,
                'reward' => $reward,
                'redemptionCode' => $this->earnedReward->redemption_code,
            ]);
    }
}
```

### Task 4.3: Create Email View
- **File:** `resources/views/emails/rewards/earned.blade.php`
- **Time:** 10 minutes

```blade
@component('mail::message')
# 🎉 Congratulations {{ $subscriber->first_name ?? 'there' }}!

You've earned the **{{ $reward->name }}** reward!

@component('mail::panel')
## Your Reward
{{ $reward->description }}

**Redemption Code:** `{{ $redemptionCode }}`
@endcomponent

## How to Redeem
{{ $reward->redemption_instructions }}

@if($reward->sponsor_name)
*This reward is sponsored by {{ $reward->sponsor_name }}*
@endif

---

Keep sharing! Check out what other rewards you can earn:

@component('mail::button', ['url' => config('app.url') . '/rewards'])
View All Rewards
@endcomponent

Thanks for spreading the word about Hudson Life Dispatch!

{{ config('app.name') }}
@endcomponent
```

**Checklist:**
- [ ] Referral verification triggers reward check
- [ ] Email template created
- [ ] Email view created
- [ ] Test email sends successfully

---

## Phase 5: Frontend Integration (1.5 hours)

### Task 5.1: Create API Endpoints
- **File:** `routes/api.php`
- **Time:** 15 minutes

```php
// Public rewards
Route::get('/rewards', [RewardController::class, 'index']);

// Authenticated subscriber routes
Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('/my-rewards', [RewardController::class, 'myRewards']);
    Route::get('/my-rewards/progress', [RewardController::class, 'progress']);
    Route::post('/earned-rewards/{earnedReward}/redeem', [RewardController::class, 'markRedeemed']);
});
```

### Task 5.2: Create RewardController
- **File:** `app/Http/Controllers/Api/RewardController.php`
- **Time:** 20 minutes

```php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Reward;
use App\Models\EarnedReward;
use App\Services\RewardService;
use Illuminate\Http\Request;

class RewardController extends Controller
{
    public function __construct(private RewardService $rewardService) {}

    // GET /api/rewards (public)
    public function index()
    {
        $rewards = Reward::active()
            ->orderByMilestone()
            ->get();
        
        return response()->json($rewards);
    }

    // GET /api/my-rewards (authenticated)
    public function myRewards(Request $request)
    {
        $subscriber = $request->user(); // Assuming Sanctum auth
        
        $earnedRewards = $subscriber->earnedRewards()
            ->with('reward')
            ->orderBy('earned_at', 'desc')
            ->get();
        
        return response()->json($earnedRewards);
    }

    // GET /api/my-rewards/progress (authenticated)
    public function progress(Request $request)
    {
        $subscriber = $request->user();
        
        $progress = $this->rewardService->getProgressToNextReward($subscriber);
        
        return response()->json($progress);
    }

    // POST /api/earned-rewards/{earnedReward}/redeem (authenticated)
    public function markRedeemed(Request $request, EarnedReward $earnedReward)
    {
        // Ensure user owns this reward
        if ($earnedReward->subscriber_id !== $request->user()->id) {
            return response()->json(['error' => 'Unauthorized'], 403);
        }
        
        if ($earnedReward->isRedeemed()) {
            return response()->json(['error' => 'Already redeemed'], 400);
        }
        
        $earnedReward->markRedeemed('Self-service redemption');
        
        return response()->json([
            'message' => 'Reward marked as redeemed',
            'earnedReward' => $earnedReward->fresh(),
        ]);
    }
}
```

### Task 5.3: Create Frontend Components
- **Time:** 55 minutes

**(Task continues with React/Next.js components - truncated for brevity)**

**Checklist:**
- [ ] API endpoints created
- [ ] Controller implemented
- [ ] Frontend components created
- [ ] Integration tested end-to-end

---

## Phase 6: Testing (30 minutes)

### Manual Test Cases
1. [ ] Create reward in admin panel
2. [ ] Subscriber reaches milestone
3. [ ] Reward auto-granted
4. [ ] Email notification sent
5. [ ] Reward appears in profile
6. [ ] Redemption code works
7. [ ] Mark as redeemed
8. [ ] Progress bar accurate
9. [ ] Leaderboard still works
10. [ ] Admin can manually grant reward

---

## Phase 7: Deployment (15 minutes)

```bash
# Run migrations
php artisan migrate --force

# Seed rewards
php artisan db:seed --class=RewardSeeder

# Clear caches
php artisan cache:clear

# Verify
php artisan tinker
>>> Reward::count()
=> 6
```

---

## Total Time: 3-6 hours

**Success Metrics (30 days post-launch):**
- 20%+ referral participation
- 3+ avg referrals per referrer
- 50%+ growth in subscriber signups
- 80%+ redemption rate

---

## Future Enhancements
- Automated physical fulfillment
- Expiring rewards
- A/B test reward offers
- Sponsored reward marketplace

