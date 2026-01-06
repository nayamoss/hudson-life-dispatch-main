# PRD: Referral Rewards System

**Feature ID:** DLC-03  
**Author:** AI Development Team  
**Date:** January 5, 2026  
**Status:** Draft

---

## 1. Executive Summary

Build a milestone-based rewards system that incentivizes subscribers to refer friends. Users earn prizes at referral thresholds (3, 5, 10, 25, 50+ referrals). This drives newsletter growth through word-of-mouth marketing.

---

## 2. Background

### Current State
- Referral tracking system exists
- Leaderboard shows top referrers
- No rewards or incentives configured
- No notifications for milestones reached
- Low referral participation rate

### Desired State
- Tiered milestone rewards (digital + physical)
- Automatic reward eligibility tracking
- Email notifications for earned rewards
- Simple redemption process
- Admin dashboard for reward management

---

## 3. Goals & Objectives

### Primary Goals
1. Increase subscriber referral rate from <5% to 20%+
2. Drive newsletter growth through incentivized sharing
3. Build community engagement and loyalty

### Secondary Goals
- Partner with local businesses for sponsored rewards
- Create social proof with reward showcase
- Generate UGC (users sharing rewards on social)

### Non-Goals
- Cash/monetary rewards (legal/tax complexity)
- Automated physical fulfillment (manual for v1)
- Integration with external reward platforms

---

## 4. User Personas

### Primary: Active Subscriber (Maria)
- **Demographics:** 35, Hudson Valley resident, engaged community member
- **Motivation:** Wants to share newsletter with friends, loves local perks
- **Goal:** Earn coffee shop gift card by referring 5 friends
- **Behavior:** Shares referral link on Facebook and neighborhood group

### Secondary: Admin (Sarah)
- **Role:** Newsletter editor
- **Goal:** Manage reward program efficiently
- **Need:** Simple dashboard to track rewards and fulfillment

---

## 5. Requirements

### Functional Requirements

#### FR-1: Reward Configuration
**Admin can create rewards with:**
- Name (e.g., "Coffee Lover Badge")
- Description (what user gets)
- Milestone (e.g., 5 referrals)
- Reward type (badge, discount, swag, feature)
- Active/inactive status
- Redemption instructions
- Image/icon
- Sponsor info (optional)

#### FR-2: Milestone Tracking
**System automatically:**
- Checks referral count on each new referral
- Grants rewards when milestone reached
- Prevents duplicate reward grants
- Logs reward grant date/time

#### FR-3: Reward Notifications
**User receives:**
- Email when reward earned
- In-app notification (if logged in)
- Reminder if not redeemed within 30 days

#### FR-4: Redemption Flow
**User can:**
- View earned rewards on profile
- See redemption instructions
- Mark reward as redeemed (self-service)
- Contact admin for fulfillment help

#### FR-5: Admin Dashboard
**Admin can:**
- View all rewards and milestones
- See earned rewards (pending/redeemed)
- Manually grant special rewards
- Track reward program metrics
- Export fulfillment list

#### FR-6: Public Rewards Showcase
**On referral page, show:**
- All available rewards
- Milestone requirements
- Visual progress bar
- Testimonials from winners

### Non-Functional Requirements

#### NFR-1: Performance
- Reward eligibility check executes in <100ms
- Notification sent within 1 minute of milestone

#### NFR-2: Scalability
- Support 10,000+ subscribers
- Handle 1,000+ simultaneous reward checks

#### NFR-3: Data Integrity
- Prevent double-rewarding
- Accurate referral counts
- Audit log for all reward grants

---

## 6. Reward Tiers (Proposed)

### Tier 1: First Referral (1 referral)
**🎉 Welcome Bonus**
- Digital badge: "Community Builder"
- Thank you email with social share graphic
- **Goal:** Encourage first share

### Tier 2: Triple Threat (3 referrals)
**☕ Local Love**
- $5 gift card to partnered local coffee shop
- Featured on "Top Referrers" page
- **Goal:** Show real value, build momentum

### Tier 3: High Five (5 referrals)
**🎟️ Experience Reward**
- 2 free tickets to local event
- OR: $10 gift card to local restaurant
- Custom digital certificate
- **Goal:** Meaningful local reward

### Tier 4: Perfect Ten (10 referrals)
**⭐ VIP Status**
- Exclusive newsletter swag (t-shirt, mug)
- Profile feature in newsletter
- VIP badge on leaderboard
- **Goal:** Status and recognition

### Tier 5: Power Referrer (25 referrals)
**🏆 Champion**
- $50 gift card to business of choice
- Lifetime VIP status
- Invite to exclusive community event
- **Goal:** Reward super-advocates

### Tier 6: Legend (50+ referrals)
**👑 Community Legend**
- $100 gift card bundle
- Permanent profile on "Legends" page
- Dinner with newsletter team
- Custom community spotlight article
- **Goal:** Create aspirational tier

---

## 7. User Experience

### Flow Diagram

