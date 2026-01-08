# Multi-Tenancy Architecture

## Overview

AWCMS uses a **Logical Isolation** model on a **Shared Database**. This allows for high scalability while maintaining strict data separation.

## 1. Tenant Resolution

### Admin Panel

* **Context**: Users log in to a unified dashboard (`/cmspanel`).
* **Resolution**: `tenant_id` is derived from the User's Profile (`users.tenant_id`) upon login.
* **Switching**: Platform Admins can "Assume Identity" of a tenant using the Tenant Switcher.

### Public Portal

* **Context**: Visitors access `example.com/{tenant}/` or legacy `tenant.awcms.com`.
* **Resolution** (Priority Order):
    1. **Path Parameter** (Primary): Extract tenant slug from first URL segment (`/{tenant}/...`).
    2. **Host Header** (Fallback): Queries `get_tenant_id_by_host(host)` RPC function.
* **Middleware**: `src/middleware.ts` intercepts the Request.
* **Context**: Sets `Astro.locals.tenant_id` and `Astro.locals.tenant_slug`.
* **Redirects**: Host-resolved tenants are redirected to canonical path-based URLs.

> See [Migration Guide](../01-guides/MIGRATION.md) for URL structure details.

## 2. Row Level Security (RLS)

Every query to the database is filtered by RLS policies.

### The Golden Rule
>
> **"Every table must have a `tenant_id` column and RLS enabled."**

### Policy Logic

```sql
-- Standard Policy
CREATE POLICY "Tenant Isolation" ON table_name
USING (tenant_id = (select auth.uid() ->> 'tenant_id')::uuid);
```

## 3. Shared vs Isolated Resources

| Resource | Scope | Description |
| -------- | ----- | ----------- |
| **Users** | Isolated | Users belong to ONE tenant (except Super Admin). |
| **Media** | Isolated | Storage buckets structured as `/{tenant_id}/{file.ext}`. |
| **Settings** | Hybrid | `system_settings` (Global) vs `tenant_configs` (Tenant). |
| **Extensions** | Shared | Installed globally, enabled per-tenant. |

## 4. Onboarding Flow

1. **Registration**: New Tenant creation triggers `create_tenant` RPC.
2. **Seeding**: `create_tenant_with_defaults` seeds initial Roles, Pages, and Menus.
3. **DNS**: Tenant configures CNAME to Cloudflare.
4. **Verification**: Admin updates `tenants.host` column.
