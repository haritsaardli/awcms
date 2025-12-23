-- =====================================================
-- Migration: Fix RBAC RLS Policies for Users, Roles, Permissions
-- Date: 2025-12-15
-- Description: Ensure super_admin has full access to all system tables
--              while maintaining security for other roles
-- IMPORTANT: Run this in Supabase SQL Editor
-- =====================================================

-- =====================================================
-- HELPER: Create a function to check if user is super_admin
-- This function will be cached and used in all policies
-- =====================================================

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = auth.uid() 
        AND r.name = 'super_admin'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION public.is_admin_or_above()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = auth.uid() 
        AND r.name IN ('super_admin', 'admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- =====================================================
-- STEP 1: FIX users TABLE RLS
-- =====================================================

-- Enable RLS if not already
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

-- Drop ALL existing policies on users
DO $$
DECLARE pol RECORD;
BEGIN
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'users' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.users', pol.policyname);
        RAISE NOTICE 'Dropped policy: %', pol.policyname;
    END LOOP;
END $$;

-- SELECT: Authenticated users can view all users (for dropdowns, etc.)
CREATE POLICY "users_select_policy"
ON public.users FOR SELECT
TO authenticated
USING (deleted_at IS NULL);

-- INSERT: Only super_admin and admin can create users
CREATE POLICY "users_insert_policy"
ON public.users FOR INSERT
TO authenticated
WITH CHECK (public.is_admin_or_above());

-- UPDATE: Users can update own profile, OR admin can update anyone
CREATE POLICY "users_update_policy"
ON public.users FOR UPDATE
TO authenticated
USING (
    id = (SELECT auth.uid())
    OR public.is_admin_or_above()
)
WITH CHECK (true);

-- DELETE: Only super_admin can delete users  
CREATE POLICY "users_delete_policy"
ON public.users FOR DELETE
TO authenticated
USING (public.is_super_admin());

-- =====================================================
-- STEP 2: FIX roles TABLE RLS
-- =====================================================

ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE pol RECORD;
BEGIN
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'roles' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.roles', pol.policyname);
    END LOOP;
END $$;

-- SELECT: All authenticated users can view roles
CREATE POLICY "roles_select_policy"
ON public.roles FOR SELECT
TO authenticated
USING (true);

-- INSERT: Only super_admin can create roles
CREATE POLICY "roles_insert_policy"
ON public.roles FOR INSERT
TO authenticated
WITH CHECK (public.is_super_admin());

-- UPDATE: Only super_admin can update roles
CREATE POLICY "roles_update_policy"
ON public.roles FOR UPDATE
TO authenticated
USING (public.is_super_admin())
WITH CHECK (true);

-- DELETE: Only super_admin can delete roles
CREATE POLICY "roles_delete_policy"
ON public.roles FOR DELETE
TO authenticated
USING (public.is_super_admin());

-- =====================================================
-- STEP 3: FIX permissions TABLE RLS
-- =====================================================

ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE pol RECORD;
BEGIN
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'permissions' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.permissions', pol.policyname);
    END LOOP;
END $$;

-- SELECT: All authenticated users can view permissions
CREATE POLICY "permissions_select_policy"
ON public.permissions FOR SELECT
TO authenticated
USING (true);

-- INSERT: Only super_admin can create permissions
CREATE POLICY "permissions_insert_policy"
ON public.permissions FOR INSERT
TO authenticated
WITH CHECK (public.is_super_admin());

-- UPDATE: Only super_admin can update permissions
CREATE POLICY "permissions_update_policy"
ON public.permissions FOR UPDATE
TO authenticated
USING (public.is_super_admin())
WITH CHECK (true);

-- DELETE: Only super_admin can delete permissions
CREATE POLICY "permissions_delete_policy"
ON public.permissions FOR DELETE
TO authenticated
USING (public.is_super_admin());

-- =====================================================
-- STEP 4: FIX role_permissions TABLE RLS
-- =====================================================

ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;

DO $$
DECLARE pol RECORD;
BEGIN
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'role_permissions' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.role_permissions', pol.policyname);
    END LOOP;
END $$;

-- SELECT: All authenticated can view role_permissions
CREATE POLICY "role_permissions_select_policy"
ON public.role_permissions FOR SELECT
TO authenticated
USING (true);

-- INSERT: Only super_admin can assign permissions
CREATE POLICY "role_permissions_insert_policy"
ON public.role_permissions FOR INSERT
TO authenticated
WITH CHECK (public.is_super_admin());

-- UPDATE: Only super_admin can update assignments
CREATE POLICY "role_permissions_update_policy"
ON public.role_permissions FOR UPDATE
TO authenticated
USING (public.is_super_admin())
WITH CHECK (true);

-- DELETE: Only super_admin can remove permission assignments
CREATE POLICY "role_permissions_delete_policy"
ON public.role_permissions FOR DELETE
TO authenticated
USING (public.is_super_admin());

-- =====================================================
-- VERIFICATION
-- =====================================================
SELECT 
    tablename, 
    policyname, 
    cmd,
    permissive
FROM pg_policies 
WHERE tablename IN ('users', 'roles', 'permissions', 'role_permissions')
AND schemaname = 'public'
ORDER BY tablename, cmd;

-- Check helper functions exist
SELECT proname, prosrc 
FROM pg_proc 
WHERE proname IN ('is_super_admin', 'is_admin_or_above');
