-- Migration: Multi-Tenancy Implementation (Fixed V3)
-- Description: Adds tenants table, tenant_id columns, and updates RLS.
-- Fixes: Order of operations to prevent trigger errors.

-- 1. Create Tenants Table
CREATE TABLE IF NOT EXISTS public.tenants (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT NOT NULL UNIQUE,
    domain TEXT UNIQUE,
    status TEXT DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'archived')),
    subscription_tier TEXT DEFAULT 'free',
    config JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

ALTER TABLE public.tenants ENABLE ROW LEVEL SECURITY;

-- 2. Create Default Tenant
INSERT INTO public.tenants (name, slug, subscription_tier)
VALUES ('Primary Tenant', 'primary', 'enterprise')
ON CONFLICT (slug) DO NOTHING;

-- 3. Add tenant_id to Audit Logs FIRST (Nullable)
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'audit_logs') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'audit_logs' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.audit_logs ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            CREATE INDEX idx_audit_logs_tenant_id ON public.audit_logs(tenant_id);
        END IF;
    END IF;
END $$;

-- 4. Update Audit Trigger Function (Now safe because audit_logs has tenant_id)
CREATE OR REPLACE FUNCTION public.log_audit_event()
RETURNS TRIGGER AS $$
DECLARE
    actor_id UUID;
    action_type TEXT;
    payload JSONB;
    captured_tenant_id UUID;
BEGIN
    actor_id := auth.uid();
    
    IF (TG_OP = 'INSERT') THEN
        action_type := 'CREATE';
        payload := to_jsonb(NEW);
    ELSIF (TG_OP = 'UPDATE') THEN
        action_type := 'UPDATE';
        payload := to_jsonb(NEW);
    ELSIF (TG_OP = 'DELETE') THEN
        action_type := 'DELETE';
        payload := to_jsonb(OLD);
    END IF;

    -- Try to capture tenant_id from the changed record
    BEGIN
        captured_tenant_id := (payload->>'tenant_id')::UUID;
    EXCEPTION WHEN OTHERS THEN
        captured_tenant_id := NULL;
    END;

    INSERT INTO public.audit_logs (tenant_id, user_id, action, resource, details, created_at)
    VALUES (
        captured_tenant_id,
        actor_id,
        action_type,
        TG_TABLE_NAME, 
        payload,
        now()
    );

    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- 5. Add tenant_id to Other Tables and Migrate Data
DO $$
DECLARE
    default_tenant_id UUID;
BEGIN
    SELECT id INTO default_tenant_id FROM public.tenants WHERE slug = 'primary' LIMIT 1;

    -- Users
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'users' AND column_name = 'tenant_id') THEN
        ALTER TABLE public.users ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
        UPDATE public.users SET tenant_id = default_tenant_id WHERE tenant_id IS NULL; -- This fires trigger, which now works!
        ALTER TABLE public.users ALTER COLUMN tenant_id SET NOT NULL;
        CREATE INDEX idx_users_tenant_id ON public.users(tenant_id);
    END IF;

    -- Roles
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'roles' AND column_name = 'tenant_id') THEN
        ALTER TABLE public.roles ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
        UPDATE public.roles SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
        ALTER TABLE public.roles ALTER COLUMN tenant_id SET NOT NULL;
        CREATE INDEX idx_roles_tenant_id ON public.roles(tenant_id);
    END IF;

    -- Products
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'products') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'products' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.products ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            UPDATE public.products SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
            ALTER TABLE public.products ALTER COLUMN tenant_id SET NOT NULL;
            CREATE INDEX idx_products_tenant_id ON public.products(tenant_id);
        END IF;
    END IF;

    -- Orders
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'orders') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'orders' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.orders ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            UPDATE public.orders SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
            ALTER TABLE public.orders ALTER COLUMN tenant_id SET NOT NULL;
            CREATE INDEX idx_orders_tenant_id ON public.orders(tenant_id);
        END IF;
    END IF;

    -- Settings
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'settings') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'settings' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.settings ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            UPDATE public.settings SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
            -- Re-key for Composite PK
            ALTER TABLE public.settings DROP CONSTRAINT settings_pkey;
            ALTER TABLE public.settings ADD PRIMARY KEY (tenant_id, key);
            ALTER TABLE public.settings ALTER COLUMN tenant_id SET NOT NULL;
        END IF;
    END IF;

    -- Templates
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'templates') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'templates' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.templates ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            UPDATE public.templates SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
            ALTER TABLE public.templates ALTER COLUMN tenant_id SET NOT NULL;
            CREATE INDEX idx_templates_tenant_id ON public.templates(tenant_id);
        END IF;
    END IF;

    -- Backfill Audit Logs (Now that trigger is updated and handled, we can backfill old nulls)
    UPDATE public.audit_logs SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;

