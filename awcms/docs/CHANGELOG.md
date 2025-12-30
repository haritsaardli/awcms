# Changelog

All notable changes to AWCMS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [2.0.0] "Aurora" - 2025-12-30

### Added

- **Versioning System**: Centralized version management with `src/lib/version.js`
- **Version Badge**: UI component for displaying version in admin panel
- **Documentation Audit**: 7 new documentation files
  - CONTRIBUTING.md - Contribution guidelines
  - CODE_OF_CONDUCT.md - Community standards
  - LICENSE.md - MIT license with third-party attribution
  - OFFLINE_ARCHITECTURE.md - Offline-first implementation guide
  - ROLE_HIERARCHY.md - Role levels and permission matrix
  - AUDIT_TRAIL.md - Audit logging documentation
  - RLS_POLICIES.md - Row Level Security reference
- **Role Migration**: Changed `super_super_admin` to `owner` as supreme role
- **RLS Fix**: Global roles (owner, super_admin) now readable by all users
- **Security Hardening**: Added `SET search_path = ''` to SECURITY DEFINER functions

### Changed

- **PERFORMANCE.md**: Expanded from 682 bytes to 4.8 KB
- **MONITORING.md**: Expanded from 573 bytes to 4.1 KB
- **INDEX.md**: Added Security & Access Control section
- **Package Version**: Updated to 2.0.0

### Fixed

- RLS policy on `roles` table blocking global role access
- Supabase Security Advisor warnings for function search_path

---

## [1.0.0] - 2025-12-15

### Added (1.0.0)

- **Sidebar Menu Structure**: Logical groups (CONTENT, MEDIA, COMMERCE, etc.)
- **Dynamic Sitemap**: Edge Function (`serve-sitemap`) generation
- **Tenant Administration**: Billing and administrative fields
- **Multi-Tenant Architecture**: Full tenant isolation with RLS
- **ABAC System**: Attribute-Based Access Control
- **Visual Builder**: Puck-based page builder
- **Internationalization**: EN and ID language support

### Changed (1.0.0)

- Menu Grouping consolidated and reorganized
- User Module tenant selector based on role
- Dashboard Platform Overview for owner and super_admin

### Fixed (1.0.0)

- UserEditor.jsx duplicate query bug
- MainRouter.jsx typo route `/ssn`
- TenantSettings.jsx infinite spinner
- TenantSettings.jsx invisible Save button

---

## Version History Summary

| Version | Codename | Date | Highlights |
| ------- | -------- | ---- | ---------- |
| 2.0.0 | Aurora | 2025-12-30 | Versioning, Documentation Audit, Role Migration |
| 1.0.0 | - | 2025-12-15 | Initial Release, Multi-Tenancy, ABAC |
