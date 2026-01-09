-- Migration: Create SECURITY DEFINER function for public tenant lookup
-- This allows anonymous users to resolve tenant by slug without RLS blocking

CREATE OR REPLACE FUNCTION public.get_tenant_by_slug(lookup_slug text)
RETURNS TABLE(id uuid, slug text)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT t.id, t.slug
  FROM tenants t
  WHERE t.slug = lower(lookup_slug)
  AND t.status = 'active'
  LIMIT 1;
END;
$$;

-- Grant execute to anon role for public access
GRANT EXECUTE ON FUNCTION public.get_tenant_by_slug(text) TO anon;
GRANT EXECUTE ON FUNCTION public.get_tenant_by_slug(text) TO authenticated;

COMMENT ON FUNCTION public.get_tenant_by_slug(text) IS 
'Safely looks up a tenant by slug. Uses SECURITY DEFINER to bypass RLS, 
allowing anonymous users to resolve tenant context for public portal middleware.';
