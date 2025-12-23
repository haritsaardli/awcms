# Modules Guide

AWCMS provides a diverse set of modules for managing content, products, users, and system configuration.

## 1. Commerce & Products

- **Products**: Full inventory management with SKU, Price, Stock, Weight, Dimensions, and Product Types.
- **Orders** *(New)*: Track sales, manage order status (Pending, Processing, Shipped), and customer shipping details.
- **Categories**: Hierarchical categorization for products.

## 2. Subscription & Limits (Multi-Tenant)

- **Usage Dashboard**: Real-time view of Resource Usage (Users, Storage) vs Plan Limits.
- **Plan Constraints**:
  - **Free**: 5 Users, 100MB Storage.
  - **Pro**: 50 Users, 10GB Storage.
  - **Enterprise**: Unlimited.
- **Enforcement**: Automatic blocking of actions (adding users, uploading files) when limits are exceeded.

## 3. Visual Page Builder

- **Visual Editor**: Drag-and-drop interface to build complex pages using pre-defined blocks.
- **Block Library**: Includes Hero, Feature, Text, Image, Gallery, Latest Articles, Testimonials, Pricing, and more.
- **Themes & Templates**: Manage system layouts (Homepage, Header, Footer) via `ThemeLayoutManager`.

## 4. Content Management

- **Articles**: Standard blog posts with Rich Text Editor, Featured Image, Categories, Tags, and SEO Metadata.
- **Pages**: Static pages (About, Contact) with optional Visual Builder integration.
- **Portfolio**: Showcase projects with client details, start/end dates, and image galleries.
- **Testimonies**: Client reviews with star ratings (1-5) and author profiles.
- **Announcements**: Time-sensitive alerts (Low, High, Urgent) with expiration dates.
- **Promotions**: Marketing campaigns with Discount %/Amount, Validity period, and visual variants (Banner, Card).

## 5. Media & Galleries

- **Media Library**: Centralized file management with drag-and-drop upload, folder organization, and image previews.
- **Photo Gallery**: Create albums and manage photo collections.
- **Video Gallery**: Embed YouTube/Vimeo videos or manage video playlists.

## 6. User Management & Security

- **Users**: Manage accounts, roles, and status (Active/Suspended). Soft-delete support prevents data loss.
- **Roles & Permissions**: Granular "Permission Matrix" to control access (View, Create, Edit, Delete) for every module.
- **Profile**: Self-service profile management, Password Change, and **Two-Factor Authentication (2FA)** setup with backup codes.
- **Turnstile CAPTCHA**: Secure login with Cloudflare Turnstile integration (Server-side verification).

## 7. Navigation & Menus

- **Sidebar Admin**: Customize the Admin Panel sidebar (Group, Reorder, Hide items) via `SidebarManager`.
- **Frontend Menus**: Manage recursive website menus (Header, Footer) via `MenusManager` and `NavigationBlock`.

## 8. System & Configuration

- **Branding** *(New)*: Setup Tenant Identity (Logo, Brand Color, Font) for white-labeling.
- **Settings** *(New)*: Manage global system variables (Site Title, Maintenance Mode, Logo).
- **Audit Logs** *(New)*: Read-only view of all system activity (Who did what, when).
- **Extensions**: Modular plugin architecture with Install/Activate/Delete lifecycle.
- **Internationalization (i18n)**: Manage supported languages (ID/EN) and translation keys.
- **SEO**: Global and resource-specific SEO settings (Sitemap generation).
- **Backups**: Database and file backup configuration and scheduling.
- **SSO**: Single Sign-On configuration for enterprise authentication.

## 9. Communication & Notifications

- **Notifications**: System-wide alerts and user notification management.
- **Inbox/Messages**: Centralized management of contact form submissions and messages.
