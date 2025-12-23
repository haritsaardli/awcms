-- Migration: Secure current_tenant_id function with Header support
-- Description: Updates current_tenant_id() to support 'x-tenant-id' header for anonymous access while prioritizing auth logic.

CREATE OR REPLACE FUNCTION public.current_tenant_id()
RETURNS uuid
LANGUAGE plpgsql
STABLE
AS $function$
DECLARE
    _tenant_id uuid;
    _header_tenant_id text;
BEGIN
    -- 1. If user is logged in, TRUST the user's record (Absolute Truth)
    IF (auth.uid() IS NOT NULL) THEN
        SELECT tenant_id INTO _tenant_id
        FROM public.users
        WHERE id = auth.uid();
        -- If we found a tenant ID for the user, return it
        IF _tenant_id IS NOT NULL THEN
            RETURN _tenant_id;
        END IF;
    END IF;

    -- 2. If Anonymous (or user has no tenant assigned?), look for the Header (Contextual Truth)
    -- Supabase exposes headers via 'request.headers' config
    -- Format: {"x-tenant-id": "..."}
    BEGIN
        _header_tenant_id := current_setting('request.headers', true)::json ->> 'x-tenant-id';
        
        -- Validate UUID format to prevent SQL injection or errors
        IF (_header_tenant_id IS NOT NULL AND _header_tenant_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') THEN
            RETURN _header_tenant_id::uuid;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        -- JSON parsing failed or config missing
        RETURN NULL;
    END;

    RETURN NULL;
END;
$function$;
