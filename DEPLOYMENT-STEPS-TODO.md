# 🚀 Deployment Steps - Manual Completion Required

## ✅ What's Already Done

All code has been implemented and is ready to deploy:
- ✅ Backend API controllers created
- ✅ Frontend components built
- ✅ All 7 town pages converted to dynamic
- ✅ Migration file created
- ✅ Fixed Filament error (removed missing ViewAdReport page)

---

## ⚠️ What Needs Manual Completion

### 1. 🗄️ Run Database Migration

**Issue:** Database server is not currently running locally.

**Action Required:**
```bash
cd hudson-life-dispatch-backend
php artisan migrate
```

This will add the `town_id` column to the `businesses` table.

**When to do this:** On your production/staging server where the database is accessible.

---

### 2. 🏢 Assign Businesses to Towns

**Action Required:**
1. Log into Filament admin at `admin.hudsonlifedispatch.com`
2. Navigate to **Businesses** resource
3. Edit each business
4. Select the appropriate **Town** from the dropdown
5. Save

**Bulk Assignment Option:**
If you have many businesses, you can create a script or SQL query:

```sql
-- Example: Assign businesses based on address
UPDATE businesses 
SET town_id = (SELECT id FROM towns WHERE slug = 'ossining')
WHERE address LIKE '%Ossining%';

UPDATE businesses 
SET town_id = (SELECT id FROM towns WHERE slug = 'yonkers')
WHERE address LIKE '%Yonkers%';

-- Repeat for each town...
```

**Towns that need businesses assigned:**
- Ossining
- Yonkers
- Tarrytown
- Sleepy Hollow
- Peekskill
- Croton-on-Hudson
- Dobbs Ferry

---

### 3. 🏷️ Tag Blog Posts with Town Names

**Action Required:**
1. Log into Filament admin at `admin.hudsonlifedispatch.com`
2. Navigate to **Blog Posts** resource
3. Edit each post
4. In the **Tags** field, add town names (lowercase, matching slugs)
5. Save

**Example tags to add:**
```
["ossining", "westchester", "events"]
["yonkers", "hudson-valley", "community"]
["tarrytown", "sleepy-hollow", "historic"]
```

**Tag Format:**
- Use lowercase
- Use hyphens for multi-word towns: `sleepy-hollow`
- Match the town slugs exactly:
  - `ossining`
  - `yonkers`
  - `tarrytown`
  - `sleepy-hollow`
  - `peekskill`
  - `croton` (for Croton-on-Hudson)
  - `dobbs-ferry`

**Pro Tip:** Create a bulk tagging script if you have many posts:

```php
// Run in Laravel Tinker
$posts = App\Models\Post::all();
foreach ($posts as $post) {
    if (str_contains($post->content, 'Ossining')) {
        $tags = $post->tags ?? [];
        $tags[] = 'ossining';
        $post->tags = array_unique($tags);
        $post->save();
    }
    // Repeat for other towns...
}
```

---

### 4. 🌐 Set Frontend Environment Variable

**Action Required:**

**For Local Development:**
Create or edit `.env.local` in the frontend directory:

```bash
cd hudson-life-dispatch-frontend
echo "NEXT_PUBLIC_API_URL=https://admin.hudsonlifedispatch.com/api" > .env.local
```

**For Production (Vercel/Netlify/etc):**
Add environment variable in your hosting dashboard:

**Variable Name:** `NEXT_PUBLIC_API_URL`  
**Variable Value:** `https://admin.hudsonlifedispatch.com/api`

**Vercel Example:**
1. Go to your project settings
2. Click **Environment Variables**
3. Add:
   - Name: `NEXT_PUBLIC_API_URL`
   - Value: `https://admin.hudsonlifedispatch.com/api`
   - Environments: Production, Preview, Development
4. Redeploy

**Note:** The frontend will fall back to this URL if the variable isn't set, but it's best practice to set it explicitly.

---

## 🧪 Testing After Deployment

### 1. Test Backend APIs

```bash
# Test town endpoint
curl https://admin.hudsonlifedispatch.com/api/towns/ossining

# Test events endpoint
curl https://admin.hudsonlifedispatch.com/api/events?town=ossining&upcoming=true&limit=5

# Test businesses endpoint
curl https://admin.hudsonlifedispatch.com/api/businesses?town=ossining&limit=5

# Test posts endpoint
curl https://admin.hudsonlifedispatch.com/api/posts?town=ossining&limit=5
```

### 2. Test Frontend Pages

Visit each town page:
- https://hudsonlifedispatch.com/ossining
- https://hudsonlifedispatch.com/yonkers
- https://hudsonlifedispatch.com/tarrytown
- https://hudsonlifedispatch.com/sleepy-hollow
- https://hudsonlifedispatch.com/peekskill
- https://hudsonlifedispatch.com/croton
- https://hudsonlifedispatch.com/dobbs-ferry

**Check for:**
- ✅ Events section shows live data
- ✅ Businesses section shows live data
- ✅ Blog posts section shows relevant articles
- ✅ Stats show correct counts
- ✅ No errors in browser console
- ✅ Images load properly

---

## 🐛 Troubleshooting

### Events not showing
- Check that events have `town_id` set in database
- Check that events have `status = 'published'`
- Check that events have `date >= today`

### Businesses not showing
- Check that businesses have `town_id` set (step 2 above)
- Check that businesses have `status = 'active'`

### Posts not showing
- Check that posts have town name in `tags` array (step 3 above)
- Check that posts have `status = 'published'`
- Check that posts have `visibility = 'public'`

### API errors (CORS)
- Ensure frontend domain is in Laravel's CORS config
- Check `config/cors.php` in backend

### 404 errors
- Check that town slugs match exactly in database
- Clear Laravel cache: `php artisan cache:clear`

---

## 📞 Summary

**You need to:**
1. ✅ Run migration (on server with DB access)
2. ✅ Assign businesses to towns in Filament
3. ✅ Add town tags to blog posts in Filament
4. ✅ Set `NEXT_PUBLIC_API_URL` in frontend environment

**Once complete:**
- All town pages will display live, dynamic data
- Content updates in Filament will immediately reflect on the frontend
- SEO benefits are maintained while gaining dynamic functionality

**Estimated Time:** 30-60 minutes (depending on amount of existing data to tag)

