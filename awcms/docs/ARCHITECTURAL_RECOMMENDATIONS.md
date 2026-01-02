# Architectural Recommendations for AWCMS

Based on the latest documentation from Context7 for **Vite 7**, **Tailwind CSS v4**, and **Supabase**, here are comprehensive recommendations for your implementation.

## 1. UI/UX: Tailwind CSS v4 Architecture

### Recommendation: Use Native CSS Variables for Theming

Tailwind v4 introduces a native CSS-first configuration via `@theme`. Instead of a JavaScript `tailwind.config.js`, define your design system directly in CSS. This improves performance and runtime dynamic capabilities.

**Action Items:**

* **Migrate tokens**: Move all color palettes and font definitions to the `@theme` block in your main CSS file.
* **Consistent Scaling**: Use the detailed **oklch** color space for 11-step color scales (50-950) as recommended by Tailwind v4 docs. This ensures perceptual uniformity across light/dark modes.
* **Dynamic Theming**: Use the `var(--color-*)` syntax for multi-tenant theming. Since Tailwind v4 exposes theme variables natively, you can swap themes simply by updating the CSS variables on the `<body>` or `<html>` tag via your `TenantContext`.

```css
@theme {
  --color-primary-500: oklch(63.7% 0.237 25.331);
  --font-sans: "Inter", system-ui, sans-serif;
}
/* Multi-tenant override via CSS variables */
[data-tenant="client-a"] {
  --color-primary-500: oklch(55.3% 0.195 38.402);
}
```

## 2. Security: Supabase Multi-Tenancy

### Recommendation: Strict RLS with Tenant Isolation

For a robust multi-tenant system, relying solely on "filtering" in the frontend is insufficient. You must enforce isolation at the database row level.

**Action Items:**

* **RLS Policies**: Ensure *every* table has policies for SELECT, INSERT, UPDATE, DELETE checking `tenant_id`.
* **Auth Context**: Use `auth.uid()` consistently.
* **Performance Indexing**: Add a database index on `tenant_id` for every table. RLS checks happen on every query, so an unindexed `tenant_id` column will kill performance as data grows.

```sql
-- Pattern for strict isolation
create policy "Tenant Isolation" on public.widgets
  using (tenant_id = (select tenant_id from auth.users where id = auth.uid()));
```

## 3. Performance: Vite 7 Optimization

### Recommendation: Warmup & Async Chunk Loading

Vite 7 offers advanced build optimizations that are crucial for a large Admin Dashboard like AWCMS.

**Action Items:**

* **Server Warmup**: Configure `server.warmup` in `vite.config.js` to pre-transform critical files (e.g., `MainLayout.jsx`, `Sidebar.jsx`, `SupabaseAuthContext.jsx`) during dev server start. This eliminates the "waterfall" delay on the first page load.
* **Target Modern Browsers**: Set `build.target` to `'baseline-widely-available'` (Vite 7 default) to ship smaller, more efficient code by avoiding unnecessary polyfills.
* **Async Chunk Loading**: Leverage Vite's automatic dynamic import optimization. Ensure generic heavy admin modules (like `Analytics` or `VisualEditor`) are lazy-loaded using `React.lazy()` or dynamic imports, allowing Vite to fetch their dependencies in parallel.

```javascript
// vite.config.js
export default defineConfig({
  server: {
    warmup: {
      clientFiles: ['./src/components/layouts/*.jsx', './src/contexts/*.jsx']
    }
  }
})
```

## 4. React 18: Enterprise Patterns

### Recommendation: Boundary-Based Error Handling

For a mission-critical CMS, a crash in one widget shouldn't break the entire dashboard.

**Action Items:**

* **Error Boundaries**: Wrap major "Slots" or "Widgets" in React Error Boundaries. If a custom external extension crashes, it should display a localized error UI rather than a white screen of death.
* **Transition API**: Use `useTransition` when switching major dashboard tabs to keep the UI responsive during heavy data fetching.

## Summary Checklist

- [ ] **CSS**: Convert `tailwind.config.js` logic to `@theme` CSS variables.
* [ ] **DB**: Verify generic `tenant_id` indexes on all tables.
* [ ] **Build**: Add `server.warmup` to `vite.config.js`.
* [ ] **React**: Implement Error Boundaries around Extension Slots.
