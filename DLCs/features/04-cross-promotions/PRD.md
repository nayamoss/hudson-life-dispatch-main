# PRD: Partner Newsletter Cross-Promotions

**Feature ID:** DLC-04  
**Author:** AI Development Team  
**Date:** January 5, 2026  
**Status:** Draft

---

## 1. Executive Summary

Build a system for cross-promoting with partner newsletters to drive mutual subscriber growth. This includes partner management, scheduled promotions, tracking links, and performance analytics.

---

## 2. Background

### Current State
- No structured partner relationships
- Manual, ad-hoc promotion requests
- No tracking of partner referral performance
- Can't measure partnership ROI

### Desired State
- Database of partner newsletters
- Scheduled cross-promotion placements
- Automatic UTM tracking for attribution
- Dashboard showing partner performance
- Reciprocal promotion workflows

---

## 3. Goals & Objectives

### Primary Goals
1. Drive 10%+ of new subscribers from partner referrals
2. Establish 5+ active partner relationships within 60 days
3. Achieve 2%+ click-through rate on partner promos
4. Demonstrate clear ROI for each partnership

### Secondary Goals
- Build local newsletter coalition
- Share best practices with partners
- Create co-marketing opportunities
- Increase brand awareness in adjacent markets

### Non-Goals
- Paid newsletter placements (free swaps only for v1)
- External ad network integration
- Programmatic ad buying
- Affiliate commission system

---

## 4. User Personas

### Primary: Newsletter Admin (Sarah)
- **Role:** Editor & Growth Manager
- **Goal:** Grow subscriber base through partnerships
- **Pain:** Manual tracking, hard to measure effectiveness
- **Need:** Simple system to manage and track partners

### Secondary: Potential Partner (Tom)
- **Role:** Editor at neighboring newsletter
- **Goal:** Grow his newsletter too
- **Value Prop:** Mutual benefit, shared audiences

---

## 5. Requirements

### Functional Requirements

#### FR-1: Partner Newsletter Management
**Admin can add partners with:**
- Newsletter name
- Publisher/contact name
- Email and website
- Target audience description
- Geographic focus
- Subscriber count
- Agreement terms (swap ratio, frequency)
- Status (prospective, active, paused, ended)
- Notes

#### FR-2: Cross-Promotion Placements
**Admin can schedule promos with:**
- Partner selection
- Promotion type (mention, feature, full ad)
- Scheduled date
- Content (headline, description, CTA, link)
- Image/logo
- Position in newsletter (header, mid, footer)
- Status (scheduled, sent, cancelled)

#### FR-3: Tracking Links
**System automatically generates:**
- Unique UTM parameters per partner
  - `utm_source=partner-newsletter`
  - `utm_medium=newsletter`
  - `utm_campaign={partner-slug}`
- Short tracking links
- Click tracking
- Conversion tracking (click → subscribe)

#### FR-4: Performance Analytics
**Dashboard shows:**
- Clicks per partner
- Subscribers per partner
- Click-through rate (CTR)
- Conversion rate
- Lifetime value per partner
- ROI metrics
- Trend charts

#### FR-5: Reciprocal Tracking
**Track our promotions in partner newsletters:**
- When we're featured
- Expected vs. actual traffic
- Fulfillment of agreement terms

#### FR-6: Newsletter Integration
**Auto-insert partner promos:**
- Select partner of the week
- Auto-generate promo content
- Insert into newsletter template
- Track inclusion in sent newsletters

### Non-Functional Requirements

#### NFR-1: Performance
- Tracking links redirect in <100ms
- Analytics dashboard loads in <2 seconds

#### NFR-2: Data Integrity
- Accurate click attribution
- No double-counting conversions
- Prevent link manipulation

#### NFR-3: Privacy
- Respect user privacy
- GDPR/CCPA compliant tracking
- Anonymous aggregate reporting

---

## 6. Partnership Models

### Model 1: Equal Swap (Recommended)
- Both newsletters promote each other once per month
- Similar audience sizes
- Same placement type
- No money exchanged

### Model 2: Proportional Swap
- Larger newsletter promotes smaller one less frequently
- Ratio based on subscriber count difference
- E.g., 10K newsletter promotes 2K newsletter 1x, gets 5x back

