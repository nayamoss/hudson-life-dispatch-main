# 📋 RESOURCE SCRAPING STRATEGY - BY CATEGORY

## Overview
833 total resources across 10 categories. Each needs a different strategy.

---

## 1. EVENTS (283 resources) - Highest Priority

### Breakdown:
- 202 HTML websites (event calendars)
- 34 Instagram accounts
- 25 Facebook pages
- 19 APIs (Eventbrite, Meetup)
- 2 Manual
- 1 RSS feed

### Strategy by Method:

#### APIs (19) - Eventbrite, Meetup, Google Events ⭐
**WHAT**: Structured event listings with dates, titles, descriptions  
**HOW**: Use their public APIs (Eventbrite has JSON-LD in HTML, Meetup has public pages)  
**WHEN**: **Daily** - Events get added/updated frequently  
**WHERE**: Eventbrite.com, Meetup.com search pages  
**WHY DAILY**: New events posted 1-7 days before they happen  
**PRIORITY**: 🔥 HIGHEST (easiest, most reliable)

#### HTML Event Calendars (202) - Museums, Libraries, Town Halls ⭐
**WHAT**: Calendar pages with event listings  
**HOW**: Parse HTML with DomCrawler, extract titles/dates/descriptions  
**WHEN**: Varies by source type:
  - **Weekly**: Most museums, libraries (update calendar once/week)
  - **Monthly**: Government meeting calendars (published monthly)
  - **Seasonal**: Annual events, holiday calendars
**WHERE**: /events, /calendar, /programs URLs  
**WHY VARIABLE**: Museums update weekly, towns monthly, festivals seasonal  
**PRIORITY**: 🔥 HIGH (consistent structure, valuable data)

**Sub-categories for HTML Events:**
- **Museums/Cultural (50+)**: Weekly scraping
- **Town/Government Events (30+)**: Monthly scraping  
- **Libraries (20+)**: Weekly scraping
- **Sports/Recreation (30+)**: Weekly scraping
- **Seasonal Festivals (20+)**: Seasonal scraping
- **Other venues (50+)**: Weekly default

#### Facebook Event Pages (25) ❌
**WHAT**: Event postings on Facebook pages  
**HOW**: Facebook Graph API (requires auth token) OR manual  
**WHEN**: Don't scrape - too difficult  
**WHY SKIP**: Requires Facebook auth, rate limits, breaks frequently  
**ALTERNATIVE**: Ask users to submit events directly  
**PRIORITY**: ⛔ SKIP for automation

#### Instagram Events (34) ❌  
**WHAT**: Event announcements in posts/stories  
**HOW**: Instagram API (requires auth) OR manual  
**WHEN**: Don't scrape  
**WHY SKIP**: Even harder than Facebook, stories expire  
**ALTERNATIVE**: Manual curation or user submissions  
**PRIORITY**: ⛔ SKIP for automation

#### RSS Feed (1) ⭐⭐⭐
**WHAT**: City of Peekskill iCalendar  
**HOW**: SimplePie RSS parser  
**WHEN**: **Daily** - RSS is instant, no overhead  
**WHY DAILY**: Free, fast, perfect format  
**PRIORITY**: 🔥🔥🔥 HIGHEST (do this first!)

---

## 2. LOCAL NEWS (61 resources)

### Breakdown:
- 40 HTML news sites
- 10 Facebook pages
- 3 RSS feeds
- 3 APIs (Google News)
- 3 Manual
- 2 Instagram

### Strategy:

#### HTML News Sites (40) - Hudson Independent, Patch, etc. ⭐
**WHAT**: Article headlines, summaries, publish dates  
**HOW**: Parse homepage or /news section, extract <article> tags  
**WHEN**: **Daily** - News published daily  
**WHERE**: Homepage, /news, /local sections  
**WHY DAILY**: News is time-sensitive  
**PRIORITY**: 🔥 HIGH (great content, usually easy HTML)

#### RSS Feeds (3) ⭐⭐⭐
**WHAT**: News article feeds  
**HOW**: SimplePie  
**WHEN**: **Daily**  
**WHY DAILY**: RSS is designed for this  
**PRIORITY**: 🔥🔥🔥 DO FIRST

#### APIs - Google News (3) ⭐
**WHAT**: News search results  
**HOW**: Parse Google News search HTML (no official API)  
**WHEN**: **Daily**  
**PRIORITY**: 🔥 HIGH

#### Facebook/Instagram News (12) ❌
**PRIORITY**: ⛔ SKIP

---

## 3. SCHOOL NEWS (65 resources)

### Breakdown:
- 48 HTML school websites
- 13 Facebook pages
- 4 Instagram accounts

### Strategy:

#### HTML School Sites (48) - District websites, PTSA ⭐
**WHAT**: School news, announcements, calendars, job postings  
**HOW**: Parse /news, /announcements, /calendar pages  
**WHEN**: **Weekly** - Schools update weekly (Monday mornings typically)  
**WHERE**: School district sites, PTSA sites  
**WHY WEEKLY**: Schools publish weekly newsletters, not daily  
**PRIORITY**: 🔥 MEDIUM-HIGH (parents care a lot!)

**Exception**: Job postings on school sites → **Daily**

#### Social Media (17) ❌
**PRIORITY**: ⛔ SKIP

---

## 4. GOVERNMENT (81 resources)

### Breakdown:
- 56 HTML government sites
- 16 Facebook pages  
- 9 Instagram accounts

### Strategy:

#### HTML Government Sites (56) - Town halls, boards ⭐
**WHAT**: Meeting agendas, minutes, announcements, permits  
**HOW**: Parse /agendas, /meetings, /news pages  
**WHEN**: **Monthly** or **Weekly** depending on type:
  - **Weekly**: News/announcements pages, job postings
  - **Monthly**: Meeting agendas (published 1x/month)
  - **Seasonal**: Annual reports, budget documents
**WHERE**: .gov domains  
**WHY VARIABLE**: Meetings monthly, news weekly  
**PRIORITY**: 🔥 MEDIUM (important but low update frequency)

**Sub-categories:**
- Board meeting agendas: **Monthly** (40 resources)
- Government news/jobs: **Weekly** (16 resources)

#### Social Media (25) ❌
**PRIORITY**: ⛔ SKIP (or manual curation)

---

## 5. RESTAURANTS (76 resources)

### Breakdown:
- 28 HTML restaurant sites
- 25 Instagram accounts
- 18 APIs (Yelp, Google Maps, OpenTable)
- 4 Facebook pages
- 1 Manual

### Strategy:

#### APIs (18) - Yelp, Google Maps, OpenTable ⭐
**WHAT**: Restaurant info, hours, menus, reviews  
**HOW**: Yelp API, Google Places API (both have free tiers)  
**WHEN**: **Weekly** - Hours/menus don't change daily  
**WHY WEEKLY**: Opening/closing, special events weekly  
**PRIORITY**: 🔥 MEDIUM (structured data)

#### HTML Restaurant Sites (28)
**WHAT**: Menus, hours, events  
**HOW**: Parse /menu, /events pages  
**WHEN**: **Monthly** - Most restaurants update menus monthly  
**WHY MONTHLY**: Static content, low update frequency  
**PRIORITY**: 🟡 LOW (nice to have, not time-sensitive)

#### Instagram (25) ❌
**PRIORITY**: ⛔ SKIP (better to follow manually)

---

## 6. JOBS (27 resources)

### Breakdown:
- 15 APIs (Indeed, LinkedIn, ZipRecruiter)
- 10 HTML job boards
- 1 Facebook
- 1 Manual

### Strategy:

#### APIs (15) - Indeed, LinkedIn ⭐
**WHAT**: Job listings with titles, descriptions, dates  
**HOW**: Use public APIs or RSS feeds (Indeed has RSS)  
**WHEN**: **Daily** - Jobs posted/removed daily  
**WHY DAILY**: Time-sensitive, competitive  
**PRIORITY**: 🔥🔥 VERY HIGH (people need jobs!)

#### HTML Job Boards (10) - School districts, town jobs ⭐
**WHAT**: Local government/school job postings  
**HOW**: Parse /careers, /employment pages  
**WHEN**: **Daily** - Jobs filled quickly  
**PRIORITY**: 🔥🔥 VERY HIGH

---

## 7. REAL ESTATE (48 resources)

### Breakdown:
- 38 APIs (Zillow, Realtor.com, Trulia)
- 5 HTML realty sites
- 3 Facebook pages
- 2 Instagram

### Strategy:

#### APIs (38) - Zillow, Realtor.com ⭐
**WHAT**: Property listings, prices, photos  
**HOW**: Use their APIs or parse search result pages  
**WHEN**: **Daily** - Hot market, listings change fast  
**WHY DAILY**: New listings posted daily, prices updated  
**PRIORITY**: 🔥 HIGH (valuable, time-sensitive)

#### HTML Realty Sites (5)
**WHEN**: **Daily**  
**PRIORITY**: 🔥 HIGH

---

## 8. PETS (40 resources)

### Breakdown:
- 18 HTML shelter sites
- 11 Facebook pages
- 9 APIs (Petfinder, Adopt-a-Pet)
- 2 Instagram

### Strategy:

#### APIs (9) - Petfinder ⭐
**WHAT**: Adoptable pets with photos, descriptions  
**HOW**: Petfinder API (free)  
**WHEN**: **Daily** - Pets adopted quickly  
**WHY DAILY**: Time-sensitive, save lives!  
**PRIORITY**: 🔥🔥 VERY HIGH (emotional, urgent)

