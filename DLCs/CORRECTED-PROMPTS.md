# Corrected Implementation Prompts - All 4 DLC Features

**IMPORTANT:** These prompts have the CORRECT tech stack information.

---

## 🎯 PROMPT 1: Content Shortlist System (DLC-01)

```
I need you to implement a Content Shortlist System for my local newsletter application.

PROJECT CONTEXT:
Hudson Life Dispatch is a curated local newsletter application that aggregates events, 
jobs, community news, and stories for the Hudson Valley region. The system currently 
has automated content sourcing via Python scrapers, AI-generated summaries, and sends 
weekly newsletters via Resend.

TECH STACK:
- Backend: Laravel (PHP 8.2+) with Filament admin panel - runs on localhost:8000
- Frontend: Next.js 15 (TypeScript) - runs on localhost:3000  
- Database: SQLite (database/database.sqlite) with Eloquent ORM
- Admin URL: localhost:8000/admin (Filament panel)
- Auth: Backend uses Filament auth, Frontend uses Clerk
- Email: Resend API

CURRENT PROBLEM:
Editors can only approve or reject content (events, jobs, stories, community news). 
There's no way to mark items as "maybe" or "review later." This makes it hard to 
build a shortlist of candidates for the newsletter and compare multiple items before 
making final decisions.

FEATURE REQUIREMENTS (from PRD):
Add a "Shortlist" curation status that creates a three-stage workflow:
1. INBOX (default) - New submissions  
2. SHORTLIST (maybe) - Items under consideration
3. FINAL DECISION - Approved or Rejected

This requires:
- Adding `curation_status` enum field to 4 tables: events, job_listings, 
  story_submissions, community_news_items
- Updating 4 Filament resources with new status column, filters, and actions
- Add bulk actions for moving multiple items to shortlist
- Add navigation badge showing shortlist count
- Add quick-action buttons in table rows

IMPLEMENTATION PLAN:
The full plan is in: DLCs/features/01-content-shortlist/PLAN.md
The PRD is in: DLCs/features/01-content-shortlist/PRD.md

Please read both files and implement this feature following the phase-by-phase plan. 
The implementation involves:
- Phase 1: Database migration (30 min)
- Phase 2: Update 4 Filament resources (1.5-2 hours)  
- Phase 3: Testing (30 min)
- Phase 4: Documentation (30 min)

Start with Phase 1 and work through systematically. Use the exact code samples 
provided in PLAN.md and adapt them to match the existing codebase patterns.

KEY FILES TO MODIFY:
- database/migrations/YYYY_MM_DD_add_curation_status_to_content_tables.php (new)
- app/Models/Event.php, JobListing.php, StorySubmission.php, CommunityNewsItem.php
- app/Filament/Resources/EventResource.php
- app/Filament/Resources/JobListingResource.php  
- app/Filament/Resources/StorySubmissionResource.php
- app/Filament/Resources/CommunityNewsItemResource.php

After implementation, test by:
1. Creating new content (should default to "inbox")
2. Moving items to shortlist (single and bulk)
3. Filtering by shortlist status
4. Approving items from shortlist
5. Checking navigation badge updates

Please implement this feature now.
```

---

## 🎯 PROMPT 2: Quality Ratings System (DLC-02)

