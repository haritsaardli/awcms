# AWCMS Extension System

## Overview

AWCMS uses a dual extension system combining WordPress-style hooks with modern ES module architecture.

| Type | Location | Loading | Use Case |
| ---- | -------- | ------- | -------- |
| **Core Plugin** | `src/plugins/` | Bundled | Essential features |
| **External Extension** | `awcms-ext-{vendor}-{slug}/` | Dynamic | Third-party modules |

---

## Hook System

### Actions

Execute custom code at specific points:

```javascript
addAction('dashboard_top', 'my_widget', () => console.log('Dashboard loaded!'));
doAction('dashboard_top');
```

### Filters

Modify data passing through:

```javascript
addFilter('admin_sidebar_menu', 'add_menu', (items) => [
  ...items, 
  { label: 'My Plugin', path: '/my-plugin' }
]);
const menuItems = applyFilters('admin_sidebar_menu', defaultItems);
```

---

## Core Plugins

Located in `src/plugins/`. Each plugin requires:

### Structure

```text
src/plugins/{slug}/
├── plugin.json       # Manifest
├── index.js          # Entry with lifecycle
└── Components.jsx
```

### Manifest (`plugin.json`)

```json
{
  "name": "Backup Manager",
  "slug": "backup",
  "version": "1.0.0",
  "type": "core",
  "routes": [{ "path": "/cmspanel/backup", "component": "BackupSettings" }],
  "menu": { "label": "Backup", "icon": "Database", "path": "backup" },
  "permissions": ["tenant.backup.create"]
}
```

### Entry (`index.js`)

```javascript
import manifest from './plugin.json';

export { manifest };

export const register = ({ addAction, addFilter, supabase, pluginConfig }) => {
  addFilter('dashboard_widgets', 'backup', (widgets) => [...widgets, MyWidget]);
};

export const activate = async (supabase, tenantId) => { /* setup */ };
export const deactivate = async (supabase, tenantId) => { /* cleanup */ };
```

---

## External Extensions

Located in `awcms-ext-{vendor}-{slug}/` at project root. Loaded dynamically.

### Directory Structure

```text
awcms-ext-ahliweb-analytics/
├── manifest.json
├── package.json
└── src/index.js
```

### Manifest (`manifest.json`)

```json
{
  "name": "Analytics",
  "slug": "analytics",
  "vendor": "ahliweb",
  "version": "1.0.0",
  "entry": "src/index.js",
  "type": "external",
  "awcms_version": ">=2.0.0"
}
```

---

## Available Hooks

| Hook Name | Type | Description |
| --------- | ---- | ----------- |
| `plugins_loaded` | Action | All plugins loaded |
| `dashboard_widgets` | Filter | Dashboard widgets |
| `admin_menu_items` | Filter | Sidebar menu items |
| `admin_routes` | Filter | Admin panel routes |

---

## Database Tables

### `extensions`

| Column | Type | Description |
| ------ | ---- | ----------- |
| slug | TEXT | Unique identifier |
| extension_type | TEXT | 'core' or 'external' |
| external_path | TEXT | Path for external |
| manifest | JSONB | Plugin manifest |
| config | JSONB | Runtime config |

### `extension_logs`

Audit trail with RLS for all extension actions.

---

## Security

- **RLS**: Tenant isolation on all tables
- **Audit**: Automatic logging via triggers
- **Permissions**: `ext.manage`, `ext.configure`, `ext.view_logs`

---

## Quick Start

1. Create `src/plugins/{slug}/plugin.json`
2. Create `src/plugins/{slug}/index.js` with `register()`
3. Add to `pluginRegistry.js`
4. Insert row in `extensions` table

---

## API Reference

```javascript
import { usePlugins, PluginSlot } from '@/contexts/PluginContext';

const { addAction, addFilter, applyFilters } = usePlugins();

<PluginSlot name="dashboard_top" args={{ user }} />
```
