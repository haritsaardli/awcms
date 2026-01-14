-- Migration: Comprehensive RLS Optimization
-- Description: Optimizes RLS policies by forcing InitPlan execution (wrapping functions in SELECT)
--              and restricting roles to authenticated where appropriate.

-- 1. Optimize Pongo Tables (Services, Teams, Partners, Funfacts)

-- Services
DROP POLICY IF EXISTS "Tenant Select Services" ON public.services;
CREATE POLICY "Tenant Select Services" ON public.services FOR SELECT TO authenticated USING (tenant_id = (SELECT current_tenant_id()));

DROP POLICY IF EXISTS "Tenant Insert Services" ON public.services;
CREATE POLICY "Tenant Insert Services" ON public.services FOR INSERT TO authenticated WITH CHECK (tenant_id = (SELECT current_tenant_id()));

DROP POLICY IF EXISTS "Tenant Update Services" ON public.services;
CREATE POLICY "Tenant Update Services" ON public.services FOR UPDATE TO authenticated USING (tenant_id = (SELECT current_tenant_id()));

DROP POLICY IF EXISTS "Tenant Delete Services" ON public.services;
CREATE POLICY "Tenant Delete Services" ON public.services FOR DELETE TO authenticated USING (tenant_id = (SELECT current_tenant_id()));

-- Teams
DROP POLICY IF EXISTS "Tenant Select Teams" ON public.teams;
CREATE POLICY "Tenant Select Teams" ON public.teams FOR SELECT TO authenticated USING (tenant_id = (SELECT current_tenant_id()));

DROP POLICY IF EXISTS "Tenant Insert Teams" ON public.teams;
CREATE POLICY "Tenant Insert Teams" ON public.teams FOR INSERT TO authenticated WITH CHECK (tenant_id = (SELECT current_tenant_id()));

DROP POLICY IF EXISTS "Tenant Update Teams" ON public.teams;
CREATE POLICY "Tenant Update Teams" ON public.teams FOR UPDATE TO authenticated USING (tenant_id = (SELECT current_tenant_id()));

DROP POLICY IF EXISTS "Tenant Delete Teams" ON public.teams;
CREATE POLICY "Tenant Delete Teams" ON public.teams FOR DELETE TO authenticated USING (tenant_id = (SELECT current_tenant_id()));

-- Partners
DROP POLICY IF EXISTS "Tenant Select Partners" ON public.partners;
CREATE POLICY "Tenant Select Partners" ON public.partners FOR SELECT TO authenticated USING (tenant_id = (SELECT current_tenant_id()));

DROP POLICY IF EXISTS "Tenant Insert Partners" ON public.partners;
CREATE POLICY "Tenant Insert Partners" ON public.partners FOR INSERT TO authenticated WITH CHECK (tenant_id = (SELECT current_tenant_id()));

DROP POLICY IF EXISTS "Tenant Update Partners" ON public.partners;
CREATE POLICY "Tenant Update Partners" ON public.partners FOR UPDATE TO authenticated USING (tenant_id = (SELECT current_tenant_id()));

DROP POLICY IF EXISTS "Tenant Delete Partners" ON public.partners;
CREATE POLICY "Tenant Delete Partners" ON public.partners FOR DELETE TO authenticated USING (tenant_id = (SELECT current_tenant_id()));

-- Funfacts
DROP POLICY IF EXISTS "Tenant Select Funfacts" ON public.funfacts;
CREATE POLICY "Tenant Select Funfacts" ON public.funfacts FOR SELECT TO authenticated USING (tenant_id = (SELECT current_tenant_id()));

DROP POLICY IF EXISTS "Tenant Insert Funfacts" ON public.funfacts;
CREATE POLICY "Tenant Insert Funfacts" ON public.funfacts FOR INSERT TO authenticated WITH CHECK (tenant_id = (SELECT current_tenant_id()));

DROP POLICY IF EXISTS "Tenant Update Funfacts" ON public.funfacts;
CREATE POLICY "Tenant Update Funfacts" ON public.funfacts FOR UPDATE TO authenticated USING (tenant_id = (SELECT current_tenant_id()));

DROP POLICY IF EXISTS "Tenant Delete Funfacts" ON public.funfacts;
CREATE POLICY "Tenant Delete Funfacts" ON public.funfacts FOR DELETE TO authenticated USING (tenant_id = (SELECT current_tenant_id()));


