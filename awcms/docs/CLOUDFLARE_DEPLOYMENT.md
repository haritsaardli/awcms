# AWCMS - Cloudflare Pages Deployment Guide

This repository is set up as a **Monorepo**. For deployment on Cloudflare Pages, you will need to create **two separate projects**: one for the Admin Panel (`awcms`) and one for the Public Portal (`awcms-public`).

## Prerequisites

- GitHub/GitLab repository with AWCMS code
- Cloudflare account (free tier is sufficient)
- Supabase project (already configured)

---

## Part 1: Deploying the Admin Panel (`awcms`)

This is the React-based CMS dashboard for tenant administration.

### 1. Create Cloudflare Pages Project

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com)
2. Navigate to **Pages** → **Create a project** → **Connect to Git**
3. Select your repository

### 2. Configure Build Settings

| Setting | Value |
|---------|-------|
| **Project Name** | e.g., `awcms-admin` |
| **Framework preset** | Vite |
| **Build command** | `npm run build` |
| **Build output directory** | `dist` |
| **Root directory** | `awcms` |
| **Node.js version** | 20.x |

### 3. Environment Variables

Add these in **Settings** → **Environment Variables**:

| Variable | Value |
|----------|-------|
| `VITE_SUPABASE_URL` | `https://your-project.supabase.co` |
| `VITE_SUPABASE_ANON_KEY` | `your-anon-key` |
| `NODE_VERSION` | `20` |

### 4. Deploy

Click **Save and Deploy**. This will deploy the Admin Panel.

---

## Part 2: Deploying the Public Portal (`awcms-public`)

This is the Astro-based public frontend for your tenants.

### 1. Create Cloudflare Pages Project

1. Go to **Pages** → **Create a project** → **Connect to Git**
2. Select **the same repository** again

### 2. Configure Build Settings

| Setting | Value |
|---------|-------|
| **Project Name** | e.g., `awcms-public` |
| **Framework preset** | Astro |
| **Build command** | `npm run build` |
| **Build output directory** | `dist` |
| **Root directory** | `awcms-public` |
| **Node.js version** | 20.x |

### 3. Environment Variables

Add these in **Settings** → **Environment Variables**:

| Variable | Value |
|----------|-------|
| `PUBLIC_SUPABASE_URL` | `https://your-project.supabase.co` |
| `PUBLIC_SUPABASE_ANON_KEY` | `your-anon-key` |
| `NODE_VERSION` | `20` |

### 4. Deploy

Click **Save and Deploy**. This will deploy the Public Portal.

---

## Post-Deployment Configuration

### Custom Domains

1. Go to your **Public Portal** project in Cloudflare.
2. Add your custom domain (e.g., `yourdomain.com`).
3. (Optional) Go to your **Admin Panel** project and add a subdomain (e.g., `admin.yourdomain.com`).

### Supabase Auth Settings

Ensure you update your Supabase Auth Redirect URLs to include both of your new Cloudflare Pages URLs:

- `https://awcms-admin.pages.dev`
- `https://awcms-public.pages.dev`
