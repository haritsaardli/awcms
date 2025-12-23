-- Migration: Fix Extensions RLS
-- Description: Drop insecure legacy policies and refine tenant isolation for Extensions.

ALTER TABLE public.extensions ENABLE ROW LEVEL SECURITY;

-- 1. Drop Insecure/Legacy Policies
DROP POLICY IF EXISTS "extensions_select" ON public.extensions;
DROP POLICY IF EXISTS "extensions_insert" ON public.extensions;
DROP POLICY IF EXISTS "extensions_update" ON public.extensions;
DROP POLICY IF EXISTS "extensions_delete" ON public.extensions;

-- 2. Drop Phase 6 Policies (to recreate them correctly)
DROP POLICY IF EXISTS "Tenant Read Access" ON public.extensions;
DROP POLICY IF EXISTS "Tenant Write Access" ON public.extensions;

-- 3. Create Refined Policies

-- READ: 
-- Tenants can see: 
--  a) Their own extensions (tenant_id = current_tenant_id())
--  b) Global extensions (tenant_id IS NULL) - e.g. Marketplace items
-- Platform Admin can see ALL.
CREATE POLICY "extensions_read_policy" ON public.extensions
FOR SELECT
USING (
  (tenant_id = current_tenant_id()) OR 
  (tenant_id IS NULL) OR 
  is_platform_admin()
);

-- WRITE (INSERT/UPDATE/DELETE):
-- Tenants can ONLY modify their own extensions.
-- Platform Admin can modify ALL (including Global).
-- NOTE: 'tenant_id IS NULL' is protected because current_tenant_id() will never return NULL for a logged-in tenant user.
CREATE POLICY "extensions_write_policy" ON public.extensions
FOR ALL
USING (
  (tenant_id = current_tenant_id() AND is_admin_or_above()) OR 
  is_platform_admin()
);
