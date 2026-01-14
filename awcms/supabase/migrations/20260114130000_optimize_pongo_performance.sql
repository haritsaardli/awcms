-- Migration: Optimize Pongo Performance and Fix Warnings
-- Description: Adds indexes for created/updated_by columns and optimizes RLS policies.

-- 1. Add indexes for created_by and updated_by (Fix Unindexed Foreign Keys)
CREATE INDEX IF NOT EXISTS idx_services_created_by ON public.services(created_by);
CREATE INDEX IF NOT EXISTS idx_services_updated_by ON public.services(updated_by);

CREATE INDEX IF NOT EXISTS idx_teams_created_by ON public.teams(created_by);
CREATE INDEX IF NOT EXISTS idx_teams_updated_by ON public.teams(updated_by);

CREATE INDEX IF NOT EXISTS idx_partners_created_by ON public.partners(created_by);
CREATE INDEX IF NOT EXISTS idx_partners_updated_by ON public.partners(updated_by);

CREATE INDEX IF NOT EXISTS idx_funfacts_created_by ON public.funfacts(created_by);
CREATE INDEX IF NOT EXISTS idx_funfacts_updated_by ON public.funfacts(updated_by);

-- 2. Optimize RLS Policies (Fix Multiple Permissive Policies Warning)
-- Restrict "Public Read" policies to 'anon' role only.
-- Restrict "Tenant Select" policies to 'authenticated' role only.
-- This prevents the database from evaluating multiple policies for the same user.

-- Services
ALTER POLICY "Public Read Published Services" ON public.services TO anon;
ALTER POLICY "Tenant Select Services" ON public.services TO authenticated;

-- Teams
ALTER POLICY "Public Read Published Teams" ON public.teams TO anon;
ALTER POLICY "Tenant Select Teams" ON public.teams TO authenticated;

-- Partners
ALTER POLICY "Public Read Published Partners" ON public.partners TO anon;
ALTER POLICY "Tenant Select Partners" ON public.partners TO authenticated;

-- Funfacts
ALTER POLICY "Public Read Published Funfacts" ON public.funfacts TO anon;
ALTER POLICY "Tenant Select Funfacts" ON public.funfacts TO authenticated;
