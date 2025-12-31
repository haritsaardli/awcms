-- Migration: Mailketing Plugin Setup
-- Run: npx supabase db push

-- Register Mailketing plugin in extensions table
INSERT INTO public.extensions (name, slug, version, description, extension_type, is_active, config, manifest)
VALUES (
    'Mailketing Email',
    'mailketing',
    '1.0.0',
    'Email sending and subscriber management via Mailketing API',
    'core',
    true,
    '{}',
    '{
        "name": "Mailketing Email",
        "slug": "mailketing",
        "version": "1.0.0",
        "type": "core",
        "description": "Email sending and subscriber management via Mailketing API",
        "author": "AhliWeb",
        "permissions": ["tenant.email.send", "tenant.email.configure", "tenant.email.view_logs"]
    }'::jsonb
)
ON CONFLICT (slug) DO UPDATE SET
    is_active = EXCLUDED.is_active,
    version = EXCLUDED.version,
    manifest = EXCLUDED.manifest;

-- Insert email permissions 
INSERT INTO public.permissions (name, description, resource, action, module) VALUES
    ('tenant.email.send', 'Send emails via email service', 'email', 'send', 'email'),
    ('tenant.email.configure', 'Configure email settings', 'email', 'configure', 'email'),
    ('tenant.email.view_logs', 'View email sending logs', 'email', 'read', 'email')
ON CONFLICT (name) DO NOTHING;

-- Grant permissions to admin roles
DO $$
DECLARE
    admin_role_id UUID;
    super_admin_role_id UUID;
    owner_role_id UUID;
    perm_send UUID;
    perm_configure UUID;
    perm_logs UUID;
BEGIN
    -- Get role IDs
    SELECT id INTO admin_role_id FROM public.roles WHERE name = 'admin' LIMIT 1;
    SELECT id INTO super_admin_role_id FROM public.roles WHERE name = 'super_admin' LIMIT 1;
    SELECT id INTO owner_role_id FROM public.roles WHERE name = 'owner' LIMIT 1;
    
    -- Get permission IDs
    SELECT id INTO perm_send FROM public.permissions WHERE name = 'tenant.email.send';
    SELECT id INTO perm_configure FROM public.permissions WHERE name = 'tenant.email.configure';
    SELECT id INTO perm_logs FROM public.permissions WHERE name = 'tenant.email.view_logs';
    
    -- Grant to admin
    IF admin_role_id IS NOT NULL AND perm_send IS NOT NULL THEN
        INSERT INTO public.role_permissions (role_id, permission_id) VALUES
            (admin_role_id, perm_send),
            (admin_role_id, perm_configure),
            (admin_role_id, perm_logs)
        ON CONFLICT DO NOTHING;
    END IF;
    
    -- Grant to super_admin
    IF super_admin_role_id IS NOT NULL AND perm_send IS NOT NULL THEN
        INSERT INTO public.role_permissions (role_id, permission_id) VALUES
            (super_admin_role_id, perm_send),
            (super_admin_role_id, perm_configure),
            (super_admin_role_id, perm_logs)
        ON CONFLICT DO NOTHING;
    END IF;
    
    -- Grant to owner
    IF owner_role_id IS NOT NULL AND perm_send IS NOT NULL THEN
        INSERT INTO public.role_permissions (role_id, permission_id) VALUES
            (owner_role_id, perm_send),
            (owner_role_id, perm_configure),
            (owner_role_id, perm_logs)
        ON CONFLICT DO NOTHING;
    END IF;
END $$;

-- Add admin menu item for Email Settings (correct schema: key, label, path, icon, group_label, order)
INSERT INTO public.admin_menus (key, label, path, icon, group_label, "order")
VALUES ('email-settings', 'Email Settings', 'email-settings', 'Mail', 'CONFIGURATION', 75)
ON CONFLICT (key) DO NOTHING;

COMMENT ON TABLE public.email_logs IS 'Logs for email events from Mailketing webhooks and API';
