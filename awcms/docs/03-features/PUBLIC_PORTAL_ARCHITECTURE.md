# AWCMS Public Portal Architecture

## Overview

The Public Portal is a high-performance, secure, multi-tenant frontend built with **Astro** and **React**, deployed to **Cloudflare Pages**. It consumes content from the AWCMS Core via Supabase, strictly isolating data by tenant.

## 1. Multi-Tenancy Architecture

- **Tenant Resolution** (Priority Order):
  1. **Path Parameter** (Primary): Extracts tenant slug from first URL segment (`/{tenant}/...`).
  2. **Host Header** (Fallback): Maps `Host` header → `public.tenants` (via RPC `get_tenant_id_by_host`).
  - Middleware (`src/middleware.ts`) sets `locals.tenant_id` and `locals.tenant_slug`.
  - Host-resolved tenants are redirected to canonical path-based URLs (301).
- **URL Structure**: `/{tenant}/{slug}` (e.g., `/primary/articles/`)
- **Data Isolation**:
  - **RLS**: Row-Level Security policies on `articles` table compel tenant check.
  - **View**: `published_articles_view` filters `tenant_id` and ensures only `published` content is accessible.

> See [Migration Guide](../01-guides/MIGRATION.md) for URL structure details.

## 2. Rendering Pipeline

### A. Puck Layouts

- **File**: `src/components/PuckRenderer.tsx`
- **Logic**: Iterates over `puck_layout_jsonb` structure.
- **Security**:
  - Uses `src/components/registry.tsx` as a strictly typed Whitelist.
  - Runtime prop validation via **Zod Schemas**.
  - Drop unknown components (dev warning / prod silence).

### B. Rich Text (TipTap)

- **File**: `src/components/TipTapRenderer.tsx`
- **Strategy**: **JSON to React Tree**.
  - No `dangerouslySetInnerHTML`.
  - Direct mapping of nodes (heading, paragraph, image) to React Elements.
  - Attributes (like `href`) are sanitized and strictly controlled.

## 3. Security Hardening

- **CSP (Content Security Policy)**:
  - Enforced via `public/_headers` (Cloudflare Pages standard).
  - `script-src 'self' ...`: No external scripts except whitelisted analytics.
  - `frame-ancestors 'none'`: Prevents clickjacking.
- **XSS Protection**:
  - React's innate escaping + strict JSON-to-Component mapping eliminates most XSS vectors.

## 4. Deployment

- **Platform**: Cloudflare Pages.
- **Adapter**: `@astrojs/cloudflare` (Server mode).
- **Environment**:
  - `VITE_SUPABASE_URL`: Public Supabase URL.
  - `VITE_SUPABASE_ANON_KEY`: Public Anon Key (scoped by RLS).

## 5. Template System Integration

- **Dynamic Routing** (`[tenant]/[...slug].astro`):
  - Validates tenant param matches resolved tenant from middleware.
  - Fetches page data from `pages` table.
  - Fetches `template_assignments` for the current channel.
  - Determines template from page override or channel assignment.
  - Merges **Header Part** + **Page Content** + **Footer Part** into final layout.
- **Root Redirect** (`index.astro`):
  - Redirects `/` to `/primary/` (default tenant).
- **URL Builder** (`src/lib/url.ts`):
  - `tenantUrl(slug, path)`: Builds tenant-prefixed URLs.
  - Used by Navbar, Footer, and all internal links.
- **Component Registry** (`registry.tsx`):
  - Whitelists allowed components including Core Widgets (`core/text`, `core/image`, `core/menu`, `core/button`).
  - Validates props with Zod schemas.

## 6. Compliance

- **Audit**: All public interactions (forms, etc.) should log to `audit_logs` via Edge Functions.
- **Privacy**: No PII stored in local storage without consent.
