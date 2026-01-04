-- Migration: 20260104000002_fix_tenant_lookup_rpc.sql
-- Description: Updates get_tenant_id_by_host to check both host and domain columns.

CREATE OR REPLACE FUNCTION public.get_tenant_id_by_host(lookup_host text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
BEGIN
  -- Check host column first, then domain
  RETURN (
    SELECT id 
    FROM tenants 
    WHERE host = lookup_host 
       OR domain = lookup_host 
    LIMIT 1
  );
END;
$function$;
