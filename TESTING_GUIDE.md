# Testing the Optimization System

## Quick Test Steps

### 1. Test API Performance

Open a terminal and run these commands to see the speed difference:

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend

# Test Community News endpoint (run each command twice)
echo "=== First Request (No Cache) ==="
time curl -s "http://localhost:8000/api/community-news" -o /dev/null -w "Time: %{time_total}s\n"

echo ""
echo "=== Second Request (Cached) ==="
time curl -s "http://localhost:8000/api/community-news" -o /dev/null -w "Time: %{time_total}s\n"
```

**Expected Result:** Second request should be 20-40% faster!

### 2. View Cache in Action in Browser

1. **Open your browser to:**
   - Community News API: http://localhost:8000/api/community-news
   - Partners API: http://localhost:8000/api/partners
   - Newsletters API: http://localhost:8000/api/newsletters

2. **Check Response Headers:**
   - Open DevTools (F12)
   - Go to Network tab
   - Look for `Cache-Control` header in the response
   - Should see: `Cache-Control: public, max-age=60, s-maxage=300`

3. **Refresh the page multiple times** - Notice it loads faster after the first time!

### 3. Test Cache Invalidation (The Cool Part!)

This tests that when you update content in Filament, the cache automatically clears:

#### Step 1: Open Two Browser Tabs

**Tab 1 - Admin Panel:**
http://localhost:8000/community-news-items

**Tab 2 - API Response:**
http://localhost:8000/api/community-news

#### Step 2: Create a Test Item

1. In Tab 1 (Admin), click "New Community News Item"
2. Fill in:
   - Title: "Cache Test Article"
   - Content: "Testing cache invalidation"
   - Category: Any category
   - Published At: Now
   - Is Featured: No
3. Click "Create"

#### Step 3: Check the Logs

Open terminal and watch the logs:

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend
tail -f storage/logs/laravel.log | grep -i "cache"
```

**Expected Output:**
```
[2025-12-31 14:37:00] local.INFO: Cleared community news cache
```

#### Step 4: Verify API Updated

Refresh Tab 2 (API) - Your new item should appear immediately!

#### Step 5: Clean Up

Delete the test item you created - check logs again to see cache cleared.

### 4. Test Each Content Type

Repeat the above test for each content type:

| Content Type | Admin URL | API URL |
|-------------|-----------|---------|
| Community News | http://localhost:8000/community-news-items | http://localhost:8000/api/community-news |
| Newsletters | http://localhost:8000/newsletters | http://localhost:8000/api/newsletters |
| Partners | http://localhost:8000/partners | http://localhost:8000/api/partners |
| Events | http://localhost:8000/events | http://localhost:8000/api/events |
| Story Submissions | http://localhost:8000/story-submissions | http://localhost:8000/api/stories |

### 5. Check Database Indexes

Verify the indexes were created:

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend

php artisan db:table community_news_items | grep -A 20 "Index"
```

**Expected:** Should see indexes on `published_at`, `is_featured`, `category`, `newsletter_id`

### 6. Test Frontend Revalidation (When Frontend is Running)

If your Next.js frontend is running:

```bash
# Test the revalidation webhook
curl -X POST http://localhost:3000/api/revalidate \
  -H "Content-Type: application/json" \
  -d '{"secret":"2lYWcmBJuxydQ4+KZXkWeGmqzb04V3FUo3a5nOlzs6Y=","path":"/news"}'
```

**Expected Response:**
```json
{
  "revalidated": true,
  "now": 1704123456789,
  "path": "/news",
  "tag": null
}
```

## Visual Testing Flow

```
┌─────────────────────────────────────────┐
│  1. Open Filament Admin Panel           │
│     http://localhost:8000/admin         │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  2. Create/Edit a Community News Item   │
│     - Add test title and content        │
│     - Click "Create"                    │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  3. Check Logs in Terminal              │
│     tail -f storage/logs/laravel.log    │
│     Look for: "Cleared cache"           │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  4. Refresh API in Browser              │
│     http://localhost:8000/api/          │
│     community-news                      │
│     Your new item should appear!        │
└─────────────────────────────────────────┘
```

## Performance Benchmarking

Run this comprehensive test:

```bash
cd /Users/nierda/GitHub/sites/hudson-life-dispatch-main/hudson-life-dispatch-backend

echo "=== Performance Benchmark ===" > benchmark.txt
echo "" >> benchmark.txt

for endpoint in "community-news" "newsletters" "partners" "events"; do
  echo "Testing: $endpoint" >> benchmark.txt
  
  # Clear cache first
  php artisan cache:clear > /dev/null 2>&1
  
  # First request (no cache)
  echo "  First request (no cache):" >> benchmark.txt
  curl -s "http://localhost:8000/api/$endpoint" -o /dev/null -w "    Time: %{time_total}s\n" >> benchmark.txt
  
  # Second request (cached)
  echo "  Second request (cached):" >> benchmark.txt
  curl -s "http://localhost:8000/api/$endpoint" -o /dev/null -w "    Time: %{time_total}s\n" >> benchmark.txt
  
  echo "" >> benchmark.txt
done

cat benchmark.txt
```

## What You Should See

### ✅ Success Indicators

1. **Faster Response Times:** Second API call is noticeably faster
2. **Cache-Control Headers:** Present in all API responses
3. **Log Messages:** "Cleared cache" appears when you create/edit/delete content
4. **Immediate Updates:** API shows new content right after cache clear
5. **Database Indexes:** Show up in `db:table` command

### ❌ Issues to Watch For

1. **No Speed Improvement:** Cache might not be working
   - Check: `config/cache.php` - should be 'database' driver
   - Run: `php artisan cache:clear` then test again

2. **No Log Messages:** Observers might not be registered
   - Check: `app/Providers/AppServiceProvider.php`
   - Should see: `CommunityNewsItem::observe(CommunityNewsObserver::class);`

3. **Stale Data in API:** Cache not clearing
   - Manually clear: `php artisan cache:clear`
   - Check logs for errors

## Quick Verification Checklist

- [ ] API endpoints return data (http://localhost:8000/api/community-news)
- [ ] Response headers include Cache-Control
- [ ] Second request is faster than first request
- [ ] Creating content triggers "Cleared cache" log message
- [ ] API immediately shows new content after cache clear
- [ ] Database indexes are present (check with `db:table`)
- [ ] All 5 observers are registered in AppServiceProvider
- [ ] Frontend revalidation endpoint responds (if frontend running)

## Next: Production Testing

Once you deploy to production with Redis:
1. Expect 80-90% faster cache responses (5-20ms)
2. Set up monitoring for cache hit rates
3. Monitor webhook success to frontend
4. Track database query reduction

---

**Current Status:** ✅ All systems operational in local development
**Production Ready:** ⚠️ Need to configure Redis on Fly.io