```
User Signs Up
     │
     ▼
Get Referral Link
     │
     ▼
Share with Friends ──► Friend Subscribes ──► Referral Count++
     │                                              │
     │                                              ▼
     │                                    Check Milestones
     │                                              │
     │                                    ┌─────────┴─────────┐
     │                                    │                   │
     │                              No Milestone        Milestone!
     │                                    │                   │
     │                                    └───────────────────┘
     │                                                        │
     │                                                        ▼
     │                                              Grant Reward
     │                                                        │
     │                                                        ▼
     │◄───────────────────────────────────────────────Send Email
     │
     ▼
View Profile
     │
     ▼
See Earned Rewards
     │
     ▼
Click "Redeem" ──► View Instructions ──► Mark Redeemed
```

### UI Mockups

#### Rewards Showcase (Public Page)

```
┌────────────────────────────────────────────────────┐
│  🎁 Referral Rewards Program                       │
├────────────────────────────────────────────────────┤
│  Share Hudson Life Dispatch with friends and earn  │
│  amazing rewards from local businesses!            │
│                                                     │
│  Your Progress: 2 / 3 referrals                   │
│  [████████░░░░░░░░] Next reward: ☕ Local Love     │
│                                                     │
├────────────────────────────────────────────────────┤
│  Available Rewards:                                │
│                                                     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐│
│  │     ☕       │  │     🎟️       │  │    ⭐    ││
│  │ LOCAL LOVE   │  │ HIGH FIVE    │  │ VIP      ││
│  │ 3 referrals  │  │ 5 referrals  │  │ 10 refs  ││
│  │              │  │              │  │          ││
│  │ $5 coffee    │  │ 2 tickets    │  │ Swag     ││
│  │ gift card    │  │ OR $10       │  │ Featured ││
│  └──────────────┘  └──────────────┘  └──────────┘│
│                                                     │
│  [Share Your Link]  [View Leaderboard]             │
└────────────────────────────────────────────────────┘
```

#### Profile Page - Rewards Section

```
┌────────────────────────────────────────────────────┐
│  Your Earned Rewards                               │
├────────────────────────────────────────────────────┤
│  🎉 Community Builder                    REDEEMED  │
│  Earned: Jan 2, 2026                               │
│                                                     │
│  ☕ Local Love                           [REDEEM]  │
│  Earned: Jan 5, 2026                               │
│  » View Redemption Instructions                    │
│                                                     │
├────────────────────────────────────────────────────┤
│  Coming Soon:                                      │
│  🎟️ High Five - 3 more referrals needed!         │
│  Progress: [████████████░░░░] 2/5                 │
└────────────────────────────────────────────────────┘
```

#### Email Notification

```
Subject: 🎉 You earned a reward!

Hi Maria,

Congratulations! You've referred 3 friends to Hudson Life 
Dispatch and earned the "Local Love" reward!

☕ Your Reward: $5 Gift Card to Birdsall House

How to Redeem:
1. Visit Birdsall House in Peekskill
2. Show this email at checkout
3. Enjoy your reward!

Code: HLD-MARIA-2026-001
Expires: February 5, 2026

Keep sharing! Your next reward is at 5 referrals.

[Share Your Link] [View All Rewards]
```

---

## 8. Technical Design

### Database Schema

#### Rewards Table
```sql
CREATE TABLE rewards (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    milestone INT UNSIGNED NOT NULL,
    reward_type ENUM('badge', 'discount', 'swag', 'feature', 'experience') DEFAULT 'badge',
    redemption_instructions TEXT,
    image_url VARCHAR(500),
    sponsor_name VARCHAR(255) NULL,
    sponsor_logo_url VARCHAR(500) NULL,
    active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    INDEX idx_milestone (milestone),
    INDEX idx_active (active)
);
```

#### Earned Rewards Table
```sql
CREATE TABLE earned_rewards (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    subscriber_id BIGINT UNSIGNED NOT NULL,
    reward_id BIGINT UNSIGNED NOT NULL,
    earned_at TIMESTAMP NOT NULL,
    notified_at TIMESTAMP NULL,
    redeemed_at TIMESTAMP NULL,
    redemption_code VARCHAR(50) UNIQUE,
    redemption_notes TEXT NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (subscriber_id) REFERENCES subscribers(id) ON DELETE CASCADE,
    FOREIGN KEY (reward_id) REFERENCES rewards(id) ON DELETE CASCADE,
    UNIQUE KEY unique_subscriber_reward (subscriber_id, reward_id),
    INDEX idx_redeemed (redeemed_at)
);
```

### Backend Service

