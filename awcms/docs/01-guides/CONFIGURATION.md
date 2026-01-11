
# Configuration Guide

## Environment Variables

AWCMS uses environment variables for configuration. The Admin Panel (`awcms`) uses `.env.local`, while the Public Portal (`awcms-public/primary`) uses `.env` (or Cloudflare Pages environment variables).

### Admin Panel (`awcms`)

Create `.env.local` in `awcms/`.

**Required variables**

```env
# Supabase Configuration (Required)
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Cloudflare Turnstile (Required for Login)
VITE_TURNSTILE_SITE_KEY=1x00000000000000000000AA # Use Test Key for Localhost
```

**Optional variables**

```env
# Admin/Server Operations (Optional - Use with caution)
VITE_SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Application Settings
VITE_APP_NAME=AWCMS
VITE_DEFAULT_LOCALE=en

# Multi-Tenancy (Development)
VITE_DEV_TENANT_SLUG=demo-tenant # Simulates subdomain in localhost
```

### Public Portal (`awcms-public/primary`)

Create `.env` in `awcms-public/primary/`.

**Required variables**

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
```

**Optional variables**

```env
VITE_DEV_TENANT_HOST=localhost # Overrides host-based tenant resolution in dev
```

### Cloudflare Runtime (Public Portal)

For the Astro-based Public Portal running on Cloudflare Pages, environment variables are read from `context.locals.runtime.env` in `awcms-public/primary/src/middleware.ts`. Ensure these are set in the Cloudflare Dashboard:

- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`

---

## Vite Configuration

The Vite configuration is located at `vite.config.js`:

```javascript
export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    host: true,
    headers: {
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block'
    }
  },
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src')
    }
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor-react': ['react', 'react-dom', 'react-router-dom'],
          'vendor-supabase': ['@supabase/supabase-js'],
          'vendor-ui': ['@radix-ui/react-dialog', ...]
        }
      }
    }
  }
});
```

---

## Tailwind CSS Configuration

### Admin Panel (TailwindCSS 4.1)

TailwindCSS 4.x uses CSS-based configuration instead of `tailwind.config.js`.

Configuration is done in `awcms/src/index.css`:

```css
@import "tailwindcss";

/* Theme customization */
@theme {
  --color-primary: oklch(0.7 0.15 200);
  --color-secondary: oklch(0.6 0.12 250);
  --font-sans: "Inter", system-ui, sans-serif;
}

/* Dark mode variables */
.dark {
  --color-background: oklch(0.15 0.02 200);
  --color-foreground: oklch(0.95 0.01 200);
}
```

### Customizing Theme

- Use `@theme` directive for custom properties
- Dark mode is handled via CSS variables and `.dark` class
- Animations via `tailwindcss-animate` plugin still work

> **Note:** `tailwind.config.js` is not required for the Admin Panel under TailwindCSS 4.x.

### Public Portal (TailwindCSS 4.1)

The Public Portal uses TailwindCSS 4.x via the Vite plugin in `awcms-public/primary/astro.config.mjs`.

- **Vite plugin**: `@tailwindcss/vite`
- **Entry CSS**: `awcms-public/primary/src/styles/global.css` uses `@config "../../tailwind.config.mjs";` + `@import "tailwindcss";`
- **Config**: `awcms-public/primary/tailwind.config.mjs` for content globs and theme extensions

---

## i18n Configuration

### Adding a New Language

1. Create translation file: `src/locales/fr.json`

2. Register in `src/i18n.js`:

```javascript
import fr from './locales/fr.json';

i18n.init({
  resources: {
    en: { translation: en },
    id: { translation: id },
    fr: { translation: fr } // Add new language
  }
});
```

1. Add to language selector in `src/components/ui/LanguageSelector.jsx`

### Translation File Structure

```json
{
  "menu": {
    "home": "Home",
    "articles": "Articles"
  },
  "auth": {
    "login": "Login",
    "logout": "Logout"
  }
}
```

---

## Supabase Configuration

### Row Level Security (RLS)

Enable RLS on all tables and create policies:

```sql
-- Example: Users can only update their own profile
CREATE POLICY "Users can update own profile"
ON public.users
FOR UPDATE
USING (auth.uid() = id);
```

### Storage Buckets

Configure bucket policies in Supabase Dashboard:

| Bucket | Public | Purpose |
| :--- | :--- | :--- |
| avatars | Yes | User profile pictures |
| articles | Yes | Article featured images |
| files | No | Private file uploads |

---

## Security Configuration

### Content Security Policy

For production, add CSP headers in your hosting configuration:

```text
Content-Security-Policy: 
  default-src 'self';
  script-src 'self' 'unsafe-inline';
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  connect-src 'self' https://*.supabase.co wss://*.supabase.co;
```

### CORS Configuration

CORS is handled by Supabase. No additional configuration needed for standard deployments.

---

## Performance Configuration

### Build Optimization

The production build is automatically optimized with:

- Code splitting (vendor chunks)
- Tree shaking
- Minification
- Gzip compression ready

### Caching Strategy

Recommended headers for static assets:

```text
Cache-Control: public, max-age=31536000, immutable
```

For HTML:

```text
Cache-Control: no-cache
```

---

## Development vs Production

| Feature | Development | Production |
| :--- | :--- | :--- |
| Source Maps | Enabled | Disabled |
| HMR | Enabled | N/A |
| Minification | Disabled | Enabled |
| Error Details | Full | Limited |
| API URL | Same | Same |
