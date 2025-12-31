# Clerk Environment Variables Setup

## Add to `.env` file in hudson-life-dispatch-backend/

```env
# Clerk Authentication Configuration

# Clerk API Secret Key (from Clerk Dashboard -> API Keys)
CLERK_API_SECRET=sk_test_YOUR_SECRET_KEY_HERE

# Clerk API Endpoint
CLERK_ENDPOINT=https://api.clerk.com/v1

# Clerk Webhook Token (from Clerk Dashboard -> Webhooks -> Signing Secret)
CLERK_WEBHOOK_TOKEN=whsec_YOUR_WEBHOOK_SECRET_HERE

# Clerk Webhook Path
CLERK_WEBHOOK_PATH=/webhook/clerk

# Clerk Webhook Verification
CLERK_WEBHOOK_VERIFY_TOKEN=true
```

## How to Get Your Keys

1. Go to https://dashboard.clerk.com
2. Select your project
3. Navigate to **API Keys**
4. Copy your **Secret Key** (starts with `sk_test_` or `sk_live_`)
5. Go to **Webhooks** section
6. Add an endpoint (or view existing one)
7. Copy the **Signing Secret** (starts with `whsec_`)

## What Each Variable Does

- **CLERK_API_SECRET**: Used to verify JWT tokens from Clerk
- **CLERK_ENDPOINT**: Clerk API base URL (should not need to change)
- **CLERK_WEBHOOK_TOKEN**: Used to verify webhook requests from Clerk
- **CLERK_WEBHOOK_PATH**: URL path where webhooks will be received
- **CLERK_WEBHOOK_VERIFY_TOKEN**: Whether to verify webhook signatures (keep true)

## Security Notes

- Never commit these keys to git
- Keep `.env` file out of version control
- Use different keys for development and production
- Rotate keys if compromised

