-- Migration: 20251218_fix_rbac_helpers_and_policies.sql
-- Description: Updates RLS helper functions and table policies to ensure super_super_admin has global access.

BEGIN;

-- 1. Update Helper Functions to include 'super_super_admin' inheritance
-- is_super_admin() now returns TRUE for super_admin OR super_super_admin
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = auth.uid() 
        AND r.name IN ('super_admin', 'super_super_admin')
    );
END;
$function$;

-- is_admin_or_above() now returns TRUE for admin, super_admin, OR super_super_admin
CREATE OR REPLACE FUNCTION public.is_admin_or_above()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $function$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = auth.uid() 
        AND r.name IN ('admin', 'super_admin', 'super_super_admin')
    );
END;
$function$;

-- 2. Update Articles Policies
DROP POLICY IF EXISTS "articles_select_policy" ON public.articles;
CREATE POLICY "articles_select_policy" ON public.articles
    FOR SELECT
    TO public
    USING (
        (status = 'published' AND deleted_at IS NULL) OR
        (
            auth.role() = 'authenticated' AND (
                (tenant_id = current_tenant_id()) OR -- Tenant Scope
                is_platform_admin() -- Global Scope
            )
        )
    );

DROP POLICY IF EXISTS "articles_update_policy" ON public.articles;
CREATE POLICY "articles_update_policy" ON public.articles
    FOR UPDATE
    TO public
    USING (
        auth.role() = 'authenticated' AND (
            (tenant_id = current_tenant_id() AND is_admin_or_above()) OR
            (created_by = auth.uid()) OR -- Own content
            is_platform_admin()
        )
    );

DROP POLICY IF EXISTS "articles_delete_policy" ON public.articles;
CREATE POLICY "articles_delete_policy" ON public.articles
    FOR DELETE
    TO public
    USING (
        auth.role() = 'authenticated' AND (
            (tenant_id = current_tenant_id() AND is_super_admin()) OR -- super_admin allows specific role in tenant
            is_platform_admin()
        )
    );

-- 3. Update Files Policies
-- Fix 'files_update_owner' which restricted to exactly 'super_admin' string
DROP POLICY IF EXISTS "files_update_owner" ON public.files;
CREATE POLICY "files_update_owner" ON public.files
    FOR UPDATE
    TO public
    USING (
        (auth.uid() = uploaded_by) OR 
        (
             (tenant_id = current_tenant_id() AND is_super_admin()) OR -- includes super_super_admin via helper, but safer to be specific
             is_platform_admin() -- Ensure platform admin bypass
        )
    );

-- 4. Update Products Policies (Fix explicit role check)
DROP POLICY IF EXISTS "products_delete_policy" ON public.products;
CREATE POLICY "products_delete_policy" ON public.products
    FOR DELETE
    TO authenticated
    USING (
        (created_by = auth.uid()) OR
        (tenant_id = current_tenant_id() AND is_super_admin()) OR -- Uses updated helper
        is_platform_admin()
    );

DROP POLICY IF EXISTS "products_update_policy" ON public.products;
CREATE POLICY "products_update_policy" ON public.products
    FOR UPDATE
    TO authenticated
    USING (
        (created_by = auth.uid()) OR
        (tenant_id = current_tenant_id() AND is_admin_or_above()) OR -- Uses updated helper
        is_platform_admin()
    )
    WITH CHECK (true);

-- 5. Update Pages Policies (Fix hardcoded array)
DROP POLICY IF EXISTS "pages_delete_policy" ON public.pages;
CREATE POLICY "pages_delete_policy" ON public.pages
    FOR DELETE
    TO public
    USING (
        auth.role() = 'authenticated' AND (
            (created_by = auth.uid()) OR 
            (tenant_id = current_tenant_id() AND is_super_admin()) OR
            is_platform_admin()
        )
    );

DROP POLICY IF EXISTS "pages_update_policy" ON public.pages;
CREATE POLICY "pages_update_policy" ON public.pages
    FOR UPDATE
    TO public
    USING (
        auth.role() = 'authenticated' AND (
            (created_by = auth.uid()) OR
            (tenant_id = current_tenant_id() AND is_admin_or_above()) OR
            is_platform_admin()
        )
    );


COMMIT;
