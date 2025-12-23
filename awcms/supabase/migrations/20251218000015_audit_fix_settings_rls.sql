-- Migration: Fix Settings and Audit Logs RLS
-- Description: Consolidate and harden RLS policies for 'settings' and 'audit_logs'.

-- 1. Fix 'settings' table RLS
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

-- Drop existing messy policies
DROP POLICY IF EXISTS "View settings" ON public.settings;
DROP POLICY IF EXISTS "settings_select_policy" ON public.settings;
DROP POLICY IF EXISTS "Super Admin manage settings" ON public.settings;
DROP POLICY IF EXISTS "Super Admin update settings" ON public.settings;
DROP POLICY IF EXISTS "Super Admin delete settings" ON public.settings;

-- Create Unified Policies
-- READ: Allow Public (if is_public=true), Tenant Users (own tenant), Platform Admin (all)
CREATE POLICY "settings_read_policy" ON public.settings
FOR SELECT
USING (
  (is_public = true) OR 
  (tenant_id = current_tenant_id()) OR 
  is_platform_admin()
);

-- WRITE (INSERT/UPDATE/DELETE): Tenant Admin (own tenant) or Platform Admin
CREATE POLICY "settings_write_policy" ON public.settings
FOR ALL
USING (
  (tenant_id = current_tenant_id() AND is_admin_or_above()) OR 
  is_platform_admin()
);


-- 2. Fix 'audit_logs' table RLS
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;

-- Drop existing messy policies
DROP POLICY IF EXISTS "Admins view audit logs" ON public.audit_logs;
DROP POLICY IF EXISTS "audit_logs_select_policy" ON public.audit_logs;

-- READ: Tenant Admin (own tenant) or Platform Admin (all)
CREATE POLICY "audit_logs_read_policy" ON public.audit_logs
FOR SELECT
USING (
  (tenant_id = current_tenant_id() AND is_admin_or_above()) OR 
  is_platform_admin()
);

-- WRITE: System (via trigger/functions mostly) or Tenant Admin (if custom logs)
CREATE POLICY "audit_logs_insert_policy" ON public.audit_logs
FOR INSERT
WITH CHECK (
  (tenant_id = current_tenant_id()) OR 
  is_platform_admin()
);
