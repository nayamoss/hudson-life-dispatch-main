# Quick Reference: Environment Variables

## Frontend Environment Variable

Add this to your frontend `.env.local` or hosting platform:

```bash
NEXT_PUBLIC_API_URL=https://admin.hudsonlifedispatch.com/api
```

### For Local Development

Create `.env.local` in the frontend directory:

```bash
cd hudson-life-dispatch-frontend
cat > .env.local << 'EOF'
NEXT_PUBLIC_API_URL=https://admin.hudsonlifedispatch.com/api
EOF
```

### For Vercel

Add in Vercel Dashboard → Project Settings → Environment Variables:

- **Name:** `NEXT_PUBLIC_API_URL`
- **Value:** `https://admin.hudsonlifedispatch.com/api`
- **Apply to:** Production, Preview, Development

Then redeploy.

### For Netlify

Add in Netlify Dashboard → Site Settings → Environment Variables:

- **Key:** `NEXT_PUBLIC_API_URL`
- **Value:** `https://admin.hudsonlifedispatch.com/api`

Then trigger new deploy.

## Verify It's Working

After setting the variable, check it's loaded:

```bash
# In your Next.js app
console.log(process.env.NEXT_PUBLIC_API_URL);
// Should output: https://admin.hudsonlifedispatch.com/api
```

Or check the API client is using the right URL by visiting any town page and checking the Network tab in browser DevTools.

