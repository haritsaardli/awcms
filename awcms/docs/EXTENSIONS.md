# Extension System Documentation

## Overview

AWCMS uses a **WordPress-style Hook System** (Actions and Filters) to allow extensions to modify system behavior and inject content without altering core files. This system is managed via `src/lib/hooks.js` and provided globally through `PluginContext`.

## Core Concepts

### 1. Actions (`addAction`, `doAction`)

Actions allow you to execute custom code at specific points in the application lifecycle.

```javascript
// Register an action
addAction('dashboard_top', 'my_custom_widget', () => {
  console.log('Dashboard loaded!');
});

// Trigger an action (Core)
doAction('dashboard_top');
```

### 2. Filters (`addFilter`, `applyFilters`)

Filters allow you to modify data passing through the system, such as menu items, content, or configurations.

```javascript
// Register a filter
addFilter('admin_sidebar_menu', 'add_my_menu', (items) => {
  return [...items, { label: 'My Plugin', path: '/my-plugin' }];
});

// Apply filters (Core)
const menuItems = applyFilters('admin_sidebar_menu', defaultItems);
```

## Plugin Architecture

### Registration

Extensions are React components or logic modules registered in `src/lib/extensionRegistry.js`. Each extension must export a `register` function.

**Example `src/extensions/helloworld/HelloWorld.js`:**

```javascript
export const register = ({ addAction, addFilter }) => {
    // Add a widget to the dashboard
    addFilter('dashboard_widgets', 'hello_world_widget', (widgets) => {
        return [...widgets, MyWidgetComponent];
    });

    // Add a menu item
    addFilter('admin_sidebar_menu', 'hello_world_menu', (items) => {
        return [...items, { key: 'hello', label: 'Hello World', path: '/hello' }];
    });
};
```

### UI Injection (`PluginAction`)

The `<PluginAction />` component creates a "slot" in the UI where multiple extensions can render content.

**Usage in Core:**

```javascript
// AdminDashboard.jsx
<PluginAction name="dashboard_top" args={[userRole]} />
```

**Usage in Extension:**

```javascript
// Register a component to render in that slot
addFilter('dashboard_top', 'my_banner', (components) => {
    return [...components, MyBannerComponent];
});
```

## Available Hooks

| Hook Name | Type | Description | Args |
|-----------|------|-------------|------|
| `plugins_loaded` | Action | Fired when all plugins are initialized | None |
| `admin_sidebar_menu` | Filter | Modify sidebar menu items | `items`, `context` |
| `dashboard_top` | Filter | Inject components at top of dashboard | `components` |
| `dashboard_widgets` | Filter | Inject widget components | `components` |

## Developing an Extension

1. **Create Directory**: `src/extensions/your-extension-name/`
2. **Create Main File**: `index.js` exporting your components and `register` function.
3. **Register**: Import in `src/lib/extensionRegistry.js` and add to map.
4. **Activate**: Insert record into `extensions` table in Supabase.