```
I need you to implement a Quality Ratings System for my local newsletter application.

PROJECT CONTEXT:
Hudson Life Dispatch is a curated local newsletter application for the Hudson Valley 
region. We aggregate events, jobs, community news, and stories from multiple sources 
(automated scrapers + manual submissions). Editors review and approve content for the 
weekly newsletter. The application has a Laravel backend with Filament admin panel 
and a Next.js frontend.

TECH STACK:
- Backend: Laravel (PHP 8.2+) with Filament admin panel - runs on localhost:8000
- Frontend: Next.js 15 (TypeScript) - runs on localhost:3000
- Database: SQLite (database/database.sqlite) with Eloquent ORM
- Admin URL: localhost:8000/admin (Filament panel)
- Email: Resend API

CURRENT PROBLEM:
Editors have no way to rate content quality. This makes it hard to:
- Remember why something was shortlisted
- Sort items by quality to prioritize best content
- Track improvement in content sources over time
- Decide between similar items when multiple events compete for limited newsletter space

FEATURE REQUIREMENTS (from PRD):
Add a 1-5 star quality rating system with optional curation notes for all content types.

This requires:
- Adding `quality_score` (1-5 integer, nullable) and `curation_notes` (text) fields 
  to 4 tables: events, job_listings, story_submissions, community_news_items
- Updating 4 Filament resources with:
  - Quality Assessment form section (star selector + notes textarea)
  - Table column showing stars (⭐⭐⭐⭐⭐)
  - Filters for rating ranges (4-5 stars, unrated, etc.)
  - Quick-rate action buttons (rate 3/4/5 stars with one click)
  - Bulk rating actions
  - Sortable by quality_score
- Optional: Analytics widget showing quality distribution

RATING SCALE:
- ⭐⭐⭐⭐⭐ (5) - Excellent, must include
- ⭐⭐⭐⭐ (4) - Good, strong candidate  
- ⭐⭐⭐ (3) - Average, maybe
- ⭐⭐ (2) - Below average, probably not
- ⭐ (1) - Poor, do not include

IMPLEMENTATION PLAN:
The full plan is in: DLCs/features/02-quality-ratings/PLAN.md
The PRD is in: DLCs/features/02-quality-ratings/PRD.md

Please read both files and implement this feature following the phase-by-phase plan:
- Phase 1: Database migration (30 min)
- Phase 2: Update 4 Filament resources (1.5-2 hours)
- Phase 3: Analytics widget - OPTIONAL (1 hour)
- Phase 4: Testing (30 min)

Start with Phase 1 and work through systematically. Use the exact code samples 
provided in PLAN.md.

KEY FILES TO MODIFY:
- database/migrations/YYYY_MM_DD_add_quality_rating_to_content_tables.php (new)
- app/Models/Event.php, JobListing.php, StorySubmission.php, CommunityNewsItem.php
- app/Filament/Resources/EventResource.php
- app/Filament/Resources/JobListingResource.php
- app/Filament/Resources/StorySubmissionResource.php  
- app/Filament/Resources/CommunityNewsItemResource.php
- app/Filament/Widgets/QualityAnalyticsWidget.php (new, optional)

DEPENDENCY NOTE:
This works great with DLC-01 (Shortlist). If that's already implemented, editors 
can shortlist items, then rate them, then approve the highest-rated ones.

After implementation, test by:
1. Rating an event 5 stars with notes
2. Using quick-rate buttons in table
3. Filtering by "High Quality (4-5 stars)"
4. Bulk rating 10 items at once
5. Sorting table by quality_score
6. Viewing analytics widget (if implemented)

Please implement this feature now.
```

---

## 🎯 PROMPT 3: Referral Rewards System (DLC-03)

