
# Configuration Guide

## Environment Variables

AWCMS uses environment variables for configuration. Create a `.env.local` file in the project root.

### Required Variables

```env
# Supabase Configuration (Required)
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Optional Variables

```env
# Admin/Server Operations (Optional - Use with caution)
VITE_SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Application Settings
VITE_APP_NAME=AWCMS
VITE_DEFAULT_LOCALE=en

# Multi-Tenancy (Development)
VITE_DEV_TENANT_SLUG=demo-tenant # Simulates subdomain in localhost
```

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

## Tailwind CSS Configuration (v4.0)

TailwindCSS 4.0 uses CSS-based configuration instead of `tailwind.config.js`.

Configuration is done in `src/index.css`:

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

> **Note:** `tailwind.config.js` is no longer needed in TailwindCSS 4.0

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
|--------|--------|---------|
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
|---------|-------------|------------|
| Source Maps | Enabled | Disabled |
| HMR | Enabled | N/A |
| Minification | Disabled | Enabled |
| Error Details | Full | Limited |
| API URL | Same | Same |
