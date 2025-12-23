-- Fix Templates Menu Path
-- The Sidebar component expects paths relative to /cmspanel/
UPDATE public.admin_menus
SET path = 'templates'
WHERE key = 'templates';
