-- =====================================================
-- Migration: Fix Users Table Insert (Simple Solution)
-- Date: 2025-12-15
-- Description: Allow direct insert to users table by adding default UUID
-- =====================================================

-- Option 1: Add default UUID generator for id column
ALTER TABLE public.users 
ALTER COLUMN id SET DEFAULT gen_random_uuid();

-- Option 2: If the above doesn't work, update insert policy to be more permissive for admins
DROP POLICY IF EXISTS "users_insert_policy" ON public.users;

CREATE POLICY "users_insert_policy"
ON public.users FOR INSERT
TO authenticated
WITH CHECK (
    -- Allow insert if user is super_admin or admin
    EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = (SELECT auth.uid()) 
        AND r.name IN ('super_admin', 'admin')
    )
);

-- Verify
SELECT column_name, column_default 
FROM information_schema.columns 
WHERE table_name = 'users' AND column_name = 'id';
