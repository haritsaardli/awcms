-- Fix RLS Recursion by implementing SECURITY DEFINER functions
-- These functions bypass RLS when querying key tables to avoid the infinite loop:
-- RLS(users) -> calls function() -> queries users -> triggers RLS(users) -> ...

-- 1. Fix current_tenant_id
CREATE OR REPLACE FUNCTION public.current_tenant_id()
 RETURNS uuid
 LANGUAGE plpgsql
 SECURITY DEFINER -- <--- CRITICAL: Runs as owner, bypassing RLS
 SET search_path TO 'public' 
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
        
        IF _tenant_id IS NOT NULL THEN
            RETURN _tenant_id;
        END IF;
    END IF;

    -- 2. If Anonymous, look for the Header
    BEGIN
        _header_tenant_id := current_setting('request.headers', true)::json ->> 'x-tenant-id';
        
        IF (_header_tenant_id IS NOT NULL AND _header_tenant_id ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$') THEN
            RETURN _header_tenant_id::uuid;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RETURN NULL;
    END;

    RETURN NULL;
END;
$function$;

-- 2. Fix is_super_admin
CREATE OR REPLACE FUNCTION public.is_super_admin()
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = auth.uid() 
        AND r.name IN ('super_admin', 'owner')
    );
END;
$function$;

-- 3. Fix is_platform_admin
CREATE OR REPLACE FUNCTION public.is_platform_admin()
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
DECLARE
    _role_name TEXT;
BEGIN
    SELECT r.name INTO _role_name
    FROM public.users u 
    JOIN public.roles r ON u.role_id = r.id 
    WHERE u.id = auth.uid();

    RETURN _role_name = 'owner';
END;
$function$;

-- 4. Fix is_admin_or_above
CREATE OR REPLACE FUNCTION public.is_admin_or_above()
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = auth.uid() 
        AND r.name IN ('admin', 'super_admin', 'owner', 'super_super_admin')
    );
END;
$function$;
