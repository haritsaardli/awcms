# Multi-Tenant Theming Guide

## Overview

AWCMS supports dynamic white-labeling, allowing each tenant to have their own brand identity (colors, fonts, logo) without code changes.

## Architecture

1. **Storage**: Theme preferences are stored in the `tenants.config` JSONB column.
2. **Injection**: `useTenantTheme` hook injects CSS variables into the `:root` (or `#root`) element at runtime.
3. **Usage**: Tailwind utilities use these CSS variables, ensuring components update automatically.

## Tenant Config Structure

```json
{
  "theme": {
    "colors": {
      "brand": "#3b82f6"
    },
    "fonts": {
      "sans": "Inter"
    },
    "logo": "https://tenant-bucket/logo.png"
  }
}
```

## CSS Variables

The system automatically generating the following variables based on the tenant's brand color:

| Variable | Description | Default |
|----------|-------------|---------|
| `--primary` | Main brand color (HSL) | `222.2 47.4% 11.2%` |
| `--font-sans` | Primary font family | `"Inter", sans-serif` |

## Usage in Components

### 1. Using Tailwind Classes (Recommended)

Always use the semantic utility classes, never hardcode colors.

```jsx
// ✅ Correct
<Button className="bg-primary text-primary-foreground">
  Action
</Button>

// ❌ Incorrect
<Button className="bg-blue-600 text-white">
  Action
</Button>
```

### 2. Using CSS Variables Directly

```css
.custom-card {
  background-color: hsl(var(--primary));
  font-family: var(--font-sans);
}
```

## Configuring a New Tenant

1. Go to **Settings > Branding**.
2. Upload a Logo.
3. Select a Brand Color.
4. Choose a Font Family.
5. Click **Save Changes**.

The theme will update instantly across the user's session.
