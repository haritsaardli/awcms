-- =====================================================
-- Migration: Fix Auth RLS Initialization Plan Warning
-- Date: 2025-12-15
-- Description: Optimize RLS policies using stable subquery pattern
--              to prevent auth.uid() being re-evaluated per row
-- IMPORTANT: Run this in Supabase SQL Editor
-- =====================================================

-- The issue: auth.uid() and current_setting() are being called for each row
-- Solution: Use a stable subquery that evaluates auth.uid() once

-- =====================================================
-- STEP 1: FIX photo_gallery TABLE
-- =====================================================

-- Drop existing policies
DROP POLICY IF EXISTS "photo_gallery_select_policy" ON public.photo_gallery;
DROP POLICY IF EXISTS "photo_gallery_insert_policy" ON public.photo_gallery;
DROP POLICY IF EXISTS "photo_gallery_update_policy" ON public.photo_gallery;
DROP POLICY IF EXISTS "photo_gallery_delete_policy" ON public.photo_gallery;

-- Create optimized policies with stable subquery pattern
CREATE POLICY "photo_gallery_select_policy"
ON public.photo_gallery FOR SELECT
TO authenticated
USING (deleted_at IS NULL);

CREATE POLICY "photo_gallery_insert_policy"
ON public.photo_gallery FOR INSERT
TO authenticated
WITH CHECK (true);

-- Use stable subquery for auth.uid() - evaluated once instead of per-row
CREATE POLICY "photo_gallery_update_policy"
ON public.photo_gallery FOR UPDATE
TO authenticated
USING (
    created_by = (SELECT auth.uid())
    OR EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = (SELECT auth.uid()) AND r.name IN ('super_admin', 'admin')
    )
)
WITH CHECK (true);

CREATE POLICY "photo_gallery_delete_policy"
ON public.photo_gallery FOR DELETE
TO authenticated
USING (
    created_by = (SELECT auth.uid())
    OR EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = (SELECT auth.uid()) AND r.name IN ('super_admin', 'admin')
    )
);

-- =====================================================
-- STEP 2: FIX product_types TABLE
-- =====================================================

DROP POLICY IF EXISTS "product_types_select_policy" ON public.product_types;
DROP POLICY IF EXISTS "product_types_insert_policy" ON public.product_types;
DROP POLICY IF EXISTS "product_types_update_policy" ON public.product_types;
DROP POLICY IF EXISTS "product_types_delete_policy" ON public.product_types;

CREATE POLICY "product_types_select_policy"
ON public.product_types FOR SELECT
TO authenticated
USING (deleted_at IS NULL);

CREATE POLICY "product_types_insert_policy"
ON public.product_types FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "product_types_update_policy"
ON public.product_types FOR UPDATE
TO authenticated
USING (
    created_by = (SELECT auth.uid())
    OR EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = (SELECT auth.uid()) AND r.name IN ('super_admin', 'admin')
    )
)
WITH CHECK (true);

CREATE POLICY "product_types_delete_policy"
ON public.product_types FOR DELETE
TO authenticated
USING (
    created_by = (SELECT auth.uid())
    OR EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = (SELECT auth.uid()) AND r.name IN ('super_admin', 'admin')
    )
);

-- =====================================================
-- STEP 3: FIX products TABLE
-- =====================================================

DROP POLICY IF EXISTS "products_select_policy" ON public.products;
DROP POLICY IF EXISTS "products_insert_policy" ON public.products;
DROP POLICY IF EXISTS "products_update_policy" ON public.products;
DROP POLICY IF EXISTS "products_delete_policy" ON public.products;

CREATE POLICY "products_select_policy"
ON public.products FOR SELECT
TO authenticated
USING (deleted_at IS NULL);

CREATE POLICY "products_insert_policy"
ON public.products FOR INSERT
TO authenticated
WITH CHECK (true);

CREATE POLICY "products_update_policy"
ON public.products FOR UPDATE
TO authenticated
USING (
    created_by = (SELECT auth.uid())
    OR EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = (SELECT auth.uid()) AND r.name IN ('super_admin', 'admin')
    )
)
WITH CHECK (true);

CREATE POLICY "products_delete_policy"
ON public.products FOR DELETE
TO authenticated
USING (
    created_by = (SELECT auth.uid())
    OR EXISTS (
        SELECT 1 FROM public.users u 
        JOIN public.roles r ON u.role_id = r.id 
        WHERE u.id = (SELECT auth.uid()) AND r.name IN ('super_admin', 'admin')
    )
);

-- =====================================================
-- VERIFICATION
-- =====================================================
SELECT 
    tablename, 
    policyname, 
    cmd,
    qual
FROM pg_policies 
WHERE tablename IN ('photo_gallery', 'product_types', 'products')
AND schemaname = 'public'
ORDER BY tablename, cmd;