```
I need you to implement a Referral Rewards System for my local newsletter application.

PROJECT CONTEXT:
Hudson Life Dispatch is a curated weekly newsletter for the Hudson Valley region. We 
send newsletters via Resend to subscribers. The application already has a referral 
tracking system - subscribers get unique referral codes, and we track who referred 
whom. We also have a referral leaderboard. However, there are NO REWARDS configured, 
so there's no incentive for people to actually share.

TECH STACK:
- Backend: Laravel (PHP 8.2+) with Filament admin panel - runs on localhost:8000
- Frontend: Next.js 15 (TypeScript) with Clerk auth - runs on localhost:3000
- Database: SQLite (database/database.sqlite) with Eloquent ORM
- Admin URL: localhost:8000/admin (Filament panel)
- Email: Resend API

CURRENT STATE:
- ✅ Subscribers table exists with referral_code field
- ✅ Referrals are tracked (referred_by_subscriber_id)
- ✅ Leaderboard shows top referrers
- ❌ No rewards configured
- ❌ No milestone tracking
- ❌ No reward notifications

FEATURE REQUIREMENTS (from PRD):
Build a milestone-based rewards system where subscribers earn prizes at referral 
thresholds (e.g., 3, 5, 10, 25, 50 referrals).

This requires:

BACKEND:
- New `rewards` table (milestone, name, description, type, redemption instructions, etc.)
- New `earned_rewards` table (subscriber_id, reward_id, earned_at, redeemed_at, 
  redemption_code, etc.)
- New Reward and EarnedReward models
- New RewardService for checking eligibility and granting rewards
- Hook into existing referral verification to auto-check for rewards
- Email notification when reward is earned (RewardEarnedMail)
- Filament resources for managing rewards and earned rewards
- Seed data with 6 default reward tiers

FRONTEND:
- API endpoints: GET /api/rewards, GET /api/my-rewards, GET /api/my-rewards/progress
- RewardsShowcase component (shows available rewards)
- RewardsProgress component (progress bar to next milestone)
- Update profile page to show earned rewards

PROPOSED REWARD TIERS (from PRD):
1. 🎉 Community Builder (1 referral) - Digital badge
2. ☕ Local Love (3 referrals) - $5 coffee shop gift card
3. 🎟️ High Five (5 referrals) - 2 event tickets OR $10 restaurant gift card
4. ⭐ VIP Status (10 referrals) - Newsletter swag + profile feature
5. 🏆 Champion (25 referrals) - $50 gift card + lifetime VIP
6. 👑 Legend (50 referrals) - $100 gift card + dinner with team

IMPLEMENTATION PLAN:
The full plan is in: DLCs/features/03-referral-rewards/PLAN.md  
The PRD is in: DLCs/features/03-referral-rewards/PRD.md

Please read both files and implement this feature following the phase-by-phase plan:
- Phase 1: Database schema (45 min)
- Phase 2: Models & services (1 hour)
- Phase 3: Filament admin panel (1 hour)
- Phase 4: Integration & automation (45 min)
- Phase 5: Frontend integration (1.5 hours)

KEY FILES TO CREATE:
- database/migrations/YYYY_MM_DD_create_rewards_table.php
- database/migrations/YYYY_MM_DD_create_earned_rewards_table.php
- database/seeders/RewardSeeder.php
- app/Models/Reward.php
- app/Models/EarnedReward.php
- app/Services/RewardService.php
- app/Filament/Resources/RewardResource.php
- app/Filament/Resources/EarnedRewardResource.php
- app/Mail/RewardEarnedMail.php
- resources/views/emails/rewards/earned.blade.php
- app/Http/Controllers/Api/RewardController.php

KEY FILES TO MODIFY:
- app/Models/Subscriber.php (add earnedRewards relationship)
- routes/api.php (add reward endpoints)
- Wherever referrals are verified (call RewardService::checkAndGrantRewards)

CRITICAL INTEGRATION POINT:
Find where referrals are verified/confirmed in your codebase (likely in a 
SubscriberService or similar). After verification, add:

```php
$rewardService = app(RewardService::class);
$rewardService->checkAndGrantRewards($subscriber);
```

After implementation, test by:
1. Creating rewards in admin panel
2. Simulating a subscriber reaching 3 referrals
3. Verifying reward is auto-granted
4. Checking email notification was sent
5. Viewing reward in subscriber's profile
6. Marking reward as redeemed

Please implement this feature now, starting with the backend (Phases 1-4), then 
move to frontend integration (Phase 5).
```

---

## 🎯 PROMPT 4: Partner Newsletter Cross-Promotions (DLC-04)

