-- Migration: 20251231_migrate_super_super_admin_to_owner
-- Description: Renames 'super_super_admin' to 'owner', handling merge if 'owner' already exists.

DO $$
DECLARE
  _owner_id UUID;
  _old_id UUID;
BEGIN
  -- 1. Check ID of existing roles
  SELECT id INTO _owner_id FROM public.roles WHERE name = 'owner';
  SELECT id INTO _old_id FROM public.roles WHERE name = 'super_super_admin';

  -- 2. Scenario A: Both exist -> Merge Old into Owner
  IF _owner_id IS NOT NULL AND _old_id IS NOT NULL THEN
    -- Move users
    UPDATE public.users SET role_id = _owner_id WHERE role_id = _old_id;
    -- Delete old role
    DELETE FROM public.roles WHERE id = _old_id;
    RAISE NOTICE 'Merged super_super_admin into existing owner role.';

  -- 3. Scenario B: Only Old exists -> Rename
  ELSIF _owner_id IS NULL AND _old_id IS NOT NULL THEN
    UPDATE public.roles
    SET name = 'owner', description = 'Supreme Authority. Has access to everything (Global).'
    WHERE id = _old_id;
    RAISE NOTICE 'Renamed super_super_admin to owner.';
    
  -- 4. Scenario C: Only Owner exists (Already done) -> Do nothing
  ELSIF _owner_id IS NOT NULL AND _old_id IS NULL THEN
    RAISE NOTICE 'Migration already applied (owner exists, super_super_admin does not).';
  END IF;

  -- Ensure cms@ahliweb.com is assigned
  PERFORM 1 FROM public.roles WHERE name = 'owner'; -- just to be safe
  
  -- Re-fetch owner_id in case we renamed it in Scenario B
  SELECT id INTO _owner_id FROM public.roles WHERE name = 'owner';

  IF _owner_id IS NOT NULL THEN
      UPDATE public.users
      SET role_id = _owner_id
      WHERE email = 'cms@ahliweb.com' AND role_id != _owner_id;
  END IF;

END $$;

-- 5. Update Helper Functions (Idempotent CREATE OR REPLACE)

CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN AS $$
DECLARE
  _role_name TEXT;
BEGIN
  _role_name := (auth.jwt() ->> 'role')::TEXT;
  IF _role_name IN ('super_admin', 'owner') THEN
    RETURN TRUE;
  END IF;
  RETURN EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = auth.uid()
    AND r.name IN ('super_admin', 'owner')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION public.is_admin_or_above()
RETURNS BOOLEAN AS $$
DECLARE
  _role_name TEXT;
BEGIN
  _role_name := (auth.jwt() ->> 'role')::TEXT;
  IF _role_name IN ('admin', 'super_admin', 'owner') THEN
    RETURN TRUE;
  END IF;
  RETURN EXISTS (
    SELECT 1 FROM public.users u
    JOIN public.roles r ON u.role_id = r.id
    WHERE u.id = auth.uid()
    AND r.name IN ('admin', 'super_admin', 'owner')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
