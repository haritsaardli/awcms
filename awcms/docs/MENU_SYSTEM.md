# Admin Menu System

## Overview

AWCMS menggunakan sistem menu admin yang dinamis dan terpusat. Struktur menu disimpan dalam database (`admin_menus`) dan memiliki fallback configuration di frontend (`useAdminMenu.js`).

## Menu Structure

Menu dibagi menjadi beberapa grup logis untuk memudahkan navigasi:

| Group | Order | Description | Modules |
|-------|-------|-------------|---------|
| **CONTENT** | 10 | Manajemen konten utama | Dashboard, Articles, Pages, Visual Builder, Themes, Portfolio, Testimonials, Announcements, Promotions, Contact Messages |
| **MEDIA** | 20 | Manajemen file dan galeri | Media Library, Photo Gallery, Video Gallery |
| **COMMERCE** | 30 | E-commerce features | Products, Product Types, Orders |
| **NAVIGATION** | 40 | Pengaturan navigasi situs | Menu Manager, Categories, Tags |
| **USERS** | 50 | Manajemen pengguna dan akses | Users, Roles & Permissions |
| **SYSTEM** | 60 | Pengaturan sistem dan tools | SEO Manager, Languages, Extensions, Sidebar Manager, Notifications, Audit Logs |
| **CONFIGURATION** | 70 | Pengaturan global tenant | Branding, SSO & Security |
| **PLATFORM** | 100 | Super Admin functions | Tenant Management |

## Configuration

Menu dikonfigurasi melalui dua layer:

1. **Database (`admin_menus` table)**
   - Source of truth utama.
   - Kolom: `id`, `key`, `label`, `path`, `icon`, `permission`, `group_label`, `group_order`, `order`, `is_visible`.
   - Mendukung reordering dan renaming via **Sidebar Manager**.

2. **Frontend Config (`src/hooks/useAdminMenu.js`)**
   - Fallback jika database kosong atau gagal dimuat.
   - Harus selalu disinkronkan dengan struktur database default.

## Permissions

Setiap item menu dilindungi oleh permission key (ABAC). Contoh:

- `Articles` -> `tenant.post.read`
- `Settings` -> `tenant.setting.update`
- `Tenant Management` -> `platform.tenant.read`

## Adding New Menu Items

Untuk menambahkan menu baru:

1. Tambahkan entry ke tabel `admin_menus`.
2. Pastikan permission key sesuai dengan modul.
3. Update `DEFAULT_MENU_CONFIG` di `useAdminMenu.js` untuk konsistensi.
