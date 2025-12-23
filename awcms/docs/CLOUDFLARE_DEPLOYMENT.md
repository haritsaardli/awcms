# AWCMS - Cloudflare Pages Deployment Guide

## Prerequisites

- GitHub/GitLab repository with AWCMS code
- Cloudflare account (free tier is sufficient)
- Supabase project (already configured)

## Deployment Steps

### 1. Push Code to Git Repository

```bash
git add .
git commit -m "Prepare for Cloudflare Pages deployment"
git push origin main
```

### 2. Connect to Cloudflare Pages

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Navigate to **Pages** → **Create a project**
3. Click **Connect to Git**
4. Select your repository

### 3. Configure Build Settings

| Setting | Value |
|---------|-------|
| **Framework preset** | Vite |
| **Build command** | `npm run build` |
| **Build output directory** | `dist` |
| **Root directory** | `/` (or path to awcms folder) |
| **Node.js version** | 18.x or 20.x |

### 4. Environment Variables

Add these in **Settings** → **Environment Variables**:

| Variable | Value | Type |
|----------|-------|------|
| `VITE_SUPABASE_URL` | `https://your-project.supabase.co` | Plain text |
| `VITE_SUPABASE_ANON_KEY` | `eyJhbGci...` | Encrypted |
| `NODE_VERSION` | `20` | Plain text |

> ⚠️ **Important**: Get these values from your Supabase project dashboard → Settings → API

### 5. Deploy

Click **Save and Deploy**. Cloudflare will:

1. Clone your repository
2. Install dependencies (`npm install`)
3. Build the project (`npm run build`)
4. Deploy the `dist` folder to its edge network

### 6. Custom Domain (Optional)

1. Go to your Pages project → **Custom domains**
2. Add your domain (e.g., `cms.yourdomain.com`)
3. Update DNS records as instructed
4. SSL certificate will be auto-provisioned

## Configuration Files

The following files are included for Cloudflare Pages:

- `public/_redirects` - SPA routing (all paths → index.html)
- `public/_headers` - Security headers & caching

## Supabase Configuration

Ensure these are configured in your Supabase project:

### Auth Settings

- **Site URL**: `https://your-app.pages.dev`
- **Redirect URLs**: Add your Cloudflare Pages URLs

### Storage CORS

Add your Cloudflare domain to allowed origins.

### Database RLS

Ensure Row Level Security policies are properly configured for production.

## Troubleshooting

### Build Fails

- Check Node.js version (use 18.x or 20.x)
- Verify all dependencies are in `package.json`
- Check build logs for specific errors

### 404 on Routes

- Ensure `_redirects` file is in `public/` folder
- File should contain: `/*    /index.html   200`

### API Errors

- Verify environment variables are set correctly
- Check Supabase project is active and accessible
- Verify CORS settings in Supabase

## Performance Tips

1. **Enable Auto Minify** in Cloudflare dashboard
2. **Enable Brotli compression** (default on)
3. **Use Page Rules** for additional caching if needed

## Monitoring

- View analytics in Cloudflare Pages dashboard
- Set up **Web Analytics** for user metrics
- Configure **Notifications** for deploy status

---

**Your AWCMS is now deployed on Cloudflare's global edge network! 🚀**
