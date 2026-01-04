-- Migration: 20260104000003_enable_public_tenant_access.sql
-- Description: Enables setting app.current_tenant_id from x-tenant-id header for public access.

-- 1. Create the function to read header and set config
CREATE OR REPLACE FUNCTION public.set_request_tenant()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  header_tenant_id text;
BEGIN
  -- Read x-tenant-id header from request.headers (provided by PostgREST)
  -- The second argument 'true' means return null if missing instead of error
  header_tenant_id := current_setting('request.headers', true)::json->>'x-tenant-id';
  
  -- If present, set the app.current_tenant_id config variable locally for this transaction
  IF header_tenant_id IS NOT NULL THEN
    -- Validate it looks like a uuid to avoid injection/errors
    IF header_tenant_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN
        PERFORM set_config('app.current_tenant_id', header_tenant_id, true);
    END IF;
  END IF;
END;
$$;

-- 2. Configure PostgREST to use this function as pre-request hook
-- We set it on the 'authenticator' role which handles all API requests
ALTER ROLE authenticator SET pgrst.db_pre_request = 'public.set_request_tenant';

-- Also ensure public has verify access (usually public has execute on public functions)
GRANT EXECUTE ON FUNCTION public.set_request_tenant TO anon;
GRANT EXECUTE ON FUNCTION public.set_request_tenant TO authenticated;
GRANT EXECUTE ON FUNCTION public.set_request_tenant TO service_role;
