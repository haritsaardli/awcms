-- Migration: Fix Role Permissions RLS
-- Date: 2026-01-19
-- Description: Updates RLS policies for 'role_permissions' to allow proper management by admins.

-- 1. Ensure RLS is enabled
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;

-- 2. Drop existing policies to start fresh (and avoid conflicts)
DROP POLICY IF EXISTS "Allow read access for all authenticated users" ON public.role_permissions;
DROP POLICY IF EXISTS "Allow full access for owners and super admins" ON public.role_permissions;
DROP POLICY IF EXISTS "Allow write access for admins" ON public.role_permissions;

-- 3. Read Policy: All authenticated users can read permissions (needed for UI to render)
CREATE POLICY "Allow read access for all authenticated users"
ON public.role_permissions FOR SELECT
TO authenticated
USING (true);

-- 4. Write Policy: Allow Owners and Super Admins to manage permissions
-- Uses a subquery to check the user's role
CREATE POLICY "Allow full access for high-level roles"
ON public.role_permissions FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = auth.uid()
    AND r.name IN ('owner', 'super_admin', 'admin')
  )
)
WITH CHECK (
  EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = auth.uid()
    AND r.name IN ('owner', 'super_admin', 'admin')
  )
);
