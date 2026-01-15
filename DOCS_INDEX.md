# AWCMS Documentation Index

## Purpose

Provide a single entry point for all AWCMS documentation across the monorepo and identify the canonical doc for each topic.

## Prerequisites

- Read and follow `AGENTS.md` (single source of truth for AI rules).
- For architecture overview, read `docs/architecture/overview.md`.

## Canonical Docs Map

### Architecture

| Topic | Canonical Doc | Notes |
| --- | --- | --- |
| System Overview | `docs/architecture/overview.md` | Monorepo and runtime architecture |
| Tech Stack | `docs/architecture/tech-stack.md` | Technologies used |
| Core Standards | `docs/architecture/standards.md` | UI, coding, and quality standards |
| Folder Structure | `docs/architecture/folder-structure.md` | Monorepo layout |
| Database Schema | `docs/architecture/database.md` | Tables and relations |

### Tenancy

| Topic | Canonical Doc | Notes |
| --- | --- | --- |
| Multi-Tenancy | `docs/tenancy/overview.md` | Tenant resolution and isolation |
| Supabase Integration | `docs/tenancy/supabase.md` | Auth and service integration |

### Security

| Topic | Canonical Doc | Notes |
| --- | --- | --- |
| Security Overview | `docs/security/overview.md` | High-level security policy |
| Threat Model | `docs/security/threat-model.md` | OWASP ASVS alignment |
| ABAC System | `docs/security/abac.md` | Permission logic |
| RLS Policies | `docs/security/rls.md` | Database-level enforcement |

### Compliance

| Topic | Canonical Doc | Notes |
| --- | --- | --- |
| Compliance Overview | `docs/compliance/overview.md` | General compliance map |
| Indonesia (UU PDP) | `docs/compliance/indonesia.md` | Local regulations |
| ISO 27001 | `docs/compliance/iso-mapping.md` | Control mapping |

### Developer Guides

| Topic | Canonical Doc | Notes |
| --- | --- | --- |
| Setup Guide | `docs/dev/setup.md` | **Start Here** |
| Admin Panel | `docs/dev/admin.md` | React Admin development |
| Public Portal | `docs/dev/public.md` | Astro development |
| Mobile App | `docs/dev/mobile.md` | Flutter development |
| IoT Firmware | `docs/dev/esp32.md` | ESP32 platform |
| CI/CD | `docs/dev/ci-cd.md` | GitHub Actions |
| Testing | `docs/dev/testing.md` | Vitest and smoke checks |
| Troubleshooting | `docs/dev/troubleshooting.md` | Common issues |

### Deployment

| Topic | Canonical Doc | Notes |
| --- | --- | --- |
| General Deployment | `docs/deploy/overview.md` | Deployment strategies |
| Cloudflare | `docs/deploy/cloudflare.md` | Hosting on Cloudflare |

## Modules

Documentation for specific feature modules is located in `docs/modules/`.
