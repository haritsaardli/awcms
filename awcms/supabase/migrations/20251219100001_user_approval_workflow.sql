-- Migration: User Approval Workflow
-- Date: 2025-12-19
-- Description: Adds multi-stage approval workflow for public user registration
-- Flow: Register -> Admin Approval -> Super Admin Approval -> Email Verify -> Login

-- 1. Add approval workflow columns to users table
ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS approval_status TEXT DEFAULT 'approved' 
  CHECK (approval_status IN ('pending_admin', 'pending_super_admin', 'approved', 'rejected'));

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS admin_approved_at TIMESTAMPTZ;

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS admin_approved_by UUID REFERENCES public.users(id);

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS super_admin_approved_at TIMESTAMPTZ;

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS super_admin_approved_by UUID REFERENCES public.users(id);

ALTER TABLE public.users 
ADD COLUMN IF NOT EXISTS rejection_reason TEXT;

-- 2. Set existing users to 'approved' (grandfathering existing users)
UPDATE public.users 
SET approval_status = 'approved' 
WHERE approval_status IS NULL;

-- 3. Create index for efficient filtering by approval status
CREATE INDEX IF NOT EXISTS idx_users_approval_status ON public.users(approval_status);

-- 4. Create a 'pending' role for newly registered users
DO $$
DECLARE
    default_tenant_id UUID;
BEGIN
    SELECT id INTO default_tenant_id FROM public.tenants WHERE slug = 'primary' LIMIT 1;
    
    IF NOT EXISTS (SELECT 1 FROM public.roles WHERE name = 'pending') THEN
        INSERT INTO public.roles (tenant_id, name, description, is_system)
        VALUES (default_tenant_id, 'pending', 'Pending Registration Approval', TRUE);
    END IF;
END $$;

-- 5. Update handle_new_user function to handle public registrations
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    default_role_id UUID;
    pending_role_id UUID;
    target_tenant_id UUID;
    primary_tenant_id UUID;
    is_public_registration BOOLEAN;
    initial_approval_status TEXT;
BEGIN
    -- 1. Determine if this is a public registration
    -- Public registrations will have 'public_registration' = true in metadata
    BEGIN
        is_public_registration := COALESCE((NEW.raw_user_meta_data->>'public_registration')::BOOLEAN, FALSE);
    EXCEPTION WHEN OTHERS THEN
        is_public_registration := FALSE;
    END;

    -- 2. Determine Tenant
    -- Try to get from metadata (if invited to specific tenant)
    BEGIN
        target_tenant_id := (NEW.raw_user_meta_data->>'tenant_id')::UUID;
    EXCEPTION WHEN OTHERS THEN
        target_tenant_id := NULL;
    END;

    -- If no tenant in metadata, fallback to Primary Tenant
    SELECT id INTO primary_tenant_id FROM public.tenants WHERE slug = 'primary' LIMIT 1;
    
    IF target_tenant_id IS NULL THEN
        target_tenant_id := primary_tenant_id;
    END IF;

    -- 3. Determine Role and Approval Status
    IF is_public_registration THEN
        -- Public registration: assign 'pending' role and set approval_status
        SELECT id INTO pending_role_id 
        FROM public.roles 
        WHERE name = 'pending' 
        LIMIT 1;
        
        default_role_id := pending_role_id;
        initial_approval_status := 'pending_admin';
    ELSE
        -- Admin-created/invited user: assign 'user' role with immediate approval
        SELECT id INTO default_role_id 
        FROM public.roles 
        WHERE name = 'user' AND tenant_id = target_tenant_id
        LIMIT 1;
        
        -- Fallback if no 'user' role in tenant
        IF default_role_id IS NULL THEN
            SELECT id INTO default_role_id 
            FROM public.roles 
            WHERE name = 'subscriber'
            LIMIT 1;
        END IF;
        
        initial_approval_status := 'approved';
    END IF;

    -- 4. Insert into public.users
    INSERT INTO public.users (
        id, 
        email, 
        full_name, 
        role_id, 
        tenant_id, 
        approval_status,
        created_at, 
        updated_at
    )
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        default_role_id,
        target_tenant_id,
        initial_approval_status,
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = COALESCE(EXCLUDED.full_name, public.users.full_name),
        updated_at = NOW();
        
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- 6. Add RLS policies for approval workflow

-- Allow admins to view pending users in their tenant
DROP POLICY IF EXISTS "admins_view_pending_users" ON public.users;
CREATE POLICY "admins_view_pending_users" ON public.users 
FOR SELECT TO authenticated
USING (
    -- Users with pending status can be viewed by admins in same tenant
    (
        approval_status IN ('pending_admin', 'pending_super_admin') 
        AND tenant_id = public.current_tenant_id()
        AND public.is_admin_or_above()
    )
    -- Platform admins can view all
    OR public.is_platform_admin()
);

-- Allow admins to update approval status
DROP POLICY IF EXISTS "admins_approve_users" ON public.users;
CREATE POLICY "admins_approve_users" ON public.users 
FOR UPDATE TO authenticated
USING (
    -- Tenant admins can approve pending_admin users in their tenant
    (
        approval_status = 'pending_admin' 
        AND tenant_id = public.current_tenant_id()
        AND public.is_admin_or_above()
    )
    -- Platform admins can approve any user
    OR public.is_platform_admin()
)
WITH CHECK (
    (tenant_id = public.current_tenant_id() AND public.is_admin_or_above())
    OR public.is_platform_admin()
);

COMMENT ON COLUMN public.users.approval_status IS 
'Multi-stage approval status: pending_admin -> pending_super_admin -> approved/rejected';