```
I need you to implement a Partner Newsletter Cross-Promotions System for my local newsletter application.

PROJECT CONTEXT:
Hudson Life Dispatch is a curated weekly newsletter for the Hudson Valley region. We 
send newsletters via Resend to subscribers. Currently, we have no structured way to 
partner with other local newsletters for cross-promotion (newsletter swaps). This is 
a missed growth opportunity - other newsletters in adjacent areas (Catskills, Peekskill, 
Tarrytown) have similar audiences and we could do free promotional swaps instead of 
paying for ads.

TECH STACK:
- Backend: Laravel (PHP 8.2+) with Filament admin panel - runs on localhost:8000
- Frontend: Next.js 15 (TypeScript) with Clerk auth - runs on localhost:3000
- Database: SQLite (database/database.sqlite) with Eloquent ORM
- Admin URL: localhost:8000/admin (Filament panel)
- Email: Resend API
- Newsletter system: Already built with automated content generation

CURRENT PROBLEM:
- No database of partner newsletters
- No way to schedule cross-promotions
- No tracking of partner referral performance
- Can't measure partnership ROI
- Manual, ad-hoc promotion requests with no structure

FEATURE REQUIREMENTS (from PRD):
Build a partner newsletter cross-promotion system where admins can manage partner 
relationships, schedule promotional placements, track performance with UTM parameters, 
and measure ROI.

This requires:

BACKEND:
- New `partner_newsletters` table (name, slug, contact info, subscriber count, status, 
  agreement terms, etc.)
- New `cross_promotions` table (partner_id, newsletter_id, scheduled_date, content, 
  tracking_link, clicks, conversions, etc.)
- New `partner_clicks` table (detailed click tracking with IP, user agent, conversion)
- New PartnerNewsletter, CrossPromotion, PartnerClick models
- New CrossPromotionService for tracking link generation and analytics
- Filament resources for managing partners and promotions
- Analytics dashboard showing partner performance (CTR, conversions, ROI)

FRONTEND (OPTIONAL FOR V1):
- Partner showcase component in newsletters
- UTM parameter handling for attribution
- Public partner directory page (optional)

KEY WORKFLOWS:

1. **Add Partner**
   - Admin adds partner newsletter details
   - Set agreement terms (e.g., "1:1 swap monthly")
   - Activate partnership

2. **Schedule Promotion**
   - Select partner and date
   - Write promo content (headline, description, CTA)
   - System auto-generates tracking link with UTM parameters
   - Insert into newsletter template

3. **Track Performance**
   - Track clicks via unique UTM parameters
   - Track conversions (click → subscribe)
   - View analytics dashboard with CTR, conversion rate, ROI

4. **Manage Reciprocity**
   - Track when partners feature us
   - Ensure agreement terms are fulfilled

UTM TRACKING STRUCTURE:
```
utm_source=hudson-life-dispatch
utm_medium=newsletter
utm_campaign={partner-slug}
utm_content=promo-{promo-id}
```

PARTNERSHIP MODELS (from PRD):
- **Equal Swap:** Both newsletters promote each other once per month
- **Proportional Swap:** Ratio based on subscriber count difference
- **Coalition:** 3-5 newsletters rotate recommendations

TARGET PARTNERS:
- Catskill Crew (Catskills region)
- Peekskill Post (Peekskill)
- Tarrytown Today (Tarrytown)
- Hudson Valley Magazine newsletter

IMPLEMENTATION PLAN:
The full plan is in: DLCs/features/04-cross-promotions/PLAN.md
The PRD is in: DLCs/features/04-cross-promotions/PRD.md

Please read both files and implement this feature following the phase-by-phase plan:
- Phase 1: Database schema (45 min) - 3 migration files
- Phase 2: Models (30 min) - 3 models with relationships
- Phase 3: Service layer (45 min) - CrossPromotionService
- Phase 4: Filament admin resources (1.5 hours) - 2 resources with analytics
- Phase 5: Testing (30 min)

KEY FILES TO CREATE:
- database/migrations/YYYY_MM_DD_create_partner_newsletters_table.php
- database/migrations/YYYY_MM_DD_create_cross_promotions_table.php
- database/migrations/YYYY_MM_DD_create_partner_clicks_table.php
- app/Models/PartnerNewsletter.php
- app/Models/CrossPromotion.php
- app/Models/PartnerClick.php
- app/Services/CrossPromotionService.php
- app/Filament/Resources/PartnerNewsletterResource.php
- app/Filament/Resources/CrossPromotionResource.php
- app/Filament/Resources/PartnerNewsletterResource/Pages/PartnerAnalytics.php
- app/Http/Controllers/Api/PartnerNewsletterController.php
- app/Http/Controllers/TrackingController.php (for click tracking endpoint)

KEY FILES TO MODIFY:
- routes/api.php (add partner endpoints and tracking endpoint)
- app/Filament/Resources/NewsletterResource.php (optionally add partner promo insertion)

CRITICAL FEATURES:

1. **Tracking Link Generation:**
```php
public function generateTrackingLink(PartnerNewsletter $partner, CrossPromotion $promo): string
{
    $baseUrl = $partner->subscribe_url;
    $utmParams = http_build_query([
        'utm_source' => 'hudson-life-dispatch',
        'utm_medium' => 'newsletter',
        'utm_campaign' => $partner->slug,
        'utm_content' => 'promo-' . $promo->id,
    ]);
    return $baseUrl . '?' . $utmParams;
}
```

2. **Click Tracking:**
   - Create tracking endpoint: GET /api/track/partner/{promo}
   - Increment click counter
   - Log detailed click with IP/user agent
   - Redirect to partner subscribe URL

3. **Analytics Dashboard:**
   - Total clicks per partner
   - Total conversions per partner
   - Average CTR (clicks / impressions)
   - Conversion rate (conversions / clicks)
   - Charts showing trends over time

NEWSLETTER INTEGRATION EXAMPLE:
```
─────────────────────────────────────────────────────
📮 RECOMMENDED NEWSLETTER