-- 2. Optimize Existing Tables (Articles, Testimonies, Portfolio)

DO $$
BEGIN
    -- Articles
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'articles') THEN
        DROP POLICY IF EXISTS "articles_select_unified" ON public.articles;
        CREATE POLICY "articles_select_unified" ON public.articles FOR SELECT USING (
            (tenant_id = (SELECT current_tenant_id())) OR (SELECT is_platform_admin())
        );

        DROP POLICY IF EXISTS "articles_insert_unified" ON public.articles;
        CREATE POLICY "articles_insert_unified" ON public.articles FOR INSERT WITH CHECK (
            ((tenant_id = (SELECT current_tenant_id())) AND (SELECT is_admin_or_above())) OR (SELECT is_platform_admin())
        );

        DROP POLICY IF EXISTS "articles_update_unified" ON public.articles;
        CREATE POLICY "articles_update_unified" ON public.articles FOR UPDATE USING (
            ((tenant_id = (SELECT current_tenant_id())) AND (SELECT is_admin_or_above())) OR (SELECT is_platform_admin())
        );

        DROP POLICY IF EXISTS "articles_delete_unified" ON public.articles;
        CREATE POLICY "articles_delete_unified" ON public.articles FOR DELETE USING (
            ((tenant_id = (SELECT current_tenant_id())) AND (SELECT is_admin_or_above())) OR (SELECT is_platform_admin())
        );
    END IF;

    -- Testimonies
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'testimonies') THEN
        DROP POLICY IF EXISTS "testimonies_select_unified" ON public.testimonies;
        CREATE POLICY "testimonies_select_unified" ON public.testimonies FOR SELECT USING (
            (tenant_id = (SELECT current_tenant_id())) OR (SELECT is_platform_admin())
        );

        DROP POLICY IF EXISTS "testimonies_insert_unified" ON public.testimonies;
        CREATE POLICY "testimonies_insert_unified" ON public.testimonies FOR INSERT WITH CHECK (
             ((tenant_id = (SELECT current_tenant_id())) AND (SELECT is_admin_or_above())) OR (SELECT is_platform_admin())
        );

        DROP POLICY IF EXISTS "testimonies_update_unified" ON public.testimonies;
        CREATE POLICY "testimonies_update_unified" ON public.testimonies FOR UPDATE USING (
             ((tenant_id = (SELECT current_tenant_id())) AND (SELECT is_admin_or_above())) OR (SELECT is_platform_admin())
        );

        DROP POLICY IF EXISTS "testimonies_delete_unified" ON public.testimonies;
        CREATE POLICY "testimonies_delete_unified" ON public.testimonies FOR DELETE USING (
             ((tenant_id = (SELECT current_tenant_id())) AND (SELECT is_admin_or_above())) OR (SELECT is_platform_admin())
        );
    END IF;

    -- Portfolio
    IF EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'portfolio') THEN
        DROP POLICY IF EXISTS "portfolio_select_unified" ON public.portfolio;
        CREATE POLICY "portfolio_select_unified" ON public.portfolio FOR SELECT USING (
            (tenant_id = (SELECT current_tenant_id())) OR (SELECT is_platform_admin())
        );

        DROP POLICY IF EXISTS "portfolio_insert_unified" ON public.portfolio;
        CREATE POLICY "portfolio_insert_unified" ON public.portfolio FOR INSERT WITH CHECK (
             ((tenant_id = (SELECT current_tenant_id())) AND (SELECT is_admin_or_above())) OR (SELECT is_platform_admin())
        );

        DROP POLICY IF EXISTS "portfolio_update_unified" ON public.portfolio;
        CREATE POLICY "portfolio_update_unified" ON public.portfolio FOR UPDATE USING (
             ((tenant_id = (SELECT current_tenant_id())) AND (SELECT is_admin_or_above())) OR (SELECT is_platform_admin())
        );

        DROP POLICY IF EXISTS "portfolio_delete_unified" ON public.portfolio;
        CREATE POLICY "portfolio_delete_unified" ON public.portfolio FOR DELETE USING (
             ((tenant_id = (SELECT current_tenant_id())) AND (SELECT is_admin_or_above())) OR (SELECT is_platform_admin())
        );
    END IF;

END $$;
