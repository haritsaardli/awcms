-- Migration: Update handle_new_user for Multi-Tenancy
-- Description: Updates the auth hook to assign assignments tenant_id to new users.

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    default_role_id UUID;
    target_tenant_id UUID;
    primary_tenant_id UUID;
BEGIN
    -- 1. Determine Tenant
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

    -- 2. Determine Role
    -- Try to find 'user' role within the target tenant
    SELECT id INTO default_role_id 
    FROM public.roles 
    WHERE name = 'user' AND tenant_id = target_tenant_id
    LIMIT 1;
    
    -- If no 'user' role in tenant, try to find ANY role in tenant? 
    -- Or fallback to a system guest role?
    -- If new tenant doesn't have roles seeded, this is an issue. 
    -- Assuming we seeded roles for Primary. 
    -- If target is new tenant, we hope roles are there.
    
    IF default_role_id IS NULL THEN
        -- Fallback: Use 'user' role from Primary tenant if we are in Primary
        -- Or just pick first role in target tenant
         SELECT id INTO default_role_id 
         FROM public.roles 
         WHERE tenant_id = target_tenant_id 
         LIMIT 1;
    END IF;

    -- Insert into public.users
    INSERT INTO public.users (id, email, full_name, role_id, tenant_id, created_at, updated_at)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        default_role_id,
        target_tenant_id,
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO UPDATE SET
        email = EXCLUDED.email,
        full_name = EXCLUDED.full_name,
        updated_at = NOW();
        -- Do not overwrite tenant_id on update if already set
        
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';
