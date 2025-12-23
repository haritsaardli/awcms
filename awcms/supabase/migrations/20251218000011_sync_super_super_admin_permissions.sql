-- Migration: 20251218_sync_super_super_admin_permissions.sql
-- Description: Assigns ALL existing permissions to super_super_admin to ensure it is a true superset.

BEGIN;

  INSERT INTO public.role_permissions (role_id, permission_id)
  SELECT r.id, p.id
  FROM public.roles r
  CROSS JOIN public.permissions p
  WHERE r.name = 'super_super_admin'
  ON CONFLICT (role_id, permission_id) DO NOTHING;

COMMIT;
