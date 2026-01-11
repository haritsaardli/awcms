-- Migration: Fix audit_logs RLS for login events
-- Date: 2026-01-12
-- Description: Updates INSERT policy to allow authenticated users to log without tenant context

-- Drop existing insert policy
DROP POLICY IF EXISTS audit_logs_insert_unified ON audit_logs;

-- Create new insert policy that allows:
-- 1. Inserts with matching tenant_id (for in-tenant actions)
-- 2. Inserts with NULL tenant_id for login/auth events (authenticated users only)
CREATE POLICY audit_logs_insert_unified ON audit_logs
    FOR INSERT
    WITH CHECK (
        (tenant_id = current_tenant_id()) -- Normal tenant-scoped inserts
        OR 
        (tenant_id IS NULL AND auth.uid() IS NOT NULL) -- Auth events (login) without tenant
    );