#### HTML Shelter Sites (18) ⭐
**WHAT**: Adoptable animals  
**HOW**: Parse /adopt, /available-pets pages  
**WHEN**: **Daily**  
**PRIORITY**: 🔥🔥 VERY HIGH

---

## 9. BUSINESS NEWS (39 resources)

### Breakdown:
- 21 HTML business sites
- 12 Instagram
- 6 Facebook

### Strategy:

#### HTML Chamber of Commerce, Business Sites (21) ⭐
**WHAT**: Business openings, chamber news, networking events  
**HOW**: Parse /news, /members pages  
**WHEN**: **Weekly** - Business news weekly  
**PRIORITY**: 🟡 MEDIUM

#### Social Media (18) ❌
**PRIORITY**: ⛔ SKIP

---

## 10. COMMUNITY (113 resources)

### Breakdown:
- 57 Facebook groups (Buy Nothing, Mom groups)
- 23 Instagram
- 18 HTML community sites
- 15 Manual (Nextdoor, Reddit)

### Strategy:

#### HTML Community Sites (18)
**WHAT**: Community bulletins, announcements  
**HOW**: Parse community pages  
**WHEN**: **Weekly**  
**PRIORITY**: 🟡 LOW

#### Facebook Groups (57) ❌
**WHY**: Requires auth, group content restricted  
**PRIORITY**: ⛔ SKIP for automation

#### Manual (15) - Nextdoor, Reddit ❌
**WHY**: Requires login, complex scraping  
**PRIORITY**: ⛔ SKIP or manual curation

---

## SUMMARY: SCRAPING PRIORITY MATRIX

### 🔥🔥🔥 DO FIRST (Easiest + Highest Value):
1. **RSS Feeds** (4 total) - Daily
2. **Job APIs** (15) - Daily  
3. **Pet APIs** (9) - Daily
4. **Event APIs** (19) - Daily

**Total: 47 resources, mostly daily**

### 🔥🔥 DO SECOND (High Value):
1. **Local News HTML** (40) - Daily
2. **Real Estate APIs** (38) - Daily
3. **Job Boards HTML** (10) - Daily
4. **Pet Shelter Sites** (18) - Daily

**Total: 106 resources, daily**

### 🔥 DO THIRD (Medium Value):
1. **Event Calendars HTML** (202) - Weekly/Monthly/Seasonal
2. **School Sites HTML** (48) - Weekly
3. **Government HTML** (56) - Monthly/Weekly
4. **Restaurant APIs** (18) - Weekly

**Total: 324 resources, mostly weekly**

### 🟡 DO LAST (Low Priority):
1. **Restaurant HTML** (28) - Monthly
2. **Business News HTML** (21) - Weekly
3. **Community HTML** (18) - Weekly

**Total: 67 resources, weekly/monthly**

### ⛔ DON'T AUTOMATE (289 resources):
- All Facebook (119)
- All Instagram (119)
- All Manual (36)
- Realty HTML Facebook/IG (15)

**Alternative**: Manual curation, user submissions, community reporting

---

## REALISTIC DAILY SCRAPING LOAD

### Daily Scrapes (~200 resources):
- 47 APIs/RSS (easy, fast)
- 106 HTML news/jobs/pets/real estate
- ~153 total daily scrapes

### Weekly Scrapes (~324 resources):
- Event calendars, schools, some government
- ~46 per day (324 ÷ 7)

### Monthly Scrapes (~67 resources):
- Government agendas, restaurant sites
- ~2 per day (67 ÷ 30)

**TOTAL DAILY AVERAGE: ~200 scrapes/day**

---

## IMPLEMENTATION PLAN

### Phase 1: Quick Wins (Week 1)
✅ RSS feeds (4)  
✅ Job APIs (15)  
✅ Pet APIs (9)  
✅ Event APIs (19)  
**Total: 47 resources**

### Phase 2: High Value Daily (Week 2-3)
✅ Local news HTML (40)  
✅ Job boards HTML (10)  
✅ Pet shelters HTML (18)  
✅ Real estate APIs (38)  
**Total: 106 resources**

### Phase 3: Weekly Content (Week 4-6)
✅ Event calendars HTML (202)  
✅ School sites (48)  
✅ Restaurant APIs (18)  
**Total: 268 resources**

### Phase 4: Monthly Content (Week 7-8)
✅ Government sites (56)  
✅ Restaurant sites (28)  
✅ Business news (21)  
**Total: 105 resources**

### Phase 5: Never ❌
❌ Facebook (119)  
❌ Instagram (119)  
❌ Manual sources (51)  
**Reason: Too difficult, unreliable, or require auth**

---

Does this make sense now? Want me to implement the Phase 1 strategy first (the 47 easiest/highest value sources)?

