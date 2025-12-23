-- 1. Fix Function Search Path Mutable (Security Advisor)
-- Set strict search_path for security-critical functions to prevent schema hijacking

ALTER FUNCTION public.log_audit_event SET search_path = public, extensions;
ALTER FUNCTION public.is_platform_admin SET search_path = public, extensions;
ALTER FUNCTION public.current_tenant_id SET search_path = public, extensions;
ALTER FUNCTION public.verify_isolation_debug SET search_path = public, extensions;
ALTER FUNCTION public.get_tenant_by_domain SET search_path = public, extensions;
ALTER FUNCTION public.check_tenant_limit SET search_path = public, extensions;
ALTER FUNCTION public.enforce_user_limit SET search_path = public, extensions;
ALTER FUNCTION public.enforce_storage_limit SET search_path = public, extensions;
ALTER FUNCTION public.set_tenant_id SET search_path = public, extensions;
ALTER FUNCTION public.is_super_admin SET search_path = public, extensions;
ALTER FUNCTION public.is_admin_or_above SET search_path = public, extensions;

-- 2. Consolidate RLS Policies (Performance & Security)

-- A. Video Gallery
-- Remove overly permissive legacy policies that bypass tenant isolation
DROP POLICY IF EXISTS "video_gallery_select_policy" ON video_gallery;
DROP POLICY IF EXISTS "video_gallery_insert_policy" ON video_gallery;
DROP POLICY IF EXISTS "video_gallery_update_policy" ON video_gallery;
DROP POLICY IF EXISTS "video_gallery_delete_policy" ON video_gallery;

-- Ensure Tenant Isolation policies exist (re-asserting them or ensuring no duplicates)
-- The existing "Tenant Read Access" and "Tenant Write Access" usually cover this.
-- we don't need to re-create them if they exist and are correct (based on audit they appeared to be correct but shadowed by the permissive ones).

-- B. Templates
-- Remove redundant policies
DROP POLICY IF EXISTS "Authenticated users can view all templates" ON templates; 
DROP POLICY IF EXISTS "templates_select_policy" ON templates; -- Redundant if "Tenant Read Access" exists

-- Note: "Tenant Read Access" covers both tenant-specific and global (tenant_id IS NULL) templates.
-- "Public can view active templates" is fine for public frontend.

-- 3. Optimize RLS performance (Auth calls)
-- Wrap auth calls in (SELECT ...) to prevent row-by-row re-evaluation where possible.
-- Note: Changing existing policies requires DROP + CREATE.
-- For "Tenant Read Access" on templates:
DROP POLICY IF EXISTS "Tenant Read Access" ON templates;
CREATE POLICY "Tenant Read Access" ON templates
FOR SELECT TO authenticated
USING (
  (tenant_id = (SELECT public.current_tenant_id())) 
  OR (tenant_id IS NULL) 
  OR (SELECT public.is_platform_admin())
);

-- Optimize "Admins users can manage templates" -> "Tenant Write Access"
-- We will rely on the standard "Tenant Write Access" for administrative tasks.
DROP POLICY IF EXISTS "Admins users can manage templates" ON templates;
DROP POLICY IF EXISTS "Tenant Write Access" ON templates;

CREATE POLICY "Tenant Write Access" ON templates
FOR ALL TO authenticated
USING (
  (
    (tenant_id = (SELECT public.current_tenant_id())) 
    AND (SELECT public.is_admin_or_above())
  ) 
  OR (SELECT public.is_platform_admin())
);
