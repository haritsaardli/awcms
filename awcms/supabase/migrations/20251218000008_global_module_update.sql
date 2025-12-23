-- Migration: 20251218_global_module_update
-- Description: Add tenant_id and RLS policies to all remaining modules for multi-tenancy.

-- List of tables to update:
-- announcements, promotions, testimonies, portfolio
-- menus, tags, categories
-- contact_messages, product_types
-- themes, templates
-- extensions, extension_routes
-- photo_gallery, video_gallery

DO $$
DECLARE
    t text;
    tables text[] := ARRAY[
        'announcements', 'promotions', 'testimonies', 'portfolio',
        'menus', 'tags', 'categories',
        'contact_messages', 'product_types', 
        'themes', 'templates', 
        'extensions', 'extension_routes', 
        'photo_gallery', 'video_gallery'
    ];
BEGIN
    FOREACH t IN ARRAY tables LOOP
        -- 1. Add tenant_id column if it doesn't exist
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = t AND column_name = 'tenant_id'
        ) THEN
            EXECUTE format('ALTER TABLE public.%I ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);', t);
            EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_tenant_id ON public.%I(tenant_id);', t, t);
        END IF;

        -- 2. Enable RLS
        EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY;', t);

        -- 3. Drop existing policies to avoid conflicts (clean slate for these tables)
        -- We use a safe drop pattern that iterates over existing policies if needed, 
        -- but for simplicity in this block we'll just try to drop known standard ones or ignore errors if complex.
        -- Better approach: Create new policies with unique names.

        -- POLICY: Read Access
        -- Allow access if:
        -- a) Row belongs to current tenant
        -- b) User is platform admin (super_super_admin)
        -- c) Table is 'themes' or 'templates' and tenant_id is NULL (System default themes)
        
        EXECUTE format('DROP POLICY IF EXISTS "Tenant Read Access" ON public.%I;', t);
        IF t IN ('themes', 'templates') THEN
             EXECUTE format(
                'CREATE POLICY "Tenant Read Access" ON public.%I FOR SELECT USING ( (tenant_id = current_tenant_id()) OR (tenant_id IS NULL) OR (is_platform_admin()) );', 
                t
            );
        ELSE
            EXECUTE format(
                'CREATE POLICY "Tenant Read Access" ON public.%I FOR SELECT USING ( (tenant_id = current_tenant_id()) OR (is_platform_admin()) );', 
                t
            );
        END IF;

        -- POLICY: Write Access (Insert/Update/Delete)
        -- Allow if:
        -- a) Row belongs to current tenant AND user is admin+
        -- b) User is platform admin
        
        EXECUTE format('DROP POLICY IF EXISTS "Tenant Write Access" ON public.%I;', t);
        EXECUTE format(
            'CREATE POLICY "Tenant Write Access" ON public.%I FOR ALL USING ( (tenant_id = current_tenant_id() AND is_admin_or_above()) OR (is_platform_admin()) );', 
            t
        );

    END LOOP;
END $$;
