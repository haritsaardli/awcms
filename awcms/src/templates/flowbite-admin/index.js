/**
 * Flowbite Admin Template
 * 
 * Replaces awadmintemplate01.
 * @module flowbite-admin
 */

// Layout Components (New)
export { default as AdminPageLayout } from './layouts/AdminPageLayout';
export { default as PageHeader } from './components/PageHeader';
export { default as Navbar } from './components/Navbar';
export { default as Sidebar } from './components/Sidebar';
export { default as Footer } from './components/Footer';

// Data Display Components (Legacy/Shared)
export { default as DataTable } from './components/legacy/DataTable';
export { default as EmptyState } from './components/legacy/EmptyState';
export { default as LoadingSkeleton } from './components/legacy/LoadingSkeleton';
export { default as PageTabs, TabsContent } from './components/legacy/PageTabs';
export { default as TenantBadge } from './components/legacy/TenantBadge';

// Form Components (Legacy/Shared)
export { default as FormWrapper } from './components/legacy/FormWrapper';

// Access Control Components (Legacy/Shared)
export { default as NotAuthorized } from './components/legacy/NotAuthorized';

export const TEMPLATE_VERSION = '1.0.0';
export const TEMPLATE_NAME = 'flowbite-admin-react';
