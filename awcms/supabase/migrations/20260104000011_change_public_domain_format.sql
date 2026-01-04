-- Migration: 20260104000011_change_public_domain_format.sql
-- Description: Change domain alias format from primary-public to primarypublic (no hyphen)
-- Supported: primarypublic.ahliweb.com -> primary.ahliweb.com

CREATE OR REPLACE FUNCTION public.get_tenant_id_by_host(lookup_host text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  target_host text;
  tenant_name text;
  domain_suffix text;
BEGIN
  -- Handle Domain Alias: tenantpublic.domain.tld -> tenant.domain.tld
  -- Example: primarypublic.ahliweb.com -> primary.ahliweb.com
  IF lookup_host ~ '^[a-z]+public\.[a-z]+\.[a-z]+$' THEN
      -- Extract tenant name (everything before 'public' in the first subdomain)
      tenant_name := regexp_replace(split_part(lookup_host, '.', 1), 'public$', '');
      domain_suffix := split_part(lookup_host, '.', 2) || '.' || split_part(lookup_host, '.', 3);
      target_host := tenant_name || '.' || domain_suffix;
  ELSE
      target_host := lookup_host;
  END IF;

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

-- Update primary tenant to ensure proper configuration
UPDATE tenants 
SET host = 'primary.ahliweb.com',
    domain = COALESCE(domain, 'primary.ahliweb.com')
WHERE host = 'primary.ahliweb.com' OR name ILIKE '%primary%';
