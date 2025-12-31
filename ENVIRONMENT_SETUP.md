# Environment Variables Setup for Data Flow Optimization

This document outlines the required environment variables for the optimized data flow between Laravel backend and Next.js frontend.

## Backend Environment Variables (.env)

Add these variables to your Laravel backend `.env` file:

```env
# Cache Configuration
CACHE_DRIVER=redis
REDIS_CLIENT=phpredis
REDIS_HOST=your-redis-host.fly.dev
REDIS_PASSWORD=your-redis-password
REDIS_PORT=6379

# Frontend Integration
FRONTEND_URL=https://hudsonlifedispatch.com
FRONTEND_REVALIDATE_URL=https://hudsonlifedispatch.com/api/revalidate
REVALIDATE_SECRET=your-secure-random-secret-key-here

# CORS Configuration
SANCTUM_STATEFUL_DOMAINS=hudsonlifedispatch.com,www.hudsonlifedispatch.com
SESSION_DOMAIN=.hudsonlifedispatch.com
```

### Generating a Secure Revalidation Secret

Run this command in your Laravel backend to generate a secure secret:

```bash
php artisan tinker --execute="echo base64_encode(random_bytes(32));"
```

Copy the output and use it for `REVALIDATE_SECRET` in both backend and frontend.

## Frontend Environment Variables (.env.local)

Add these variables to your Next.js frontend `.env.local` file:

```env
# API Configuration
NEXT_PUBLIC_API_URL=https://admin.hudsonlifedispatch.com/api

# Revalidation Secret (must match backend)
REVALIDATE_SECRET=your-secure-random-secret-key-here
```

## How It Works

### 1. Cache Layer (Backend)
- API responses are cached in Redis with tags
- Cache duration: 5-10 minutes depending on content type
- HTTP Cache-Control headers set for CDN caching

### 2. Cache Invalidation (Backend)
- Model observers detect changes (create, update, delete)
- Automatically flush relevant cache tags
- Trigger frontend revalidation via webhook

### 3. Frontend Revalidation (Next.js)
- Backend sends POST request to `/api/revalidate`
- Next.js revalidates specific paths or tags
- Fresh data fetched on next request

### 4. Data Flow Diagram

```
User Updates Content in Filament
         ↓
Model Observer Triggered
         ↓
    ┌────┴────┐
    ↓         ↓
Clear Cache   Send Webhook
(Redis)       (Frontend)
    ↓         ↓
    └────┬────┘
         ↓
Frontend Revalidates Path
         ↓
Next Request Gets Fresh Data
```

## Testing the Setup

### 1. Test Backend Cache

```bash
# In Laravel backend
php artisan tinker

# Test cache
Cache::tags(['community-news'])->put('test', 'value', 60);
Cache::tags(['community-news'])->get('test'); // Should return 'value'
Cache::tags(['community-news'])->flush();
Cache::tags(['community-news'])->get('test'); // Should return null
```

### 2. Test Frontend Revalidation

```bash
# From command line
curl -X POST https://hudsonlifedispatch.com/api/revalidate \
  -H "Content-Type: application/json" \
  -d '{"secret":"your-secret-here","path":"/news"}'
```

Expected response:
```json
{
  "revalidated": true,
  "now": 1704067200000,
  "path": "/news",
  "tag": null
}
```

### 3. End-to-End Test

1. Create a new Community News item in Filament
2. Check Laravel logs for cache clear message
3. Check Next.js logs for revalidation message
4. Visit the frontend news page - should show new item within 60 seconds

## Performance Expectations

- **API Response Time**: 5-20ms (cached) vs 50-200ms (database)
- **Cache Hit Rate**: 80-90% expected
- **Frontend Update Delay**: < 60 seconds after backend change
- **Database Load Reduction**: 80-90%

## Troubleshooting

### Cache Not Working

Check Redis connection:
```bash
php artisan tinker --execute="Cache::put('test', 'value', 60); echo Cache::get('test');"
```

### Revalidation Not Working

Check logs:
```bash
# Backend logs
tail -f storage/logs/laravel.log | grep "revalidate"

# Frontend logs (if deployed)
# Check your hosting platform's logs
```

### CORS Issues

Ensure `config/cors.php` includes your frontend domain in `allowed_origins`.

## Security Notes

- Keep `REVALIDATE_SECRET` secure and never commit to version control
- Use HTTPS for all production URLs
- Rotate the secret periodically
- Monitor revalidation endpoint for abuse

## Production Deployment Checklist

- [ ] Redis configured and accessible
- [ ] Environment variables set in backend
- [ ] Environment variables set in frontend
- [ ] CORS configuration updated
- [ ] Revalidation secret generated and set
- [ ] Test cache functionality
- [ ] Test revalidation webhook
- [ ] Monitor performance metrics
- [ ] Set up alerts for cache failures

