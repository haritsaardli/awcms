-- Migration: Phase 2 Content Isolation
-- Adds tenant_id to pages and files tables.

DO $$
DECLARE
    default_tenant_id UUID := '469ed0e4-8e8c-4ace-8189-71c7c170994a'; -- Primary Tenant ID
BEGIN

    -- 1. PAGES Isolation
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'pages') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'pages' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.pages ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            UPDATE public.pages SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
            ALTER TABLE public.pages ALTER COLUMN tenant_id SET NOT NULL;
            CREATE INDEX idx_pages_tenant_id ON public.pages(tenant_id);
        END IF;
    END IF;

    -- 2. FILES Isolation
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'files') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'files' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.files ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            UPDATE public.files SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
            ALTER TABLE public.files ALTER COLUMN tenant_id SET NOT NULL;
            CREATE INDEX idx_files_tenant_id ON public.files(tenant_id);
        END IF;
    END IF;

    -- 3. FOLDERS Isolation (If exists)
    -- We assume table is named 'folders' or similar. 
    -- Since we didn't find one with strict FK, we verify if a 'folders' table exists by name here dynamically.
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'folders') THEN
         IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'folders' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.folders ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            UPDATE public.folders SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
            ALTER TABLE public.folders ALTER COLUMN tenant_id SET NOT NULL;
            CREATE INDEX idx_folders_tenant_id ON public.folders(tenant_id);
        END IF;
    END IF;

END $$;

-- 4. RLS Policies

-- PAGES
ALTER TABLE public.pages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "pages_select_policy" ON public.pages;
CREATE POLICY "pages_select_policy" ON public.pages FOR SELECT TO authenticated
USING (
    (tenant_id = public.current_tenant_id() AND deleted_at IS NULL)
    OR public.is_platform_admin()
);

DROP POLICY IF EXISTS "pages_modify_policy" ON public.pages;
CREATE POLICY "pages_modify_policy" ON public.pages FOR ALL TO authenticated
USING (
    (tenant_id = public.current_tenant_id())
    OR public.is_platform_admin()
);

-- FILES
ALTER TABLE public.files ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "files_select_policy" ON public.files;
CREATE POLICY "files_select_policy" ON public.files FOR SELECT TO authenticated
USING (
    (tenant_id = public.current_tenant_id() AND deleted_at IS NULL)
    OR public.is_platform_admin()
);

DROP POLICY IF EXISTS "files_modify_policy" ON public.files;
CREATE POLICY "files_modify_policy" ON public.files FOR ALL TO authenticated
USING (
    (tenant_id = public.current_tenant_id())
    OR public.is_platform_admin()
);

-- FOLDERS (Optional)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'folders') THEN
        EXECUTE 'ALTER TABLE public.folders ENABLE ROW LEVEL SECURITY';
        
        EXECUTE 'DROP POLICY IF EXISTS "folders_select_policy" ON public.folders';
        EXECUTE 'CREATE POLICY "folders_select_policy" ON public.folders FOR SELECT TO authenticated USING ((tenant_id = public.current_tenant_id() AND deleted_at IS NULL) OR public.is_platform_admin())';
        
        EXECUTE 'DROP POLICY IF EXISTS "folders_modify_policy" ON public.folders';
        EXECUTE 'CREATE POLICY "folders_modify_policy" ON public.folders FOR ALL TO authenticated USING ((tenant_id = public.current_tenant_id()) OR public.is_platform_admin())';
    END IF;
END $$;
