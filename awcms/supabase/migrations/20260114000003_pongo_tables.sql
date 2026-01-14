
-- Migration: Create Pongo Schema Tables
-- Date: 2026-01-14
-- Description: Adds services, teams, partners, and funfacts tables with RLS and audit columns.

-- 1. Services Table
CREATE TABLE IF NOT EXISTS public.services (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    tenant_id UUID NOT NULL REFERENCES public.tenants(id),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id),
    title TEXT NOT NULL,
    description TEXT,
    icon TEXT,
    image TEXT,
    link TEXT,
    "order" INTEGER DEFAULT 0,
    status TEXT DEFAULT 'published' CHECK (status IN ('draft', 'published', 'archived'))
);

-- 2. Teams Table
CREATE TABLE IF NOT EXISTS public.teams (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    tenant_id UUID NOT NULL REFERENCES public.tenants(id),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id),
    name TEXT NOT NULL,
    role TEXT,
    image TEXT,
    social_links JSONB DEFAULT '[]'::jsonb,
    "order" INTEGER DEFAULT 0,
    status TEXT DEFAULT 'published' CHECK (status IN ('draft', 'published', 'archived'))
);

-- 3. Partners Table
CREATE TABLE IF NOT EXISTS public.partners (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    tenant_id UUID NOT NULL REFERENCES public.tenants(id),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id),
    name TEXT NOT NULL,
    logo TEXT,
    link TEXT,
    "order" INTEGER DEFAULT 0,
    status TEXT DEFAULT 'published' CHECK (status IN ('draft', 'published', 'archived'))
);

-- 4. Funfacts Table
CREATE TABLE IF NOT EXISTS public.funfacts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    deleted_at TIMESTAMP WITH TIME ZONE,
    tenant_id UUID NOT NULL REFERENCES public.tenants(id),
    created_by UUID REFERENCES auth.users(id),
    updated_by UUID REFERENCES auth.users(id),
    title TEXT NOT NULL,
    count TEXT,
    icon TEXT,
    "order" INTEGER DEFAULT 0,
    status TEXT DEFAULT 'published' CHECK (status IN ('draft', 'published', 'archived'))
);

-- 5. Enable RLS
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.partners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.funfacts ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies (Standard Tenant Isolation)
-- Services
CREATE POLICY "Tenant Select Services" ON public.services FOR SELECT USING (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));
CREATE POLICY "Tenant Insert Services" ON public.services FOR INSERT WITH CHECK (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));
CREATE POLICY "Tenant Update Services" ON public.services FOR UPDATE USING (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));
CREATE POLICY "Tenant Delete Services" ON public.services FOR DELETE USING (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));

-- Teams
CREATE POLICY "Tenant Select Teams" ON public.teams FOR SELECT USING (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));
CREATE POLICY "Tenant Insert Teams" ON public.teams FOR INSERT WITH CHECK (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));
CREATE POLICY "Tenant Update Teams" ON public.teams FOR UPDATE USING (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));
CREATE POLICY "Tenant Delete Teams" ON public.teams FOR DELETE USING (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));

-- Partners
CREATE POLICY "Tenant Select Partners" ON public.partners FOR SELECT USING (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));
CREATE POLICY "Tenant Insert Partners" ON public.partners FOR INSERT WITH CHECK (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));
CREATE POLICY "Tenant Update Partners" ON public.partners FOR UPDATE USING (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));
CREATE POLICY "Tenant Delete Partners" ON public.partners FOR DELETE USING (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));

-- Funfacts
CREATE POLICY "Tenant Select Funfacts" ON public.funfacts FOR SELECT USING (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));
CREATE POLICY "Tenant Insert Funfacts" ON public.funfacts FOR INSERT WITH CHECK (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));
CREATE POLICY "Tenant Update Funfacts" ON public.funfacts FOR UPDATE USING (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));
CREATE POLICY "Tenant Delete Funfacts" ON public.funfacts FOR DELETE USING (tenant_id = (SELECT current_setting('app.current_tenant_id', true)::uuid));

-- 7. Grant Permissions
GRANT ALL ON TABLE public.services TO authenticated;
GRANT ALL ON TABLE public.teams TO authenticated;
GRANT ALL ON TABLE public.partners TO authenticated;
GRANT ALL ON TABLE public.funfacts TO authenticated;

GRANT ALL ON TABLE public.services TO service_role;
GRANT ALL ON TABLE public.teams TO service_role;
GRANT ALL ON TABLE public.partners TO service_role;
GRANT ALL ON TABLE public.funfacts TO service_role;
