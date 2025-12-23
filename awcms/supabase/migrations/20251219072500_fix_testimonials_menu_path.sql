-- Migration: Fix Testimonials menu path
-- The menu item has path 'testimonials' but the actual route is 'testimonies'
-- This causes navigation to fail and redirect to public page

-- Fix the path for testimonies menu item
UPDATE admin_menus 
SET path = 'testimonies', 
    updated_at = NOW() 
WHERE key = 'testimonies' AND path = 'testimonials';

-- Also fix if the key was set wrong
UPDATE admin_menus 
SET path = 'testimonies', 
    updated_at = NOW() 
WHERE label = 'Testimonials' AND path = 'testimonials';

-- Verify the fix
SELECT id, key, label, path FROM admin_menus WHERE key LIKE '%testimon%' OR label LIKE '%Testimon%';
