-- Migration: Complete 7-Action Permission Matrix Seed
-- Date: 2026-01-19
-- Description: Seeds all 7 permission actions (create, read, update, publish, soft_delete, restore, delete_permanent)
--              for all 42+ resources across the system.
-- Author: Antigravity Agent

-- 1. Ensure 'resource' column exists on permissions table
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'permissions' 
        AND column_name = 'resource' 
        AND table_schema = 'public'
    ) THEN
        ALTER TABLE public.permissions ADD COLUMN resource TEXT;
    END IF;
END $$;

-- 2. Define the 7 actions
-- create, read, update, publish, soft_delete, restore, delete_permanent

-- 3. Seed Permissions Function
-- This creates all 7 actions for a given resource
CREATE OR REPLACE FUNCTION seed_resource_permissions(
    p_module TEXT,
    p_resource TEXT,
    p_description_prefix TEXT DEFAULT NULL
) RETURNS void AS $$
DECLARE
    v_actions TEXT[] := ARRAY['create', 'read', 'update', 'publish', 'soft_delete', 'restore', 'delete_permanent'];
    v_action TEXT;
    v_name TEXT;
    v_description TEXT;
BEGIN
    FOREACH v_action IN ARRAY v_actions LOOP
        v_name := p_module || '.' || p_resource || '.' || v_action;
        v_description := COALESCE(p_description_prefix, p_resource) || ' - ' || v_action;
        
        INSERT INTO public.permissions (name, description, module, resource, action)
        VALUES (v_name, v_description, p_module, p_resource, v_action)
        ON CONFLICT (name) DO UPDATE SET
            description = EXCLUDED.description,
            module = EXCLUDED.module,
            resource = EXCLUDED.resource,
            action = EXCLUDED.action;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- 4. Seed Permissions for All Resources

-- ========================
-- CONTENT MODULE (tenant scope)
-- ========================
SELECT seed_resource_permissions('tenant', 'articles', 'Articles');
SELECT seed_resource_permissions('tenant', 'pages', 'Pages');
SELECT seed_resource_permissions('tenant', 'visual_pages', 'Visual Pages');
SELECT seed_resource_permissions('tenant', 'portfolio', 'Portfolio');
SELECT seed_resource_permissions('tenant', 'testimonies', 'Testimonies');
SELECT seed_resource_permissions('tenant', 'announcements', 'Announcements');
SELECT seed_resource_permissions('tenant', 'promotions', 'Promotions');
SELECT seed_resource_permissions('tenant', 'products', 'Products');
SELECT seed_resource_permissions('tenant', 'product_types', 'Product Types');
SELECT seed_resource_permissions('tenant', 'themes', 'Themes');
SELECT seed_resource_permissions('tenant', 'widgets', 'Widgets');
SELECT seed_resource_permissions('tenant', 'templates', 'Templates');
SELECT seed_resource_permissions('tenant', 'contact_messages', 'Contact Messages');
SELECT seed_resource_permissions('tenant', 'services', 'Services');
SELECT seed_resource_permissions('tenant', 'fun_facts', 'Fun Facts');
SELECT seed_resource_permissions('tenant', 'team', 'Team Members');
SELECT seed_resource_permissions('tenant', 'partners', 'Partners');

-- ========================
-- MEDIA MODULE (tenant scope)
-- ========================
SELECT seed_resource_permissions('tenant', 'photo_galleries', 'Photo Galleries');
SELECT seed_resource_permissions('tenant', 'video_galleries', 'Video Galleries');
SELECT seed_resource_permissions('tenant', 'files', 'Files/Media');

-- ========================
-- COMMERCE MODULE (tenant scope)
-- ========================
SELECT seed_resource_permissions('tenant', 'orders', 'Orders');
SELECT seed_resource_permissions('tenant', 'payment_methods', 'Payment Methods');

-- ========================
-- NAVIGATION MODULE (tenant scope)
-- ========================
SELECT seed_resource_permissions('tenant', 'menus', 'Menus');
SELECT seed_resource_permissions('tenant', 'categories', 'Categories');
SELECT seed_resource_permissions('tenant', 'tags', 'Tags');

-- ========================
-- COMMUNICATION MODULE (tenant scope)
-- ========================
SELECT seed_resource_permissions('tenant', 'contacts', 'Contacts');
SELECT seed_resource_permissions('tenant', 'notifications', 'Notifications');

-- ========================
-- SYSTEM MODULE (platform scope)
-- ========================
SELECT seed_resource_permissions('platform', 'users', 'Users');
SELECT seed_resource_permissions('platform', 'roles', 'Roles');
SELECT seed_resource_permissions('platform', 'permissions', 'Permissions');
SELECT seed_resource_permissions('platform', 'policies', 'Policies');
SELECT seed_resource_permissions('platform', 'settings', 'Settings');
SELECT seed_resource_permissions('platform', 'audit_logs', 'Audit Logs');
SELECT seed_resource_permissions('platform', 'extensions', 'Extensions');
SELECT seed_resource_permissions('platform', 'languages', 'Languages');
SELECT seed_resource_permissions('platform', 'seo', 'SEO Settings');
SELECT seed_resource_permissions('platform', 'sso', 'SSO Providers');
SELECT seed_resource_permissions('platform', 'admin_menu', 'Admin Menu');
SELECT seed_resource_permissions('platform', 'sidebar_manager', 'Sidebar Manager');
SELECT seed_resource_permissions('platform', 'theme_layout', 'Theme Layout');
SELECT seed_resource_permissions('platform', 'user_approval', 'User Approval');