### Model 3: Coalition
- 3-5 newsletters rotate recommendations
- "Local Newsletter Collective" branding
- Shared growth, community focus

---

## 7. User Experience

### Admin Workflow

```
1. Add Partner Newsletter
   ├─ Enter details
   ├─ Set agreement terms
   └─ Activate partnership

2. Schedule Promotion
   ├─ Select partner
   ├─ Choose date
   ├─ Write promo content
   └─ Generate tracking link

3. Newsletter Send
   ├─ Auto-insert partner promo
   ├─ Send newsletter
   └─ Track performance

4. Review Analytics
   ├─ View partner dashboard
   ├─ Check fulfillment
   └─ Optimize partnerships
```

### Subscriber Experience

```
Subscriber reads newsletter
       │
       ▼
Sees partner recommendation
"📮 Check out Catskill Crew - weekly culture newsletter"
       │
       ▼
Clicks link (UTM tracked)
       │
       ▼
Lands on partner signup page
       │
       ▼
Subscribes (conversion tracked)
```

### UI Mockups

#### Admin: Partner Management Table

```
┌─────────────────────────────────────────────────────────────┐
│ Partner Newsletters                         [+ Add Partner]  │
├─────────────────────────────────────────────────────────────┤
│ Name             │ Status   │ Subscribers │ Our Promos │ CTR │
├──────────────────┼──────────┼─────────────┼────────────┼─────┤
│ Catskill Crew    │ Active   │ 12,000      │ 3          │ 2.8%│
│ Peekskill Post   │ Active   │ 8,500       │ 2          │ 1.9%│
│ Hudson Valley Now│ Paused   │ 25,000      │ 1          │ 3.2%│
│ Local Lives      │ Prospect │ 5,000       │ 0          │ —   │
└─────────────────────────────────────────────────────────────┘
```

#### Admin: Schedule Cross-Promotion

```
┌─────────────────────────────────────────────────────┐
│ Schedule Partner Promotion                          │
├─────────────────────────────────────────────────────┤
│ Partner Newsletter:                                 │
│ [Catskill Crew ▼]                                   │
│                                                     │
│ Scheduled Date:                                     │
│ [Jan 15, 2026 ▼]                                    │
│                                                     │
│ Promotion Type:                                     │
│ [○ Mention  ● Feature  ○ Full Ad]                  │
│                                                     │
│ Content:                                            │
│ ┌─────────────────────────────────────────────────┐│
│ │ Check out Catskill Crew - the best weekly      ││
│ │ newsletter for culture and events in the        ││
│ │ Catskills region!                               ││
│ └─────────────────────────────────────────────────┘│
│                                                     │
│ Call to Action:                                     │
│ [Subscribe to Catskill Crew →]                     │
│                                                     │
│ Position:                                           │
│ [○ Header  ● Mid-newsletter  ○ Footer]             │
│                                                     │
│ Tracking Link:                                      │
│ https://catskillcrew.com/?utm_source=hld...        │
│ [Copy Link]                                         │
│                                                     │
│              [Cancel]  [Schedule Promotion]         │
└─────────────────────────────────────────────────────┘
```

#### Newsletter: Partner Recommendation Block

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

#### Admin: Partner Performance Dashboard

