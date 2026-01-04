-- Migration: 20260104000015_debug_tenant_lookup_v2.sql
-- Description: Debug tenant lookup for primarypublic.ahliweb.com

DO $$
DECLARE
  test_host text := 'primarypublic.ahliweb.com';
  tenant_id uuid;
BEGIN
  -- 1. Call the function
  tenant_id := public.get_tenant_id_by_host(test_host);
  
  -- 2. Log Result
  RAISE WARNING 'Debug Lookup for % -> UUID: %', test_host, tenant_id;
  
  -- 3. Verify if tenant actually exists with that ID
  IF tenant_id IS NOT NULL THEN
      PERFORM 1 FROM tenants WHERE id = tenant_id;
      RAISE WARNING 'Tenant Verified Exists';
  ELSE
      RAISE WARNING 'Tenant NOT FOUND via RPC';
  END IF;

END $$;