-- ========================
-- PLATFORM MODULE (platform scope)
-- ========================
SELECT seed_resource_permissions('platform', 'tenants', 'Tenants');
SELECT seed_resource_permissions('platform', 'dashboard', 'Dashboard');
SELECT seed_resource_permissions('platform', '2fa', 'Two-Factor Auth');

-- ========================
-- PLUGIN MODULES (tenant scope)
-- ========================
SELECT seed_resource_permissions('tenant', 'regions', 'Regions');
SELECT seed_resource_permissions('tenant', 'mailketing', 'Mailketing');
SELECT seed_resource_permissions('tenant', 'backup', 'Backup');

-- ========================
-- EXTENSION MODULES (tenant scope)
-- ========================
SELECT seed_resource_permissions('tenant', 'analytics', 'Analytics');

-- 5. Clean up the helper function
DROP FUNCTION IF EXISTS seed_resource_permissions(TEXT, TEXT, TEXT);

-- 6. Add helpful index for permission lookups
CREATE INDEX IF NOT EXISTS idx_permissions_module_resource_action 
ON public.permissions (module, resource, action);

-- 7. Update role_permissions for default roles
-- Owner & Super Admin get ALL permissions
DO $$
DECLARE
    v_role_id UUID;
    v_perm RECORD;
BEGIN
    -- Owner
    SELECT id INTO v_role_id FROM public.roles WHERE name = 'owner';
    IF v_role_id IS NOT NULL THEN
        FOR v_perm IN SELECT id FROM public.permissions WHERE deleted_at IS NULL LOOP
            INSERT INTO public.role_permissions (role_id, permission_id)
            VALUES (v_role_id, v_perm.id)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END IF;

    -- Super Admin
    SELECT id INTO v_role_id FROM public.roles WHERE name = 'super_admin';
    IF v_role_id IS NOT NULL THEN
        FOR v_perm IN SELECT id FROM public.permissions WHERE deleted_at IS NULL LOOP
            INSERT INTO public.role_permissions (role_id, permission_id)
            VALUES (v_role_id, v_perm.id)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END IF;
END $$;

-- 8. Admin: All tenant.* permissions except restore, delete_permanent, and platform.*
DO $$
DECLARE
    v_role_id UUID;
    v_perm RECORD;
BEGIN
    SELECT id INTO v_role_id FROM public.roles WHERE name = 'admin';
    IF v_role_id IS NOT NULL THEN
        FOR v_perm IN 
            SELECT id FROM public.permissions 
            WHERE deleted_at IS NULL 
            AND module = 'tenant'
            AND action NOT IN ('restore', 'delete_permanent')
        LOOP
            INSERT INTO public.role_permissions (role_id, permission_id)
            VALUES (v_role_id, v_perm.id)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END IF;
END $$;

-- 9. Editor: Create, Read, Update, Publish (no delete actions)
DO $$
DECLARE
    v_role_id UUID;
    v_perm RECORD;
BEGIN
    SELECT id INTO v_role_id FROM public.roles WHERE name = 'editor';
    IF v_role_id IS NOT NULL THEN
        FOR v_perm IN 
            SELECT id FROM public.permissions 
            WHERE deleted_at IS NULL 
            AND module = 'tenant'
            AND action IN ('create', 'read', 'update', 'publish')
        LOOP
            INSERT INTO public.role_permissions (role_id, permission_id)
            VALUES (v_role_id, v_perm.id)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END IF;
END $$;

-- 10. Author: Create, Read, Update (own only - enforced in app code)
DO $$
DECLARE
    v_role_id UUID;
    v_perm RECORD;
BEGIN
    SELECT id INTO v_role_id FROM public.roles WHERE name = 'author';
    IF v_role_id IS NOT NULL THEN
        FOR v_perm IN 
            SELECT id FROM public.permissions 
            WHERE deleted_at IS NULL 
            AND module = 'tenant'
            AND action IN ('create', 'read', 'update')
        LOOP
            INSERT INTO public.role_permissions (role_id, permission_id)
            VALUES (v_role_id, v_perm.id)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END IF;
END $$;

-- 11. Member: Read only for content resources
DO $$
DECLARE
    v_role_id UUID;
    v_perm RECORD;
BEGIN
    SELECT id INTO v_role_id FROM public.roles WHERE name = 'member';
    IF v_role_id IS NOT NULL THEN
        FOR v_perm IN 
            SELECT id FROM public.permissions 
            WHERE deleted_at IS NULL 
            AND module = 'tenant'
            AND action = 'read'
            AND resource IN ('articles', 'pages', 'portfolio', 'testimonies', 'announcements', 
                            'products', 'photo_galleries', 'video_galleries', 'services')
        LOOP
            INSERT INTO public.role_permissions (role_id, permission_id)
            VALUES (v_role_id, v_perm.id)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END IF;
END $$;

-- 12. Subscriber: Read only for public content
DO $$
DECLARE
    v_role_id UUID;
    v_perm RECORD;
BEGIN
    SELECT id INTO v_role_id FROM public.roles WHERE name = 'subscriber';
    IF v_role_id IS NOT NULL THEN
        FOR v_perm IN 
            SELECT id FROM public.permissions 
            WHERE deleted_at IS NULL 
            AND module = 'tenant'
            AND action = 'read'
            AND resource IN ('articles', 'pages', 'portfolio', 'products', 'services')
        LOOP
            INSERT INTO public.role_permissions (role_id, permission_id)
            VALUES (v_role_id, v_perm.id)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END IF;
END $$;

-- Done!
-- This migration creates ~350+ permissions (50 resources × 7 actions)
-- and assigns them to roles based on the standard permission matrix.