```
┌─────────────────────────────────────────────────────────┐
│ Partner Performance (Last 30 Days)                      │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  Total Partner Clicks: 245                              │
│  New Subscribers from Partners: 31                      │
│  Average CTR: 2.4%                                      │
│  Average Conversion Rate: 18.7%                         │
│                                                         │
├─────────────────────────────────────────────────────────┤
│ Top Performing Partners:                                │
│                                                         │
│ 1. Hudson Valley Now - 15 subs (48% conv rate) ⭐      │
│ 2. Catskill Crew - 10 subs (32% conv rate)             │
│ 3. Peekskill Post - 6 subs (19% conv rate)             │
│                                                         │
├─────────────────────────────────────────────────────────┤
│ [Chart: Clicks & Conversions Over Time]                │
│                                                         │
│   │                                                     │
│ 20│           ●                                         │
│ 15│     ●           ●                                   │
│ 10│ ●       ●             ●                             │
│  5│                             ●                       │
│   └─────────────────────────────────────                │
│    W1   W2   W3   W4   W5   W6                         │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 8. Technical Design

### Database Schema

#### Partner Newsletters Table
```sql
CREATE TABLE partner_newsletters (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    publisher_name VARCHAR(255),
    contact_email VARCHAR(255),
    website_url VARCHAR(500),
    subscribe_url VARCHAR(500),
    description TEXT,
    audience_focus TEXT,
    geographic_focus VARCHAR(255),
    subscriber_count INT UNSIGNED,
    frequency ENUM('daily', 'weekly', 'biweekly', 'monthly') DEFAULT 'weekly',
    status ENUM('prospective', 'active', 'paused', 'ended') DEFAULT 'prospective',
    agreement_terms TEXT,
    logo_url VARCHAR(500),
    notes TEXT,
    activated_at TIMESTAMP NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    INDEX idx_status (status),
    INDEX idx_slug (slug)
);
```

#### Cross Promotions Table
```sql
CREATE TABLE cross_promotions (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    partner_newsletter_id BIGINT UNSIGNED NOT NULL,
    newsletter_edition_id BIGINT UNSIGNED NULL,
    scheduled_date DATE NOT NULL,
    promotion_type ENUM('mention', 'feature', 'full_ad') DEFAULT 'feature',
    headline VARCHAR(255),
    content TEXT,
    cta_text VARCHAR(100),
    tracking_link VARCHAR(500),
    image_url VARCHAR(500),
    position ENUM('header', 'mid', 'footer') DEFAULT 'mid',
    status ENUM('draft', 'scheduled', 'sent', 'cancelled') DEFAULT 'draft',
    sent_at TIMESTAMP NULL,
    clicks INT UNSIGNED DEFAULT 0,
    conversions INT UNSIGNED DEFAULT 0,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (partner_newsletter_id) REFERENCES partner_newsletters(id) ON DELETE CASCADE,
    FOREIGN KEY (newsletter_edition_id) REFERENCES newsletters(id) ON DELETE SET NULL,
    INDEX idx_scheduled_date (scheduled_date),
    INDEX idx_status (status),
    INDEX idx_partner (partner_newsletter_id)
);
```

#### Partner Clicks Table (for detailed tracking)
```sql
CREATE TABLE partner_clicks (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    cross_promotion_id BIGINT UNSIGNED NOT NULL,
    subscriber_id BIGINT UNSIGNED NULL,
    clicked_at TIMESTAMP NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    converted_at TIMESTAMP NULL,
    created_at TIMESTAMP,
    FOREIGN KEY (cross_promotion_id) REFERENCES cross_promotions(id) ON DELETE CASCADE,
    FOREIGN KEY (subscriber_id) REFERENCES subscribers(id) ON DELETE SET NULL,
    INDEX idx_clicked_at (clicked_at),
    INDEX idx_conversion (converted_at)
);
```

### Tracking Link Generation

```php
// app/Services/CrossPromotionService.php
class CrossPromotionService
{
    public function generateTrackingLink(PartnerNewsletter $partner, CrossPromotion $promo): string
    {
        $baseUrl = $partner->subscribe_url;
        
        $utmParams = http_build_query([
            'utm_source' => 'hudson-life-dispatch',
            'utm_medium' => 'newsletter',
            'utm_campaign' => $partner->slug,
            'utm_content' => $promo->id,
        ]);
        
        return $baseUrl . '?' . $utmParams;
    }
    
    public function trackClick(CrossPromotion $promo, ?Subscriber $subscriber = null): void
    {
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
    }
    
    public function trackConversion(PartnerNewsletter $partner, Subscriber $newSubscriber): void
    {
        // Find recent click from this subscriber (if they were subscribed)
        // Or match by UTM parameters if new signup
        
        $recentClick = PartnerClick::where('cross_promotion_id', $promo->id)
            ->where('clicked_at', '>=', now()->subDays(7))
            ->whereNull('converted_at')
            ->first();
        
        if ($recentClick) {
            $recentClick->update(['converted_at' => now()]);
            $promo->increment('conversions');
        }
    }
}
```

### API Endpoints

```php
// routes/api.php

