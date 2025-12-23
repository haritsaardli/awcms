
# Component Guide

## Overview

AWCMS uses a component-based architecture with reusable UI components based on shadcn/ui (Radix primitives).

---

## Component Structure

```text
src/components/
├── ui/                 # Base UI components (30 files)
│   ├── button.jsx
│   ├── input.jsx
│   ├── dialog.jsx
│   ├── select.jsx
│   ├── RichTextEditor.jsx
│   ├── ImageUpload.jsx
│   ├── LocationPicker.jsx
│   └── ...
├── dashboard/          # Admin panel components (49+ files)
│   ├── AdminDashboard.jsx
│   ├── AdminLayout.jsx
│   ├── Header.jsx
│   ├── Sidebar.jsx
│   ├── ArticleEditor.jsx
│   ├── ArticlesManager.jsx
│   ├── SidebarMenuManager.jsx
│   └── ...
└── public/             # Public-facing components (9 files)
    ├── PublicHeader.jsx
    ├── PublicFooter.jsx
    └── ...
```

---

## Base UI Components

### Button

```jsx
import { Button } from '@/components/ui/button';

// Variants
<Button>Default</Button>
<Button variant="secondary">Secondary</Button>
<Button variant="destructive">Destructive</Button>
<Button variant="outline">Outline</Button>
<Button variant="ghost">Ghost</Button>
<Button variant="link">Link</Button>

// Sizes
<Button size="sm">Small</Button>
<Button size="default">Default</Button>
<Button size="lg">Large</Button>
<Button size="icon"><Icon /></Button>
```

### Input

```jsx
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';

<div className="space-y-2">
  <Label htmlFor="email">Email</Label>
  <Input id="email" type="email" placeholder="Enter email" />
</div>
```

### Dialog/Modal

```jsx
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from '@/components/ui/dialog';

<Dialog>
  <DialogTrigger asChild>
    <Button>Open Dialog</Button>
  </DialogTrigger>
  <DialogContent>
    <DialogHeader>
      <DialogTitle>Title</DialogTitle>
      <DialogDescription>Description here</DialogDescription>
    </DialogHeader>
    {/* Content */}
  </DialogContent>
</Dialog>
```

### Select

```jsx
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

<Select value={value} onValueChange={setValue}>
  <SelectTrigger>
    <SelectValue placeholder="Select option" />
  </SelectTrigger>
  <SelectContent>
    <SelectItem value="option1">Option 1</SelectItem>
    <SelectItem value="option2">Option 2</SelectItem>
  </SelectContent>
</Select>
```

---

## Rich Text Editor

AWCMS uses TipTap 3.x for rich text editing:

```jsx
import RichTextEditor from '@/components/ui/RichTextEditor';

<RichTextEditor
  value={content}
  onChange={setContent}
  placeholder="Start writing..."
/>
```

**Features:**

- Headings (H1, H2, H3)
- Bold, Italic, Underline, Strikethrough
- Bullet and Ordered Lists
- Blockquotes
- Links and Images
- Undo/Redo
- XSS-safe by default

---

## Dashboard Components

### Key Components

| Component | File | Purpose |
|-----------|------|---------|
| `AdminLayout` | AdminLayout.jsx | Main layout wrapper |
| `Header` | Header.jsx | Top navigation bar |
| `Sidebar` | Sidebar.jsx | Side navigation |
| `ArticleEditor` | ArticleEditor.jsx | Article creation/editing |
| `PageEditor` | PageEditor.jsx | Page creation/editing |
| `SidebarMenuManager` | SidebarMenuManager.jsx | Menu management |
| `PermissionMatrix` | PermissionMatrix.jsx | Role permissions grid |
| `UserProfile` | UserProfile.jsx | User account settings |
| `TwoFactorSettings` | TwoFactorSettings.jsx | 2FA configuration |

### Sidebar

The sidebar is dynamically generated from the database:

```jsx
// Automatic menu loading based on user permissions
// Uses: src/hooks/useAdminMenu.js
// See: src/components/dashboard/Sidebar.jsx
```

// See: src/components/dashboard/Sidebar.jsx

```

---

## Core Data Components

These components form the backbone of the Admin Dashboard, ensuring consistent UI and strict multi-tenancy.

### GenericContentManager

The primary component for listing and managing resources (CRUD).

```jsx
import GenericContentManager from '@/components/dashboard/GenericContentManager';

