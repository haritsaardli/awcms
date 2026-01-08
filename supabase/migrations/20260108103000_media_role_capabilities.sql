-- Migration: Media Role Capabilities
-- Restrict INSERT/UPDATE/DELETE to manage roles (owner, super_admin, admin, editor, author)
-- SELECT remains open to all authenticated tenant users

-- ============================================
-- 1. Create helper function for manage role check
-- ============================================
CREATE OR REPLACE FUNCTION public.is_media_manage_role()
RETURNS boolean
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $$
  SELECT COALESCE(
    get_user_role_name(auth.uid()) IN ('owner', 'super_admin', 'admin', 'editor', 'author'),
    FALSE
  ) OR is_platform_admin();
$$;

COMMENT ON FUNCTION public.is_media_manage_role() IS 
'Returns TRUE if the current user has media manage capabilities (owner, super_admin, admin, editor, author)';

-- ============================================
-- 2. Drop existing INSERT/UPDATE/DELETE policies
-- ============================================
DROP POLICY IF EXISTS "files_insert_unified" ON public.files;
DROP POLICY IF EXISTS "files_update_unified" ON public.files;
DROP POLICY IF EXISTS "files_delete_unified" ON public.files;

-- ============================================
-- 3. Recreate policies with role restriction
-- ============================================

-- INSERT: Only manage roles can insert
CREATE POLICY "files_insert_unified" ON public.files
FOR INSERT
WITH CHECK (
  (tenant_id = current_tenant_id() AND is_media_manage_role())
  OR is_platform_admin()
);

-- UPDATE: Only manage roles can update
CREATE POLICY "files_update_unified" ON public.files
FOR UPDATE
USING (
  (tenant_id = current_tenant_id() AND is_media_manage_role())
  OR is_platform_admin()
);

-- DELETE: Only manage roles can delete
CREATE POLICY "files_delete_unified" ON public.files
FOR DELETE
USING (
  (tenant_id = current_tenant_id() AND is_media_manage_role())
  OR is_platform_admin()
);

-- ============================================
-- 4. Note: SELECT policy remains unchanged
-- ============================================
-- files_select_unified already allows:
-- tenant_id = current_tenant_id() AND deleted_at IS NULL
-- OR is_platform_admin()