// Tracking endpoint (when user clicks partner link)
Route::get('/track/partner/{promo}', [TrackingController::class, 'partnerClick']);

// Admin endpoints
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/partners', [PartnerNewsletterController::class, 'index']);
    Route::get('/partners/{partner}/analytics', [PartnerNewsletterController::class, 'analytics']);
});
```

---

## 9. Success Criteria

### Launch Criteria
- ✅ 2+ partner newsletters added
- ✅ 1 cross-promotion sent and tracked
- ✅ Analytics dashboard functional
- ✅ Tracking links work correctly

### Post-Launch Metrics (60 days)

#### Partnership Metrics
- **Partner Count:** 5+ active partners
- **Promo Frequency:** 1-2 partner features per newsletter
- **Reciprocity Rate:** 80%+ of partners reciprocate

#### Performance Metrics
- **Click-Through Rate:** 2%+ average CTR
- **Conversion Rate:** 15%+ (click → subscribe)
- **Partner Referral Share:** 10%+ of new subscribers from partners
- **Cost per Acquisition:** $0 (free swaps vs. $5-20 paid ads)

---

## 10. Partnership Outreach Plan

### Target Partners

**Tier 1: Geographic Neighbors**
- Catskill Crew (Catskills)
- Peekskill Post (Peekskill)
- Tarrytown Today (Tarrytown)
- **Why:** Overlapping but distinct geographic focus

**Tier 2: Vertical Alignment**
- Hudson Valley Magazine newsletter
- Hudson Valley Mom newsletter
- Hudson Valley Eats newsletter
- **Why:** Same region, different focus areas

**Tier 3: Similar Communities**
- Local newsletters in similar towns (Beacon, Cold Spring, etc.)
- **Why:** Audience similarities

### Outreach Email Template

```
Subject: Partnership Opportunity: Newsletter Cross-Promotion

Hi [Name],

I'm [Your Name], editor of Hudson Life Dispatch, a weekly newsletter 
covering events, news, and culture in [Your Area].

I love what you're doing with [Partner Newsletter] and think our 
audiences would appreciate each other's content.

Would you be interested in a cross-promotion? Here's what I'm thinking:
- We feature each other once per month
- Same placement type (e.g., mid-newsletter recommendation)
- Track performance and optimize together
- No cost - mutual benefit

We currently have [X] subscribers with [Y]% open rate.

Interested in chatting? I'd love to explore how we can grow together!

Best,
[Your Name]
```

---

## 11. Out of Scope (Future Enhancements)

- Paid sponsorship placements
- Programmatic ad network
- Affiliate revenue sharing
- A/B testing partner promos
- Automated partner matching
- API for partner data sharing
- White-label partner directory

---

## 12. Open Questions

### Q1: How often should we feature partners?
**Answer:** 1-2x per month max. Test subscriber tolerance.

### Q2: Should partners approve our promo content?
**Answer:** Yes, send for review 3 days before send.

### Q3: What if partner doesn't reciprocate?
**Answer:** Pause after 2 months, require fulfillment to continue.

### Q4: Share subscriber data with partners?
**Answer:** No. Aggregated analytics only.

---

## 13. Appendix

### Competitive Analysis

| Newsletter | Partner Promos? | Frequency | Style |
|------------|----------------|-----------|-------|
| Morning Brew | ✅ | Weekly | Dedicated section |
| The Hustle | ✅ | Monthly | Full ad block |
| Axios Local | ❌ | None | No partner promos |
| Local newsletters | 🟡 | Rare | Ad-hoc mentions |

**Insight:** Big newsletters do it, local newsletters don't. Opportunity!

### ROI Calculation

**Traditional Newsletter Ad Cost:**
- $50-200 per placement in similar newsletter
- 10 placements = $500-2,000

**Cross-Promotion (Free):**
- Cost: $0
- Benefit: Same exposure + reciprocal promotion
- ROI: Infinite vs. paid ads

### Legal Considerations
- Partnership terms of service
- Disclaimer about partner content
- Privacy: No data sharing without consent
- Endorsement disclosure (FTC compliance)

