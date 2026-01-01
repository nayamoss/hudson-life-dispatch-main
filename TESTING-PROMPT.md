Test all advertising system features implemented in this Laravel backend:

**Phase 3 - Newsletter Ads:**
- Check NewsletterAdService exists with methods: getAdForSlot, processNewsletterSnippets
- Verify 3 email templates exist: native-inline.blade.php, banner.blade.php, text-mention.blade.php
- Test routes work: GET /api/ads/{id}/track.gif, GET /api/ads/{id}/redirect
- Confirm newsletter_position field exists in ads table

**Phase 4 - Advanced Features:**
- Test AdRotationService with 4 rotation strategies
- Verify ABTestService with statistical significance calculation
- Check ad_variations and ad_reports tables exist
- Test POST /api/ads/{id}/report endpoint
- Verify SendSponsorPerformanceReports command exists
- Check sponsor dashboard routes work: /sponsor/dashboard

**Phase 5 - Admin Enhancements:**
- Verify ad preview shows in AdResource
- Test duplicate action works in admin
- Check bulk operations (activate, pause, set status)
- Confirm AdTemplate model and resource exist
- Test "Create Ad from Template" functionality

**Phase 6 - Analytics:**
- Verify AdAnalyticsDashboard widget shows in admin
- Test EngagementScoringService calculates scores 0-100
- Run command: php artisan ads:update-engagement-scores

Check for any missing files, broken imports, or syntax errors. Report what works and what doesn't.

