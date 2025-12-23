-- Migration: Add missing index on settings table
-- Description: Adds an index on the tenant_id column of the settings table to improve query performance.

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'settings') THEN
        CREATE INDEX IF NOT EXISTS idx_settings_tenant_id ON public.settings(tenant_id);
    END IF;
END $$;
