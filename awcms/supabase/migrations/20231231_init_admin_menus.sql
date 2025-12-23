-- Migration: Init Admin Menus
-- Date: 2023-12-31 (Pre-2024 fix)

CREATE TABLE IF NOT EXISTS public.admin_menus (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key TEXT UNIQUE NOT NULL,
    label TEXT NOT NULL,
    path TEXT,
    icon TEXT,
    permission TEXT,
    group_label TEXT DEFAULT 'General',
    group_order INTEGER DEFAULT 100,
    "order" INTEGER DEFAULT 0,
    is_visible BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.admin_menus ENABLE ROW LEVEL SECURITY;

-- Policies
-- Allow all authenticated users to read menu (filtering happens in UI or could be strict here)
CREATE POLICY "admin_menus_read" ON public.admin_menus FOR SELECT
USING (auth.role() = 'authenticated');

-- Only admins can modify
-- Only admins can modify
-- Policy moved to 20251219_fix_policies_rls.sql to resolve circular dependency with users table
CREATE POLICY "admin_menus_write" ON public.admin_menus FOR ALL
USING (auth.uid() IS NOT NULL AND false); -- Temporary lock until 2025 migration unlocks it