Catskill Crew
Your weekly guide to culture, events, and hidden gems 
in the Catskills.

Perfect if you love discovering unique local experiences!

[Subscribe to Catskill Crew →]
─────────────────────────────────────────────────────
```

SUCCESS METRICS:
After 60 days:
- 5+ active partner relationships
- 10%+ of new subscribers from partner referrals
- 2%+ average click-through rate
- 15%+ conversion rate (click → subscribe)
- $0 cost per acquisition (vs. $5-20 for paid ads)

After implementation, test by:
1. Creating a partner newsletter in admin panel
2. Activating the partnership
3. Scheduling a cross-promotion for today
4. Generating tracking link
5. Clicking the tracking link
6. Verifying click is tracked in database
7. Simulating a conversion
8. Viewing analytics dashboard
9. Checking partner performance metrics
10. Marking promotion as sent

BONUS: OUTREACH EMAIL TEMPLATE
Once system is built, use this to contact partners:

```
Subject: Partnership Opportunity: Newsletter Cross-Promotion

Hi [Name],

I'm [Your Name], editor of Hudson Life Dispatch, a weekly newsletter 
covering events, news, and culture in Hudson Valley.

I love what you're doing with [Partner Newsletter] and think our 
audiences would appreciate each other's content.

Would you be interested in a cross-promotion? Here's what I'm thinking:
- We feature each other once per month
- Same placement type (mid-newsletter recommendation)
- Track performance together
- No cost - mutual benefit

We currently have [X] subscribers with [Y]% open rate.

Interested? Let's grow together!

Best,
[Your Name]
```

Please implement this feature now, starting with the backend (Phases 1-4). Frontend 
integration can be added later if needed. Focus on:
1. Partner management in admin panel
2. Promotion scheduling
3. Tracking link generation
4. Click/conversion tracking
5. Analytics dashboard

This is the most complex of the 4 DLC features, so take it phase by phase and test 
each part thoroughly.
```

---

## ✅ KEY CORRECTIONS MADE:

1. **Database:** SQLite (database/database.sqlite) - NOT NeonDB, NOT PostgreSQL
2. **Backend Port:** localhost:8000 - confirmed
3. **Frontend Port:** localhost:3000 - confirmed
4. **Admin URL:** localhost:8000/admin - confirmed

All other details remain accurate. These prompts are now ready to use!