<GenericContentManager
  tableName="articles"
  resourceName="Article"
  columns={[
    { key: 'title', label: 'Title' },
    { key: 'status', label: 'Status' }
  ]}
  formFields={[
    { key: 'title', label: 'Title', required: true }
  ]}
  // Security
  permissionPrefix="articles" // Mapping: tenant.articles.read
/>
```

**Features:**

- **Automatic Multi-Tenancy**: Automatically filters queries by `tenant_id`.
- **RBAC Integration**: Checks permissions before rendering actions.
- **Search & Pagination**: Built-in server-side handling.

### GenericResourceEditor

The standard form handler for creating/editing resources.

- **Auto-Injection**: Automatically injects `tenant_id` and `created_by` for new records.
- **Validation**: Handles required fields and types.

```

## Public Components

### PublicHeader

```jsx
import PublicHeader from '@/components/public/PublicHeader';

// Features:
// - Dynamic menu from database
// - Language selector
// - Login/Dashboard button
// - Mobile responsive hamburger menu
// - Dark/Light theme toggle
```

### PublicFooter

```jsx
import PublicFooter from '@/components/public/PublicFooter';

// Features:
// - Dynamic menu columns
// - Social media links
// - Contact information
// - Copyright notice
```

---

## Custom Form Components

### ImageUpload

```jsx
import ImageUpload from '@/components/ui/ImageUpload';

<ImageUpload
  value={imageUrl}
  onChange={setImageUrl}
  bucket="articles"
/>
```

### LocationPicker

```jsx
import LocationPicker from '@/components/ui/LocationPicker';

<LocationPicker
  value={{ lat: -6.2, lng: 106.8 }}
  onChange={setLocation}
/>
```

### TagInput

```jsx
import TagInput from '@/components/ui/TagInput';

<TagInput
  value={tags}
  onChange={setTags}
  placeholder="Add tags..."
/>
```

---

## Toast Notifications

```jsx
import { useToast } from '@/components/ui/use-toast';

function MyComponent() {
  const { toast } = useToast();

  const handleAction = () => {
    // Success toast
    toast({
      title: "Success",
      description: "Action completed successfully"
    });

    // Error toast
    toast({
      variant: "destructive",
      title: "Error",
      description: "Something went wrong"
    });
  };
}
```

---

## Component Patterns

### Loading States

```jsx
import { Skeleton } from '@/components/ui/skeleton';

function ArticleList() {
  const { data, loading } = useArticles();

  if (loading) {
    return <Skeleton className="h-[200px] w-full" />;
  }

  return <div>{/* content */}</div>;
}
```

### Error Handling

```jsx
import { Alert, AlertDescription } from '@/components/ui/alert';

function ArticleList() {
  const { data, error } = useArticles();

  if (error) {
    return (
      <Alert variant="destructive">
        <AlertDescription>{error.message}</AlertDescription>
      </Alert>
    );
  }

  return <div>{/* content */}</div>;
}
```

---

## Styling Guidelines

1. Use Tailwind CSS utilities
2. Follow shadcn/ui conventions
3. Use CSS variables for theming (TailwindCSS 4.0)
4. Keep components responsive by default
5. Use `cn()` utility for conditional classes

```jsx
import { cn } from '@/lib/utils';

<div className={cn(
  "base-classes",
  isActive && "active-classes",
  className
)}>
```

---

## Available UI Components

| Component | File | Description |
|-----------|------|-------------|
| AlertDialog | alert-dialog.jsx | Confirmation dialogs |
| Alert | alert.jsx | Inline alerts |
| Avatar | avatar.jsx | User avatars |
| Badge | badge.jsx | Status badges |
| Button | button.jsx | Action buttons |
| Card | card.jsx | Content cards |
| Checkbox | checkbox.jsx | Checkboxes |
| Dialog | dialog.jsx | Modal dialogs |
| DropdownMenu | dropdown-menu.jsx | Dropdown menus |
| Input | input.jsx | Text inputs |
| Label | label.jsx | Form labels |
| Pagination | pagination.jsx | Page navigation |
| Progress | progress.jsx | Progress bars |
| ScrollArea | scroll-area.jsx | Scrollable containers |
| Select | select.jsx | Dropdowns |
| Skeleton | skeleton.jsx | Loading placeholders |
| Slider | slider.jsx | Range sliders |
| Switch | switch.jsx | Toggle switches |
| Table | table.jsx | Data tables |
| Tabs | tabs.jsx | Tabbed interfaces |
| Textarea | textarea.jsx | Multi-line inputs |
| Toast | toast.jsx | Notifications |
| Tooltip | tooltip.jsx | Hover tooltips |
