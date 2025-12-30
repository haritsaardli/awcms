-- Migration: 20251231000025_fix_roles_rls_for_global_roles
-- Description: Allows authenticated users to SELECT roles with NULL tenant_id (global roles like 'owner', 'super_admin').
-- This fixes the chicken-and-egg problem where a user with a global role cannot read their own role from the DB.

-- Drop existing policy 
DROP POLICY IF EXISTS "roles_select_unified" ON public.roles;

-- Recreate with NULL tenant_id allowance
-- Logic:
-- 1. User can read roles in their tenant (tenant_id = current_tenant_id())
-- 2. User can read GLOBAL roles (tenant_id IS NULL) - needed for owner/super_admin roles
-- 3. Platform Admin can read ALL roles (bypass)
CREATE POLICY "roles_select_unified" ON public.roles FOR SELECT USING (
    tenant_id = public.current_tenant_id() 
    OR tenant_id IS NULL
    OR public.is_platform_admin()
);
