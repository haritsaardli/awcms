-- =====================================================
-- Migration: Fix Function Search Path Mutable Warning
-- Date: 2025-12-15
-- Description: Set search_path for security functions
-- IMPORTANT: Run this in Supabase SQL Editor
-- =====================================================

-- Use CREATE OR REPLACE (no need to drop - policies depend on these)

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
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE SET search_path = '';

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
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE SET search_path = '';

-- Verify functions have search_path set
SELECT proname, prosecdef, proconfig
FROM pg_proc 
WHERE proname IN ('is_super_admin', 'is_admin_or_above')
AND pronamespace = 'public'::regnamespace;

