-- Migration: 20260104000014_update_get_tenant_by_domain_alias.sql
-- Description: Update get_tenant_by_domain to support public domain aliases
-- This ensures consistency even if the Admin App is hit via a public alias

CREATE OR REPLACE FUNCTION public.get_tenant_by_domain(lookup_domain TEXT)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
    target_domain TEXT;
    subdomain TEXT;
    tenant_name TEXT;
    domain_suffix TEXT;
BEGIN
    -- 1. Handle Domain Alias Logic (Same as get_tenant_id_by_host)
    -- Format: primarypublic.ahliweb.com -> primary.ahliweb.com
    
    subdomain := split_part(lookup_domain, '.', 1);
    domain_suffix := substring(lookup_domain from position('.' in lookup_domain) + 1);

    IF subdomain LIKE '%public' AND length(subdomain) > 6 THEN
        tenant_name := left(subdomain, length(subdomain) - 6);
        target_domain := tenant_name || '.' || domain_suffix;
    ELSE
        target_domain := lookup_domain;
    END IF;

    -- 2. Search by custom domain OR slug (subdomain) OR host
    SELECT to_jsonb(t) INTO result
    FROM public.tenants t
    WHERE (t.domain = target_domain OR t.slug = target_domain OR t.host = target_domain)
      AND t.status = 'active'
    LIMIT 1;

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execution to everyone
GRANT EXECUTE ON FUNCTION public.get_tenant_by_domain(TEXT) TO anon, authenticated, service_role;
