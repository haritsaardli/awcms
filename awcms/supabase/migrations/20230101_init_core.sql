-- Migration: Init Core Schema (Restored)
-- Date: 2023-01-01
-- Description: Creates roles, permissions, and users tables which are dependencies for all other migrations.

-- 1. Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Utility Functions
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 3. Permissions Table
CREATE TABLE IF NOT EXISTS public.permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    module TEXT,
    action TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. Roles Table
CREATE TABLE IF NOT EXISTS public.roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT UNIQUE NOT NULL,
    description TEXT,
    created_by UUID, -- Self-reference possible later, but nullable
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 5. Role Permissions Junction
CREATE TABLE IF NOT EXISTS public.role_permissions (
    role_id UUID REFERENCES public.roles(id) ON DELETE CASCADE,
    permission_id UUID REFERENCES public.permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

-- 6. Users Table
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE, -- Mirrors Auth ID
    email TEXT,
    full_name TEXT,
    avatar_url TEXT,
    role_id UUID REFERENCES public.roles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. Trigger to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
DECLARE
  default_role_id UUID;
BEGIN
  -- Default to 'subscriber' if exists, else null (admin assigns later)
  SELECT id INTO default_role_id FROM public.roles WHERE name = 'subscriber';

  INSERT INTO public.users (id, email, full_name, role_id)
  VALUES (new.id, new.email, new.raw_user_meta_data->>'full_name', default_role_id)
  ON CONFLICT (id) DO NOTHING;
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger logic (only create if doesn't exist to avoid dupes on re-run)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- 8. Seed Initial Roles
INSERT INTO public.roles (name, description) VALUES
('super_admin', 'System Owner'),
('admin', 'Administrator'),
('editor', 'Content Editor'),
('author', 'Content Author'),
('subscriber', 'Read Only User')
ON CONFLICT (name) DO NOTHING;

-- 9. Init RLS (Basic)
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.role_permissions ENABLE ROW LEVEL SECURITY;
