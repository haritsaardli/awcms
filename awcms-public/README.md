# AWCMS Public Portal

The public-facing frontend for AWCMS multi-tenant content management system, built with Astro.

## 🏗️ Architecture

This is a **Server-Side Rendered (SSR)** Astro application deployed to Cloudflare Pages. It serves public content for multiple tenants using path-based routing.

### URL Structure

```txt
/{tenant}/{page-slug}
```

**Examples:**

```txt
/primary/              → Primary tenant homepage
/primary/articles/     → Articles listing
/primary/pages/about/  → About page
/tenant-b/             → Another tenant's homepage
```

## 🚀 Getting Started

### Prerequisites

* Node.js 20+
* npm or pnpm

### Installation

```bash
cd awcms-public
npm install
```

### Development

```bash
npm run dev
```

The dev server runs at `http://localhost:4321`. By default, it uses the `VITE_DEV_TENANT_HOST` environment variable for tenant resolution.

### Environment Variables

Create `.env` based on `.env.example`:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
VITE_DEV_TENANT_HOST=localhost  # For local development
```

## 📁 Project Structure

```txt
/
├── public/             # Static assets
├── src/
│   ├── components/     # Astro/React components
│   ├── layouts/        # Page layouts
│   ├── lib/            # Utilities (supabase, url builder)
│   ├── pages/
│   │   ├── index.astro           # Root redirect
│   │   └── [tenant]/
│   │       └── [...slug].astro   # Tenant-scoped pages
│   ├── styles/         # Global CSS
│   └── templates/      # Template themes
├── astro.config.mjs    # Astro configuration
└── package.json
```

## 🔗 Tenant Resolution

The middleware resolves tenants in this order:

1. **Path Parameter** (Primary): Extracts tenant slug from URL path (`/{tenant}/...`)
2. **Host Header** (Fallback): Looks up tenant by domain/subdomain

If resolved from host, the user is redirected to the canonical path-based URL.

## 🛠️ Commands

| Command | Action |
| :--- | :--- |
| `npm run dev` | Start dev server at `localhost:4321` |
| `npm run build` | Build for production |
| `npm run preview` | Preview production build locally |

## 📚 Documentation

* [Migration Guide](../awcms/docs/01-guides/MIGRATION.md) - URL structure changes
* [Deployment Guide](../awcms/docs/01-guides/DEPLOYMENT.md) - Cloudflare Pages setup
* [Main Documentation](../awcms/docs/INDEX.md) - Full documentation index
