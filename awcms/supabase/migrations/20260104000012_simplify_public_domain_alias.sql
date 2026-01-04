-- Migration: 20260104000012_simplify_public_domain_alias.sql
-- Description: Simplify domain alias to reliably match primarypublic.ahliweb.com
-- Uses simple string operations instead of regex for reliability

CREATE OR REPLACE FUNCTION public.get_tenant_id_by_host(lookup_host text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  target_host text;
  subdomain text;
  tenant_name text;
  domain_suffix text;
BEGIN
  -- Extract subdomain (first part before first dot)
  subdomain := split_part(lookup_host, '.', 1);
  domain_suffix := substring(lookup_host from position('.' in lookup_host) + 1);
  
  -- Handle Domain Alias: tenantpublic.domain.tld -> tenant.domain.tld
  -- Check if subdomain ends with 'public'
  IF subdomain LIKE '%public' AND length(subdomain) > 6 THEN
      -- Extract tenant name by removing 'public' suffix
      tenant_name := left(subdomain, length(subdomain) - 6);
      target_host := tenant_name || '.' || domain_suffix;
  ELSE
      target_host := lookup_host;
  END IF;

  -- Debug: Log the resolution
  RAISE LOG 'get_tenant_id_by_host: lookup_host=%, subdomain=%, target_host=%', 
            lookup_host, subdomain, target_host;

  -- Lookup Tenant by host or domain
  RETURN (
    SELECT id 
    FROM tenants 
    WHERE host = target_host 
       OR domain = target_host 
    LIMIT 1
  );
END;
$$;
