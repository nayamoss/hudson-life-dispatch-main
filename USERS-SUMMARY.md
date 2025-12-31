# Hudson Life Dispatch - User Summary

## 👥 All Users Overview

### User Count: 2

1. **Naya Admin** - Full Administrator ⭐
2. **Naya Moss** - Free Subscriber 👤

---

## 📊 User Comparison Table

| Attribute | Naya Admin (Admin) | Naya Moss (Subscriber) |
|-----------|-------------------|------------------------|
| **Clerk ID** | `user_37acLPftUqMQXvaURj41Y4ALdxz` | `user_37acMrQMIJ8FspRHfKUM5gEgjbZ` |
| **Email** | kinvergtmwn.l8yhu@simplelogin.com | naya@namoslabs.com |
| **Username** | nayaadmin | nayamoss |
| **Display Name** | Naya Admin | Naya Moss |
| **Primary Role** | `admin` | `subscriber` |
| **Roles Array** | `["admin"]` | `["subscriber"]` |
| **Profile URL** | `/nayaadmin` | `/nayamoss` |
| **Created** | 2025-12-31 | 2025-12-31 |

---

## 🔐 Access & Permissions Comparison

### Admin Panel Access

| Permission | Naya Admin | Naya Moss |
|------------|-----------|-----------|
| **Access admin.hudsonlifedispatch.com** | ✅ Full Access | ❌ Denied |
| **Access /admin routes** | ✅ All Routes | ❌ None |
| **Filament Resources** | ✅ All Resources | ❌ None |

### Content Management

| Permission | Naya Admin | Naya Moss |
|------------|-----------|-----------|
| **Create Blog Posts** | ✅ Yes | ❌ No |
| **Manage Events** | ✅ Full CRUD | ❌ Read Only |
| **Manage Businesses** | ✅ Full CRUD | ❌ Read Only |
| **Approve Story Submissions** | ✅ Yes | ❌ No |
| **Publish Newsletters** | ✅ Yes | ❌ No |
| **Moderate Comments** | ✅ Yes | ❌ No |
| **Manage Users** | ✅ Yes | ❌ No |

### Analytics & Reports

| Permission | Naya Admin | Naya Moss |
|------------|-----------|-----------|
| **View Analytics Dashboard** | ✅ Full Access | ❌ Denied |
| **Export Data** | ✅ Yes | ❌ No |
| **View User Activity** | ✅ All Users | 🟡 Own Only |
| **System Logs** | ✅ Full Access | ❌ Denied |

### System Administration

| Permission | Naya Admin | Naya Moss |
|------------|-----------|-----------|
| **Site Settings** | ✅ Full Control | ❌ Denied |
| **Run Scraping Tools** | ✅ Yes | ❌ No |
| **Manage Integrations** | ✅ Yes | ❌ No |
| **Email Templates** | ✅ Full CRUD | ❌ Denied |
| **Navigation Menus** | ✅ Full CRUD | ❌ Denied |

### User Features

| Permission | Naya Admin | Naya Moss |
|------------|-----------|-----------|
| **View Public Content** | ✅ Yes | ✅ Yes |
| **View Subscriber Content** | ✅ Yes | ✅ Yes |
| **Edit Own Profile** | ✅ Yes | ✅ Yes |
| **Manage Own Preferences** | ✅ Yes | ✅ Yes |
| **Submit Stories** | ✅ Yes | ✅ Yes |
| **Newsletter Subscription** | 🟡 Optional | ✅ Active |

---

## 📧 Newsletter Subscription Status

### Naya Admin
- **Subscribed:** No (not in newsletter_subscribers)
- **Status:** N/A
- **Purpose:** Admin account, not subscriber

### Naya Moss
- **Subscribed:** ✅ Yes
- **Status:** Active
- **Source:** clerk_integration
- **Subscribed Date:** 2025-12-31

---

## 🌐 API Endpoints

### User Profile Endpoints

Both users are accessible via public API:

```bash
# Naya Admin
GET http://localhost:8000/api/users/nayaadmin
GET http://localhost:8000/api/users/user_37acLPftUqMQXvaURj41Y4ALdxz

# Naya Moss
GET http://localhost:8000/api/users/nayamoss
GET http://localhost:8000/api/users/user_37acMrQMIJ8FspRHfKUM5gEgjbZ
```

### Public Profiles

```
Development:
- http://localhost:3000/nayaadmin
- http://localhost:3000/nayamoss

Production:
- https://hudsonlifedispatch.com/nayaadmin
- https://hudsonlifedispatch.com/nayamoss
```

---

## 🔒 Authentication & Security

### Authentication Method
- **Both users:** Clerk (OAuth)
- **Password:** None (Clerk handles auth)
- **Session:** Managed by Clerk

### Security Levels

#### Naya Admin (High Security)
- ⚠️ **Critical Account** - Full system access
- 🔐 **Recommended:** Enable 2FA in Clerk
- 📊 **Monitoring:** Log all admin actions
- 🔄 **Audit:** Regular security reviews

