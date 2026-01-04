-- Migration: 20260104000005_support_public_domain_alias.sql
-- Description: Update get_tenant_id_by_host to support primary-public domain alias.

CREATE OR REPLACE FUNCTION public.get_tenant_id_by_host(lookup_host text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  target_host text;
BEGIN
  -- 1. Handle Domain Aliases
  IF lookup_host = 'primary-public.ahliweb.com' THEN
      target_host := 'primary.ahliweb.com';
  ELSE
      target_host := lookup_host;
  END IF;

  -- 2. Lookup Tenant
  RETURN (
    SELECT id 
    FROM tenants 
    WHERE host = target_host 
       OR domain = target_host 
    LIMIT 1
  );
END;
$$;
