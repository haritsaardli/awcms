-- Migration: Fix Pongo Performance and Schema
-- Description: Adds indexes for foreign keys (tenant_id) to fix performance warnings.
--              Renames "order" column to "display_order" to match codebase variables and avoid reserved keyword issues.

-- 1. Add indexes for tenant_id (Foreign Key Performance & RLS Optimization)
CREATE INDEX IF NOT EXISTS idx_services_tenant_id ON public.services(tenant_id);
CREATE INDEX IF NOT EXISTS idx_teams_tenant_id ON public.teams(tenant_id);
CREATE INDEX IF NOT EXISTS idx_partners_tenant_id ON public.partners(tenant_id);
CREATE INDEX IF NOT EXISTS idx_funfacts_tenant_id ON public.funfacts(tenant_id);

-- 2. Rename "order" to "display_order" to match codebase (Astro components use display_order)
--    We look for the column existing before trying to rename to make it idempotent-ish
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'services' AND column_name = 'order') THEN
        ALTER TABLE public.services RENAME COLUMN "order" TO display_order;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'teams' AND column_name = 'order') THEN
        ALTER TABLE public.teams RENAME COLUMN "order" TO display_order;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'partners' AND column_name = 'order') THEN
        ALTER TABLE public.partners RENAME COLUMN "order" TO display_order;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'funfacts' AND column_name = 'order') THEN
        ALTER TABLE public.funfacts RENAME COLUMN "order" TO display_order;
    END IF;
END $$;

-- 3. Add indexes for display_order (Sorting Performance)
CREATE INDEX IF NOT EXISTS idx_services_display_order ON public.services(display_order);
CREATE INDEX IF NOT EXISTS idx_teams_display_order ON public.teams(display_order);
CREATE INDEX IF NOT EXISTS idx_partners_display_order ON public.partners(display_order);
CREATE INDEX IF NOT EXISTS idx_funfacts_display_order ON public.funfacts(display_order);
