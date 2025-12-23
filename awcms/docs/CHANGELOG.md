# Changelog

## [Unreleased]

### Added

- New **Sidebar Menu Structure**: Restructured admin sidebar into logical groups (CONTENT, MEDIA, COMMERCE, NAVIGATION, USERS, SYSTEM, CONFIGURATION, PLATFORM).
- Dynamic Sitemap: Added dynamic sitemap generation via Edge Function (`serve-sitemap`) and frontend route (`/sitemap.xml`).
- **Tenant Administration**: Added billing and administrative fields to tenant management (expiry date, billing amount/cycle, contact email, notes).

### Changed

- **Menu Grouping**: Consolidated "Home" into "Dashboard", moved "Themes" to Content, reorganized System and Configuration groups.
- **Database**: Updated `admin_menus` table data to reflect the new structure and remove duplicates.
- **Configuration**: Updated `useAdminMenu.js` default config to match the new database structure.
- **User Module**: Tenant selector now shows based on role (not just for platform admins). Global roles (owner, super_admin) hide tenant field; tenant-scoped roles require tenant selection.
- **Role Filter**: Excluded `public` and `no_access` from assignable roles in UserEditor.
- **Dashboard**: Platform Overview now visible for both `owner` and `super_admin` roles (previously owner only).

### Fixed

- **UserEditor.jsx**: Fixed duplicate query bug in `fetchTenants()`.
- **UserEditor.jsx**: Auto-clear `tenant_id` when switching to global roles.
- **MainRouter.jsx**: Removed typo route `/ssn` (should be `/sso`).
- **TenantSettings.jsx**: Fixed infinite spinner - was using wrong context property (`tenant` instead of `currentTenant`).
- **TenantSettings.jsx**: Fixed invisible Save button - typo `bg-bluen-600` → `bg-blue-600`.

### Changed (SSO & Security)

- **SSOManager.jsx**: Refactored to use Supabase Auth instead of non-existent custom tables.
- Shows Security Overview, Auth Providers, and Login Activity tabs.
- OAuth providers now configured via Supabase Dashboard (not custom UI).

### Removed

- **Legacy Items**: Removed "Locations & Contacts" and duplicate "Home" items from the sidebar.
- **Static Sitemap**: Removed static `sitemap.xml` in favor of the dynamic solution.
- **SSO Custom Tables**: Removed references to `sso_providers`, `sso_role_mappings`, `sso_audit_logs` (non-existent).