#### Naya Moss (Standard Security)
- ✅ **Standard Account** - Limited access
- 🔐 **Optional:** 2FA for added security
- 📊 **Monitoring:** Standard activity logs
- 🔄 **Audit:** Periodic reviews

---

## 🧪 Testing Both Users

### Quick Test Commands

```bash
# Test both user profiles
curl http://localhost:8000/api/users/nayaadmin | jq
curl http://localhost:8000/api/users/nayamoss | jq

# Check roles in database
sqlite3 database/database.sqlite "SELECT id, name, username, primary_role, roles FROM users;"

# Check newsletter subscriptions
sqlite3 database/database.sqlite "SELECT email, name, status FROM newsletter_subscribers;"
```

### Expected Database Output

```
Users Table:
user_37acLPftUqMQXvaURj41Y4ALdxz|Naya Admin|nayaadmin|admin|["admin"]
user_37acMrQMIJ8FspRHfKUM5gEgjbZ|Naya Moss|nayamoss|subscriber|["subscriber"]

Newsletter Subscribers:
naya@namoslabs.com|Naya Moss|active
```

---

## 📋 Use Cases

### Naya Admin Should:
1. ✅ Access admin panel at admin.hudsonlifedispatch.com
2. ✅ Manage all blog posts, events, businesses
3. ✅ Approve/reject story submissions
4. ✅ Run scraping and automation tools
5. ✅ View analytics and system logs
6. ✅ Manage all users and permissions
7. ✅ Configure site settings
8. ✅ Send newsletter campaigns

### Naya Admin Should NOT:
- ❌ Be used for regular browsing (use subscriber account)
- ❌ Share credentials with others
- ❌ Leave sessions open unattended
- ❌ Make unauthorized data exports

### Naya Moss Should:
1. ✅ View subscriber-only content
2. ✅ Edit own profile information
3. ✅ Manage newsletter preferences
4. ✅ Submit stories for review
5. ✅ Browse public content
6. ✅ Receive newsletter emails

### Naya Moss Should NOT:
- ❌ Attempt to access admin panel
- ❌ Try to manage other users' content
- ❌ Access admin API endpoints
- ❌ Modify system settings

---

## 🔧 Management Commands

### Create/Update Users

```bash
# Create/update Naya Admin
php artisan db:seed --class=NayaAdminUserSeeder

# Create/update Naya Moss
php artisan db:seed --class=NayaMossUserSeeder
```

### View Users

```bash
# All users
sqlite3 database/database.sqlite "SELECT * FROM users;"

# Specific user
sqlite3 database/database.sqlite "SELECT * FROM users WHERE username='nayaadmin';"
```

### Change User Role

```sql
-- Promote to admin
UPDATE users 
SET roles = '["admin"]', primary_role = 'admin' 
WHERE id = 'user_id_here';

-- Demote to subscriber
UPDATE users 
SET roles = '["subscriber"]', primary_role = 'subscriber' 
WHERE id = 'user_id_here';
```

---

## 📊 Statistics

### User Counts by Role

```sql
SELECT primary_role, COUNT(*) as count 
FROM users 
GROUP BY primary_role;
```

**Current:**
- Admin: 1
- Subscriber: 1
- **Total: 2**

### Newsletter Subscribers

```sql
SELECT COUNT(*) as total_subscribers 
FROM newsletter_subscribers 
WHERE status = 'active';
```

**Current:** 1 active subscriber

---

## 🎯 Best Practices

### For Admin Users (Naya Admin)
1. ✅ Enable 2FA immediately
2. ✅ Use strong, unique password in Clerk
3. ✅ Log out after admin tasks
4. ✅ Review activity logs regularly
5. ✅ Limit admin session duration
6. ✅ Use separate browser/profile for admin work

### For Subscriber Users (Naya Moss)
1. ✅ Keep profile information updated
2. ✅ Manage email preferences appropriately
3. ✅ Enable 2FA for added security
4. ✅ Report any suspicious activity
5. ✅ Use strong password in Clerk

### For Both
1. ✅ Never share login credentials
2. ✅ Use official URLs only
3. ✅ Report security concerns immediately
4. ✅ Keep browser and software updated
5. ✅ Be cautious of phishing attempts

---

## 📝 Documentation Links

- **Naya Admin Details:** `NAYA-ADMIN-SETUP.md`
- **Naya Moss Details:** `NAYA-MOSS-SUBSCRIBER-SETUP.md`
- **User Profile Fix:** `USER-PROFILE-FIX.md`
- **Architecture Guide:** `AGENTS.md`

---

## 🆘 Quick Reference

### Admin Login
1. Go to: `https://admin.hudsonlifedispatch.com`
2. Sign in with: `kinvergtmwn.l8yhu@simplelogin.com`
3. Access: Full admin panel

### Subscriber Login
1. Go to: `https://hudsonlifedispatch.com`
2. Sign in with: `naya@namoslabs.com`
3. Access: Public + subscriber content

### Need Help?
- Review user-specific documentation
- Check Clerk dashboard for auth issues
- Verify database records
- Test API endpoints
- Check Laravel logs