END $$;

-- 6. Helper Functions for RLS
CREATE OR REPLACE FUNCTION public.is_platform_admin()
RETURNS BOOLEAN AS $$
DECLARE
    _role_name TEXT;
BEGIN
    SELECT r.name INTO _role_name
    FROM public.users u 
    JOIN public.roles r ON u.role_id = r.id 
    WHERE u.id = auth.uid();

    RETURN _role_name = 'super_super_admin';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION public.current_tenant_id()
RETURNS UUID AS $$
DECLARE
    _tenant_id UUID;
BEGIN
    SELECT tenant_id INTO _tenant_id
    FROM public.users
    WHERE id = auth.uid();
    RETURN _tenant_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- 7. Create 'super_super_admin' Role
DO $$
DECLARE
    default_tenant_id UUID;
BEGIN
    SELECT id INTO default_tenant_id FROM public.tenants WHERE slug = 'primary' LIMIT 1;
    
    IF NOT EXISTS (SELECT 1 FROM public.roles WHERE name = 'super_super_admin') THEN
        INSERT INTO public.roles (tenant_id, name, description, created_by)
        VALUES (default_tenant_id, 'super_super_admin', 'Platform Administrator', NULL);
    END IF;
END $$;

-- 8. Update RLS Policies

-- Tenants
DROP POLICY IF EXISTS "Platform Admin Manage Tenants" ON public.tenants;
CREATE POLICY "Platform Admin Manage Tenants" ON public.tenants
    FOR ALL TO authenticated
    USING (public.is_platform_admin())
    WITH CHECK (public.is_platform_admin());

DROP POLICY IF EXISTS "Users View Own Tenant" ON public.tenants;
CREATE POLICY "Users View Own Tenant" ON public.tenants
    FOR SELECT TO authenticated
    USING (id = public.current_tenant_id());

-- Users
DROP POLICY IF EXISTS "users_select_policy" ON public.users;
CREATE POLICY "users_select_policy" ON public.users FOR SELECT TO authenticated
USING (
    (tenant_id = public.current_tenant_id() AND deleted_at IS NULL)
    OR public.is_platform_admin()
);

DROP POLICY IF EXISTS "users_insert_policy" ON public.users;
CREATE POLICY "users_insert_policy" ON public.users FOR INSERT TO authenticated
WITH CHECK (
    (tenant_id = public.current_tenant_id() AND public.is_admin_or_above())
    OR public.is_platform_admin()
);

-- Roles
DROP POLICY IF EXISTS "roles_select_policy" ON public.roles;
CREATE POLICY "roles_select_policy" ON public.roles FOR SELECT TO authenticated
USING (
    tenant_id = public.current_tenant_id()
    OR public.is_platform_admin()
);

-- Audit Logs
DROP POLICY IF EXISTS "Admins view audit logs" ON public.audit_logs;
CREATE POLICY "Admins view audit logs" ON public.audit_logs
    FOR SELECT TO authenticated
    USING (
        (tenant_id = public.current_tenant_id() AND (SELECT name FROM public.roles WHERE id = (SELECT role_id FROM public.users WHERE id = auth.uid())) IN ('super_admin', 'admin'))
        Or (tenant_id IS NULL AND public.is_platform_admin())
        OR public.is_platform_admin()
    );

