-- Secure RPC function to resolve tenant by domain or slug
-- Accessible to public (anon) and authenticated users for initial tenant resolution.

CREATE OR REPLACE FUNCTION public.get_tenant_by_domain(lookup_domain TEXT)
RETURNS JSONB AS $$
DECLARE
    result JSONB;
BEGIN
    -- Search by custom domain OR slug (subdomain)
    SELECT to_jsonb(t) INTO result
    FROM public.tenants t
    WHERE (t.domain = lookup_domain OR t.slug = lookup_domain)
      AND t.status = 'active'
    LIMIT 1;

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execution to everyone
GRANT EXECUTE ON FUNCTION public.get_tenant_by_domain(TEXT) TO anon, authenticated, service_role;
