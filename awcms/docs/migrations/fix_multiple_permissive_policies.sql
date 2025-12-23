-- =====================================================
-- Migration: Fix Multiple Permissive Policies
-- Date: 2025-12-15
-- Description: Consolidate RLS policies to fix performance warnings
-- IMPORTANT: Run this in Supabase SQL Editor
-- =====================================================

-- =====================================================
-- STEP 1: FIX photo_gallery TABLE
-- =====================================================

-- Drop ALL existing policies on photo_gallery
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'photo_gallery' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.photo_gallery', pol.policyname);
        RAISE NOTICE 'Dropped policy: %', pol.policyname;
    END LOOP;
END $$;

-- Create consolidated policies for photo_gallery
-- SELECT: Anyone authenticated can view non-deleted records
CREATE POLICY "photo_gallery_select_policy"
ON public.photo_gallery FOR SELECT
TO authenticated
USING (deleted_at IS NULL);

-- INSERT: Authenticated users can insert
CREATE POLICY "photo_gallery_insert_policy"
ON public.photo_gallery FOR INSERT
TO authenticated
WITH CHECK (true);

-- UPDATE: Users can update their own OR super_admin can update all
CREATE POLICY "photo_gallery_update_policy"
ON public.photo_gallery FOR UPDATE
TO authenticated
USING (
    created_by = auth.uid() 
    OR EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = auth.uid() AND r.name IN ('super_admin', 'admin')
    )
)
WITH CHECK (true);

-- DELETE: Users can delete their own OR super_admin can delete all
CREATE POLICY "photo_gallery_delete_policy"
ON public.photo_gallery FOR DELETE
TO authenticated
USING (
    created_by = auth.uid() 
    OR EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = auth.uid() AND r.name IN ('super_admin', 'admin')
    )
);

-- =====================================================
-- STEP 2: FIX product_types TABLE
-- =====================================================

-- Drop ALL existing policies on product_types
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'product_types' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.product_types', pol.policyname);
        RAISE NOTICE 'Dropped policy: %', pol.policyname;
    END LOOP;
END $$;

-- Create consolidated policies for product_types
-- SELECT: Anyone authenticated can view non-deleted records
CREATE POLICY "product_types_select_policy"
ON public.product_types FOR SELECT
TO authenticated
USING (deleted_at IS NULL);

-- INSERT: Authenticated users can insert
CREATE POLICY "product_types_insert_policy"
ON public.product_types FOR INSERT
TO authenticated
WITH CHECK (true);

-- UPDATE: Users can update their own OR admin can update all
CREATE POLICY "product_types_update_policy"
ON public.product_types FOR UPDATE
TO authenticated
USING (
    created_by = auth.uid() 
    OR EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = auth.uid() AND r.name IN ('super_admin', 'admin')
    )
)
WITH CHECK (true);

-- DELETE: Users can delete their own OR admin can delete all
CREATE POLICY "product_types_delete_policy"
ON public.product_types FOR DELETE
TO authenticated
USING (
    created_by = auth.uid() 
    OR EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = auth.uid() AND r.name IN ('super_admin', 'admin')
    )
);

-- =====================================================
-- STEP 3: FIX products TABLE
-- =====================================================

-- Drop ALL existing policies on products
DO $$
DECLARE
    pol RECORD;
BEGIN
    FOR pol IN SELECT policyname FROM pg_policies WHERE tablename = 'products' AND schemaname = 'public'
    LOOP
        EXECUTE format('DROP POLICY IF EXISTS %I ON public.products', pol.policyname);
        RAISE NOTICE 'Dropped policy: %', pol.policyname;
    END LOOP;
END $$;

-- Create consolidated policies for products
-- SELECT: Anyone authenticated can view non-deleted records
CREATE POLICY "products_select_policy"
ON public.products FOR SELECT
TO authenticated
USING (deleted_at IS NULL);

-- INSERT: Authenticated users can insert
CREATE POLICY "products_insert_policy"
ON public.products FOR INSERT
TO authenticated
WITH CHECK (true);

-- UPDATE: Users can update their own OR admin can update all
CREATE POLICY "products_update_policy"
ON public.products FOR UPDATE
TO authenticated
USING (
    created_by = auth.uid() 
    OR EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = auth.uid() AND r.name IN ('super_admin', 'admin')
    )
)
WITH CHECK (true);

-- DELETE: Users can delete their own OR admin can delete all
CREATE POLICY "products_delete_policy"
ON public.products FOR DELETE
TO authenticated
USING (
    created_by = auth.uid() 
    OR EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = auth.uid() AND r.name IN ('super_admin', 'admin')
    )
);

-- =====================================================
-- VERIFICATION: Check policies after migration
-- =====================================================
SELECT 
    schemaname,
    tablename, 
    policyname, 
    permissive,
    roles,
    cmd
FROM pg_policies 
WHERE tablename IN ('photo_gallery', 'product_types', 'products')
AND schemaname = 'public'
ORDER BY tablename, cmd;
