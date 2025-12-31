# Your Clerk API Keys Configuration

## Frontend (.env.local)

Add to: `hudson-life-dispatch-frontend/.env.local`

```env
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_YW11c2luZy1kb3ZlLTMuY2xlcmsuYWNjb3VudHMuZGV2JA
CLERK_SECRET_KEY=sk_test_99wh2uKEepvBSLjioPZxsxttsoLgUlzxX1Tg1yY5p9
```

## Backend (.env)

Add to: `hudson-life-dispatch-backend/.env`

```env
# Clerk API Configuration
CLERK_API_SECRET=sk_test_99wh2uKEepvBSLjioPZxsxttsoLgUlzxX1Tg1yY5p9
CLERK_ENDPOINT=https://api.clerk.com/v1
CLERK_WEBHOOK_PATH=/webhook/clerk
CLERK_WEBHOOK_VERIFY_TOKEN=true

# Note: You'll get CLERK_WEBHOOK_TOKEN after configuring webhooks in Clerk Dashboard
CLERK_WEBHOOK_TOKEN=
```

## Quick Setup Commands

```bash
# Backend
cd hudson-life-dispatch-backend
echo "" >> .env
echo "# Clerk Authentication" >> .env
echo "CLERK_API_SECRET=sk_test_99wh2uKEepvBSLjioPZxsxttsoLgUlzxX1Tg1yY5p9" >> .env
echo "CLERK_ENDPOINT=https://api.clerk.com/v1" >> .env
echo "CLERK_WEBHOOK_PATH=/webhook/clerk" >> .env
echo "CLERK_WEBHOOK_VERIFY_TOKEN=true" >> .env
echo "CLERK_WEBHOOK_TOKEN=" >> .env

# Frontend
cd ../hudson-life-dispatch-frontend
echo "" >> .env.local
echo "# Clerk Authentication" >> .env.local
echo "NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_YW11c2luZy1kb3ZlLTMuY2xlcmsuYWNjb3VudHMuZGV2JA" >> .env.local
echo "CLERK_SECRET_KEY=sk_test_99wh2uKEepvBSLjioPZxsxttsoLgUlzxX1Tg1yY5p9" >> .env.local
```

## Webhook Configuration

1. Go to https://dashboard.clerk.com
2. Click on your project
3. Go to "Webhooks" in the sidebar
4. Click "Add Endpoint"
5. Enter endpoint URL:
   ```
   https://admin.hudsonlifedispatch.com/api/webhooks/clerk
   ```
6. Select events:
   - ✅ user.created
   - ✅ user.updated
   - ✅ user.deleted
7. Click "Create"
8. Copy the **Signing Secret** (starts with `whsec_`)
9. Add to backend `.env`:
   ```env
   CLERK_WEBHOOK_TOKEN=whsec_YOUR_SIGNING_SECRET_HERE
   ```

## Test It Now!

```bash
# Restart backend server
cd hudson-life-dispatch-backend
php artisan config:clear
php artisan serve --host=0.0.0.0 --port=8000

# In another terminal, restart frontend
cd hudson-life-dispatch-frontend
npm run dev
```

Then:
1. Go to http://localhost:3000
2. Sign in with Clerk
3. Open browser console (F12)
4. Run:
```javascript
const token = await window.Clerk.session.getToken();
fetch('http://localhost:8000/api/test/clerk', {
  headers: { 'Authorization': `Bearer ${token}` }
}).then(r => r.json()).then(console.log);
```

**Expected Result:**
```json
{
  "success": true,
  "message": "Clerk authentication working",
  "user": { "id": "user_...", "email": "...", ... }
}
```

## Status

- ✅ Publishable Key (Frontend): Provided
- ✅ Secret Key (Backend): Provided
- ⏳ Webhook Secret: Need to configure in Clerk Dashboard
- ⏳ Test: Run the test above

## Next Step

Run the quick setup commands above, then test!

