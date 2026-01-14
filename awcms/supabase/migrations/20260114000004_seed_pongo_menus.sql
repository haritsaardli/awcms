
-- Migration: Seed Pongo Admin Menus
-- Date: 2026-01-14
-- Description: Adds menu items for Services, Team, Partners, and Fun Facts.

INSERT INTO public.admin_menus (key, label, path, icon, permission, group_label, group_order, "order", is_visible)
VALUES
    ('services', 'Services', 'services', 'Wrench', 'tenant.services.read', 'CONTENT', 10, 51, true),
    ('team', 'Team Members', 'team', 'Users', 'tenant.teams.read', 'CONTENT', 10, 52, true),
    ('partners', 'Partners', 'partners', 'Handshake', 'tenant.partners.read', 'CONTENT', 10, 53, true),
    ('funfacts', 'Fun Facts', 'funfacts', 'Trophy', 'tenant.funfacts.read', 'CONTENT', 10, 54, true)
ON CONFLICT (key) DO UPDATE SET
    label = EXCLUDED.label,
    path = EXCLUDED.path,
    icon = EXCLUDED.icon,
    group_label = EXCLUDED.group_label,
    "order" = EXCLUDED.order;