```php
// app/Services/RewardService.php
class RewardService
{
    public function checkAndGrantRewards(Subscriber $subscriber): void
    {
        $referralCount = $subscriber->referrals()->verified()->count();
        
        $eligibleRewards = Reward::where('active', true)
            ->where('milestone', '<=', $referralCount)
            ->get();
        
        foreach ($eligibleRewards as $reward) {
            $this->grantRewardIfNotEarned($subscriber, $reward);
        }
    }
    
    protected function grantRewardIfNotEarned(Subscriber $subscriber, Reward $reward): void
    {
        $alreadyEarned = EarnedReward::where('subscriber_id', $subscriber->id)
            ->where('reward_id', $reward->id)
            ->exists();
        
        if ($alreadyEarned) {
            return;
        }
        
        $earnedReward = EarnedReward::create([
            'subscriber_id' => $subscriber->id,
            'reward_id' => $reward->id,
            'earned_at' => now(),
            'redemption_code' => $this->generateRedemptionCode($subscriber, $reward),
        ]);
        
        $this->sendRewardNotification($subscriber, $earnedReward);
    }
    
    protected function generateRedemptionCode(Subscriber $subscriber, Reward $reward): string
    {
        return 'HLD-' . strtoupper(substr($subscriber->email, 0, 5)) . '-' . date('Y') . '-' . str_pad($reward->id, 3, '0', STR_PAD_LEFT);
    }
    
    protected function sendRewardNotification(Subscriber $subscriber, EarnedReward $earnedReward): void
    {
        Mail::to($subscriber->email)
            ->send(new RewardEarnedMail($subscriber, $earnedReward));
        
        $earnedReward->update(['notified_at' => now()]);
    }
}
```

### API Endpoints

```php
// routes/api.php

// Get available rewards (public)
Route::get('/rewards', [RewardController::class, 'index']);

// Get subscriber's earned rewards (protected)
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/my-rewards', [RewardController::class, 'myRewards']);
    Route::post('/rewards/{earnedReward}/redeem', [RewardController::class, 'markRedeemed']);
});
```

---

## 9. Success Criteria

### Launch Criteria
- ✅ At least 3 reward tiers configured
- ✅ Reward notification emails work
- ✅ Redemption flow tested end-to-end
- ✅ Admin dashboard functional

### Post-Launch Metrics (60 days)

#### Engagement Metrics
- **Referral Rate:** 20%+ of subscribers make ≥1 referral
- **Avg Referrals per Referrer:** 3+ (up from current 1.2)
- **Milestone Achievement:** 40% of referrers earn at least Tier 1 reward

#### Growth Metrics
- **Subscriber Growth:** 50%+ increase in new signups
- **Referral-Driven Signups:** 30%+ of new subscribers from referrals
- **Viral Coefficient:** 0.5+ (each subscriber brings 0.5+ new subscribers)

#### Redemption Metrics
- **Redemption Rate:** 80%+ of earned rewards redeemed
- **Time to Redeem:** <14 days average
- **Redemption Feedback:** 90%+ satisfaction

---

## 10. Monetization & Partnerships

### Sponsored Rewards
Partner with local businesses to sponsor reward tiers:

**Benefits to Sponsors:**
- Brand exposure to engaged local audience
- Logo on rewards page
- Featured in reward notification emails
- Trackable redemptions

**Pricing Model:**
- **Tier 1 Sponsor:** $200/month - 1 referral reward
- **Tier 2 Sponsor:** $500/month - 3 referral reward
- **Tier 3 Sponsor:** $1,000/month - 5 referral reward
- **Tier 4 Sponsor:** $2,000/month - 10 referral reward

**ROI Calculation:**
- 1,000 subscribers × 20% referral rate = 200 referrers
- 200 referrers × 3 avg referrals = 600 new subscribers
- 600 new subscribers × 30% reach Tier 2 (3 refs) = 180 rewards
- Cost per redemption: $500/180 = $2.78
- Value to business: Customer acquisition cost typically $10-50

---

## 11. Out of Scope (Future Enhancements)

- Automated physical fulfillment integration
- Points system (flexible rewards instead of fixed milestones)
- Expiring rewards (time limits)
- Team/group referral competitions
- Charity donation option instead of rewards
- Referral attribution tracking (which channel/post drove signup)
- A/B testing reward offers

---

## 12. Open Questions

### Q1: Should rewards expire?
**Answer:** Yes, 90 days after earning. Prevents abuse and creates urgency.

### Q2: What if someone games the system (fake referrals)?
**Answer:** 
- Require email verification
- Monitor for suspicious patterns (same IP, disposable emails)
- Admin ability to revoke rewards
- Terms of service against fraud

### Q3: Who handles physical reward fulfillment?
**Answer:** Admin manually for v1. Batch monthly.

### Q4: Can users see what others earned?
**Answer:** No, privacy first. Only show aggregated stats.

---

## 13. Appendix

### Competitive Analysis

| Platform | Referral Rewards? | Tiers | Reward Types |
|----------|------------------|-------|--------------|
| Morning Brew | ✅ | 5 | Swag, mugs, hoodies |
| The Hustle | ✅ | 6 | Gifts, courses, premium |
| Milk Road | ✅ | 4 | Merch, NFTs, access |
| Local newsletters | ❌ | - | Not common |

**Insight:** B2C newsletters commonly use rewards, but local newsletters rarely do. Opportunity to differentiate!

### Legal Considerations
- Terms of service: No purchase necessary
- Anti-fraud clause
- Reward substitution rights
- Tax implications: Under $600 annually per user
- Privacy: Don't share recipient info with sponsors

### Research Citations
- Dropbox referral program case study: 60% growth from referrals
- ReferralCandy: Referred customers have 16% higher lifetime value
- Ambassador: Peer recommendations 5x more trusted than ads

