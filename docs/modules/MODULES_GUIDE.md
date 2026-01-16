# Modules Guide

## Purpose

Describe how admin modules are organized and where to find them in the codebase.

## Audience

- Admin panel developers
- Extension authors

## Prerequisites

- `docs/architecture/folder-structure.md`
- `docs/modules/ADMIN_UI_ARCHITECTURE.md`

## Core Concepts

- Modules map to routes, menu entries, and permission keys.
- Most module UIs live under `awcms/src/components/dashboard` as `*Manager.jsx` files.
- Plugins can add modules via the extension system.

## Module Structure

| Component Type | Location | Naming |
|----------------|----------|--------|
| Manager Components | `awcms/src/components/dashboard/` | `*Manager.jsx` |
| Route Pages | `awcms/src/pages/cmspanel/` | Module-specific |
| Sidebar Config | `awcms/src/templates/flowbite-admin/components/Sidebar.jsx` | `MENU_ITEMS` |

## How It Works

1. Routes are defined in `awcms/src/components/MainRouter.jsx`
2. Sidebar items are configured in `Sidebar.jsx` with icons and permissions
3. Each module uses `AdminPageLayout` and `PageHeader` for consistent UI
4. `useAdminMenu()` loads the menu configuration for dynamic menus

## Implementation Patterns

### Adding a New Module

1. Create `YourManager.jsx` in `awcms/src/components/dashboard/`:

```jsx
import { AdminPageLayout, PageHeader } from '@/templates/flowbite-admin';
import GenericContentManager from '@/components/dashboard/GenericContentManager';
import { FileText } from 'lucide-react';

function YourManager() {
  return (
    <AdminPageLayout requiredPermission="tenant.your_module.read">
      <PageHeader
        title="Your Module"
        description="Manage your content."
        icon={FileText}
        breadcrumbs={[{ label: 'Your Module', icon: FileText }]}
      />
      <GenericContentManager
        tableName="your_table"
        resourceName="Item"
        columns={[{ key: 'name', label: 'Name' }]}
        formFields={[{ key: 'name', label: 'Name', required: true }]}
        permissionPrefix="your_module"
        showBreadcrumbs={false}
      />
    </AdminPageLayout>
  );
}

export default YourManager;
```

1. Add route in `MainRouter.jsx`
2. Add sidebar entry in `Sidebar.jsx` `MENU_ITEMS`

## Available Modules (38 Managers)

| Category | Modules |
|----------|---------|
| **Content** | Articles, Pages, Tags, Categories, Visual Pages, Theme Layouts |
| **Media** | Files (Media Library), Photo Gallery, Video Gallery |
| **Commerce** | Products, Product Types, Orders, Promotions, Payment Methods |
| **Services** | Services, Team, Testimony, Partners, Portfolio, Fun Facts |
| **Engagement** | Contacts, Contact Messages, Announcements |
| **Extensions** | Extensions, Themes, Templates, Widgets, Visual Builder |
| **Access** | Users, Roles, Permissions, Policies |
| **System** | Settings, SEO, Branding, Tenants, Audit Logs, SSO, Approvals |

## Permissions and Access

- Every module must use `AdminPageLayout` with `requiredPermission` prop
- Use `usePermissions()` for additional checks:

```jsx
const { hasPermission, isPlatformAdmin } = usePermissions();
```

- Use `useTenant()` to scope tenant data

## Security and Compliance Notes

- Use soft delete patterns (`deleted_at` column)
- All queries must filter by `tenant_id` (enforced by RLS)
- Never expose sensitive data without permission checks

## References

- `docs/modules/ADMIN_UI_ARCHITECTURE.md`
- `docs/modules/MENU_SYSTEM.md`
- `docs/security/abac.md`
