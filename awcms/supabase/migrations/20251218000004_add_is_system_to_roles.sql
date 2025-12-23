-- Migration: 20251218_add_is_system_to_roles.sql

BEGIN;

-- 1. Add is_system column if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'roles' AND column_name = 'is_system') THEN
        ALTER TABLE public.roles ADD COLUMN is_system BOOLEAN DEFAULT FALSE;
    END IF;
END $$;

-- 2. Mark existing system roles
UPDATE public.roles SET is_system = TRUE WHERE name IN ('super_admin', 'admin', 'public', 'guest');

COMMIT;
