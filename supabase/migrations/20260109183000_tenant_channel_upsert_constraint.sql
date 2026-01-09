-- Migration: Add unique constraint for tenant_channels upsert support
-- Fixes PostgreSQL 42P10 error when upserting with (tenant_id, channel, is_primary)

-- Add unique constraint to support frontend upsert logic
ALTER TABLE public.tenant_channels 
ADD CONSTRAINT tenant_channels_tenant_channel_primary_unique 
UNIQUE (tenant_id, channel, is_primary);

-- Reload PostgREST schema cache
NOTIFY pgrst, 'reload schema';
