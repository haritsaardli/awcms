
-- Migration: Seed Pongo Default Data
-- Date: 2026-01-14
-- Description: Seeds the services, teams, partners, and funfacts tables with initial Pongo template content.

-- Services
INSERT INTO public.services (tenant_id, title, description, icon, image, link, "order", status)
SELECT
    t.id as tenant_id,
    d.title,
    d.description,
    d.icon,
    d.image,
    '#' as link,
    row_number() OVER (PARTITION BY t.id ORDER BY d.title) as "order",
    'published' as status
FROM public.tenants t
CROSS JOIN (VALUES
    ('Power & Energy', 'Recently cut out of an illustrated magine and housed indust', 'fi flaticon-solar-energy', '/assets/images/services/img-1.jpg'),
    ('Mechanical Works', 'Recently cut out of an illustrated magine and housed indust', 'fi flaticon-plug', '/assets/images/services/img-2.jpg'),
    ('Petroleum Refinery', 'Recently cut out of an illustrated magine and housed indust', 'fi flaticon-oil-barrel', '/assets/images/services/img-3.jpg'),
    ('Oil and Gas', 'Recently cut out of an illustrated magine and housed indust', 'fi flaticon-oil-1', '/assets/images/services/img-4.jpg'),
    ('Logistics Services', 'Recently cut out of an illustrated magine and housed indust', 'fi flaticon-truck', '/assets/images/services/img-5.jpg'),
    ('General Industry', 'Recently cut out of an illustrated magine and housed indust', 'fi flaticon-factory', '/assets/images/services/img-6.jpg')
) AS d(title, description, icon, image)
WHERE t.domain = 'localhost';

-- Funfacts
INSERT INTO public.funfacts (tenant_id, title, count, icon, "order", status)
SELECT
    t.id as tenant_id,
    d.title,
    d.count,
    d.icon,
    row_number() OVER (PARTITION BY t.id ORDER BY d.title) as "order",
    'published' as status
FROM public.tenants t
CROSS JOIN (VALUES
    ('Projects', '25+', 'fi flaticon-stats'),
    ('Factory', '256+', 'fi flaticon-modern'),
    ('Workers', '2568+', 'fi flaticon-users'),
    ('Award Win', '35+', 'fi flaticon-trophy')
) AS d(title, count, icon)
WHERE t.domain = 'localhost';

-- Partners
INSERT INTO public.partners (tenant_id, name, logo, link, "order", status)
SELECT
    t.id as tenant_id,
    d.name,
    d.logo,
    '#' as link,
    row_number() OVER (PARTITION BY t.id ORDER BY d.name) as "order",
    'published' as status
FROM public.tenants t
CROSS JOIN (VALUES
    ('Partner 1', '/assets/images/partners/img-1.jpg'),
    ('Partner 2', '/assets/images/partners/img-2.jpg'),
    ('Partner 3', '/assets/images/partners/img-3.jpg'),
    ('Partner 4', '/assets/images/partners/img-4.jpg'),
    ('Partner 5', '/assets/images/partners/img-5.jpg')
) AS d(name, logo)
WHERE t.domain = 'localhost';

-- Teams
INSERT INTO public.teams (tenant_id, name, role, image, social_links, "order", status)
SELECT
    t.id as tenant_id,
    d.name,
    d.role,
    d.image,
    '[{"icon": "ti-facebook", "link": "#"}, {"icon": "ti-twitter-alt", "link": "#"}, {"icon": "ti-linkedin", "link": "#"}, {"icon": "ti-pinterest", "link": "#"}]'::jsonb as social_links,
    row_number() OVER (PARTITION BY t.id ORDER BY d.name) as "order",
    'published' as status
FROM public.tenants t
CROSS JOIN (VALUES
    ('Michel Jhone', 'Mechanical Engineer', '/assets/images/team/img-1.jpg'),
    ('Aliza Anne', 'Mechanical Engineer', '/assets/images/team/img-2.jpg'),
    ('Martin Somm', 'Mechanical Engineer', '/assets/images/team/img-3.jpg'),
    ('Lisa Reso', 'Mechanical Engineer', '/assets/images/team/img-4.jpg')
) AS d(name, role, image)
WHERE t.domain = 'localhost';
