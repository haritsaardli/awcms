-- Add Templates to Admin Menu
INSERT INTO public.admin_menus (key, label, path, icon, permission, group_label, group_order, "order", is_visible)
VALUES (
    'templates',
    'Templates',
    '/cmspanel/templates',
    'LayoutTemplate',
    'manage_themes',
    'DESIGN',
    30, -- Adjust based on where Themes is (usually around here)
    20,
    true
)
ON CONFLICT (key) DO UPDATE SET
    path = EXCLUDED.path,
    icon = EXCLUDED.icon,
    permission = EXCLUDED.permission,
    group_label = EXCLUDED.group_label;
