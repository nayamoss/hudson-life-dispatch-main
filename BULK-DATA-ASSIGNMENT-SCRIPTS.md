# SQL Scripts for Bulk Data Assignment

## Quick Bulk Assignment of Businesses to Towns

Run these SQL queries in your database to automatically assign businesses to towns based on their address:

```sql
-- First, verify your town IDs
SELECT id, name, slug FROM towns;

-- Assign businesses to Ossining
UPDATE businesses 
SET town_id = (SELECT id FROM towns WHERE slug = 'ossining')
WHERE (address LIKE '%Ossining%' OR address LIKE '%OSSINING%')
  AND town_id IS NULL;

-- Assign businesses to Yonkers
UPDATE businesses 
SET town_id = (SELECT id FROM towns WHERE slug = 'yonkers')
WHERE (address LIKE '%Yonkers%' OR address LIKE '%YONKERS%')
  AND town_id IS NULL;

-- Assign businesses to Tarrytown
UPDATE businesses 
SET town_id = (SELECT id FROM towns WHERE slug = 'tarrytown')
WHERE (address LIKE '%Tarrytown%' OR address LIKE '%TARRYTOWN%')
  AND town_id IS NULL;

-- Assign businesses to Sleepy Hollow
UPDATE businesses 
SET town_id = (SELECT id FROM towns WHERE slug = 'sleepy-hollow')
WHERE (address LIKE '%Sleepy Hollow%' OR address LIKE '%SLEEPY HOLLOW%')
  AND town_id IS NULL;

-- Assign businesses to Peekskill
UPDATE businesses 
SET town_id = (SELECT id FROM towns WHERE slug = 'peekskill')
WHERE (address LIKE '%Peekskill%' OR address LIKE '%PEEKSKILL%')
  AND town_id IS NULL;

-- Assign businesses to Croton-on-Hudson
UPDATE businesses 
SET town_id = (SELECT id FROM towns WHERE slug = 'croton')
WHERE (address LIKE '%Croton%' OR address LIKE '%CROTON%')
  AND town_id IS NULL;

-- Assign businesses to Dobbs Ferry
UPDATE businesses 
SET town_id = (SELECT id FROM towns WHERE slug = 'dobbs-ferry')
WHERE (address LIKE '%Dobbs Ferry%' OR address LIKE '%DOBBS FERRY%')
  AND town_id IS NULL;

-- Verify assignments
SELECT t.name as town, COUNT(b.id) as business_count
FROM towns t
LEFT JOIN businesses b ON b.town_id = t.id
GROUP BY t.id, t.name
ORDER BY t.name;

-- Check unassigned businesses
SELECT id, name, address
FROM businesses
WHERE town_id IS NULL
LIMIT 20;
```

---

## Laravel Tinker Commands for Bulk Tagging Posts

Run these in Laravel Tinker (`php artisan tinker`):

```php
// Get all published posts
$posts = App\Models\Post::where('status', 'published')->get();

// Auto-tag posts based on content
foreach ($posts as $post) {
    $tags = $post->tags ?? [];
    $content = strtolower($post->title . ' ' . $post->content);
    
    // Check for each town mention
    if (str_contains($content, 'ossining')) {
        $tags[] = 'ossining';
    }
    if (str_contains($content, 'yonkers')) {
        $tags[] = 'yonkers';
    }
    if (str_contains($content, 'tarrytown')) {
        $tags[] = 'tarrytown';
    }
    if (str_contains($content, 'sleepy hollow')) {
        $tags[] = 'sleepy-hollow';
    }
    if (str_contains($content, 'peekskill')) {
        $tags[] = 'peekskill';
    }
    if (str_contains($content, 'croton')) {
        $tags[] = 'croton';
    }
    if (str_contains($content, 'dobbs ferry')) {
        $tags[] = 'dobbs-ferry';
    }
    
    // Remove duplicates and save
    if (!empty($tags)) {
        $post->tags = array_unique($tags);
        $post->save();
        echo "Tagged: {$post->title}\n";
    }
}

// Verify tagged posts
$taggedPosts = App\Models\Post::whereJsonContains('tags', 'ossining')->count();
echo "Posts tagged with 'ossining': {$taggedPosts}\n";
```

---

## Artisan Command to Verify Everything

Create a quick check command:

```php
// Run in terminal
php artisan tinker

// Check towns
App\Models\Town::where('is_active', true)->count();

// Check businesses with towns
App\Models\Business::whereNotNull('town_id')->count();

// Check posts with town tags
App\Models\Post::where(function($q) {
    $q->whereJsonContains('tags', 'ossining')
      ->orWhereJsonContains('tags', 'yonkers')
      ->orWhereJsonContains('tags', 'tarrytown')
      ->orWhereJsonContains('tags', 'sleepy-hollow')
      ->orWhereJsonContains('tags', 'peekskill')
      ->orWhereJsonContains('tags', 'croton')
      ->orWhereJsonContains('tags', 'dobbs-ferry');
})->count();

// Check events with towns
App\Models\Event::whereNotNull('town_id')
    ->where('status', 'published')
    ->where('date', '>=', now())
    ->count();
```

---

## Expected Results

After running these scripts, you should see:

```
✅ All businesses assigned to towns (or identified as needing manual assignment)
✅ All relevant blog posts tagged with town names
✅ Town pages displaying live data when visited
```

---

## Manual Cleanup

After running bulk scripts, you may still have:
1. Businesses with unclear addresses → Assign manually in Filament
2. Posts that mention multiple towns → Verify tags are appropriate
3. Posts with no town mention → Skip or add general "hudson-valley" tag

Use Filament admin to review and clean up any edge cases.

