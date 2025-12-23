-- Migration: 20251218_auto_set_tenant_id
-- Description: Create trigger to automatically set tenant_id from current_tenant_id() if not provided.

-- 1. Create the trigger function
CREATE OR REPLACE FUNCTION public.set_tenant_id()
RETURNS TRIGGER AS $$
BEGIN
    -- Only set if not already provided (allows explicit override by platform admins)
    IF NEW.tenant_id IS NULL THEN
        NEW.tenant_id := current_tenant_id();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Apply trigger to all multi-tenant tables
DO $$
DECLARE
    t text;
    tables text[] := ARRAY[
        -- Core
        'articles', 'pages', 'files', 'products', 'orders',
        -- Marketing
        'announcements', 'promotions', 'testimonies', 'portfolio',
        -- Content
        'menus', 'tags', 'categories',
        -- System
        'contact_messages', 'product_types', 
        'themes', 'templates', 
        'extensions', 'extension_routes', 
        'photo_gallery', 'video_gallery'
    ];
BEGIN
    FOREACH t IN ARRAY tables LOOP
        -- Drop if exists to avoid duplication errors during re-runs
        EXECUTE format('DROP TRIGGER IF EXISTS trg_set_tenant_id ON public.%I;', t);
        
        -- Create Trigger
        EXECUTE format(
            'CREATE TRIGGER trg_set_tenant_id
             BEFORE INSERT ON public.%I
             FOR EACH ROW
             EXECUTE FUNCTION public.set_tenant_id();',
            t
        );
    END LOOP;
END $$;
