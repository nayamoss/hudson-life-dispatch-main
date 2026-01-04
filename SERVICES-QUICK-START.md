# Services Directory - Quick Start Guide

## 🚀 Quick Commands

### Update Business Counts
```bash
cd hudson-life-dispatch-backend
php artisan services:update-counts
```

### Seed Service Categories
```bash
cd hudson-life-dispatch-backend
php artisan db:seed --class=ServiceCategorySeeder
```

### Test API Endpoints
```bash
# List all categories
curl http://localhost:8000/api/services

# Get category with businesses
curl http://localhost:8000/api/services/restaurants

# Get town-specific listings
curl http://localhost:8000/api/services/ossining/restaurants

# Get towns for a category
curl http://localhost:8000/api/services/restaurants/towns
```

## 📍 URLs to Visit

### Frontend
- **Hub:** http://localhost:3000/services
- **Category:** http://localhost:3000/services/restaurants
- **Town + Category:** http://localhost:3000/services/ossining/restaurants

### API
- **Categories:** http://localhost:8000/api/services
- **Category:** http://localhost:8000/api/services/restaurants
- **Town:** http://localhost:8000/api/services/ossining/restaurants

## 🎯 Service Categories Available

1. **restaurants** - Restaurants & Dining 🍽️
2. **home-services** - Home Services 🏠
3. **health-wellness** - Health & Wellness 💪
4. **professional-services** - Professional Services 💼
5. **retail-shopping** - Retail & Shopping 🛍️
6. **beauty-personal-care** - Beauty & Personal Care 💇
7. **auto-services** - Auto Services 🚗
8. **real-estate** - Real Estate 🏡
9. **education-childcare** - Education & Childcare 📚
10. **arts-entertainment** - Arts & Entertainment 🎨

## 🏘️ Towns Available

1. ossining
2. tarrytown
3. sleepy-hollow
4. irvington
5. dobbs-ferry
6. hastings
7. croton
8. peekskill
9. yonkers

## 📝 Adding a Business to a Category

Ensure the business has matching category values:

```php
// In business record
'category' => ['Restaurant', 'Dining', 'Food & Beverage']

// Service category mapping (ServiceCategorySeeder.php)
'business_category_mapping' => ['Restaurant', 'Cafe', 'Bar', 'Food & Beverage', 'Dining']
```

The business will appear in "Restaurants & Dining" because it has matching values.

## 🔄 Daily Maintenance

Add to Laravel scheduler (`app/Console/Kernel.php`):

```php
protected function schedule(Schedule $schedule)
{
    $schedule->command('services:update-counts')->daily();
}
```

## 🐛 Troubleshooting

### No businesses showing?
1. Check business `status = 'active'`
2. Verify business `category` JSON matches service mapping
3. Run `php artisan services:update-counts`

### Wrong town showing?
- Verify business `town_id` is correct
- Check town slug matches URL

### API 404 errors?
- Clear route cache: `php artisan route:clear`
- Check Laravel logs: `tail -f storage/logs/laravel.log`

## 📚 Full Documentation

See `/hudson-life-dispatch-backend/docs/SERVICES-DIRECTORY.md` for complete documentation.

