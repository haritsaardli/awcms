# AWCMS Monorepo

Welcome to the AWCMS development monorepo. This repository contains the source code for both the Admin Panel and the Public Portal.

## 📂 Project Structure

- **`awcms/`**: The Admin Panel and Content Management System. Built with React 18, Vite, and Supabase.
- **`awcms-public/`**: The Public Portal frontend. Built with Astro 5 and React 19 for high performance and SEO.

## 🚀 Quick Start

To get started, you will need to run both the Admin Panel and the Public Portal.

### 1. Admin Panel (`awcms`)

```bash
cd awcms
npm install
cp .env.example .env.local # Configure your Supabase credentials
npm run dev
```

Runs on: `http://localhost:3000`

### 2. Public Portal (`awcms-public`)

```bash
cd awcms-public
npm install
cp .env.example .env # Configure your Supabase credentials
npm run dev
```

Runs on: `http://localhost:4321`

## 📚 Documentation

Detailed documentation is available in the `awcms/docs` directory:

- [**Full Documentation Index**](awcms/docs/INDEX.md)
- [**Deployment Guide**](awcms/docs/CLOUDFLARE_DEPLOYMENT.md)
