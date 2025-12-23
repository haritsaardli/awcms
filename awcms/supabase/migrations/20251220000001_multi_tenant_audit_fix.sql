-- Migration: Multi-Tenant Audit Fixes
-- Description: Adds missing tenant_id columns and indexes to ensure strict data isolation.

-- Helper block for safe column addition
DO $$
DECLARE
    default_tenant_id UUID;
BEGIN
    SELECT id INTO default_tenant_id FROM public.tenants WHERE slug = 'primary' LIMIT 1;

    -- 1. Contacts
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contacts') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'contacts' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.contacts ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            UPDATE public.contacts SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
            ALTER TABLE public.contacts ALTER COLUMN tenant_id SET NOT NULL;
            CREATE INDEX idx_contacts_tenant_id ON public.contacts(tenant_id);
        END IF;
    END IF;

    -- 2. SEO Metadata
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'seo_metadata') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'seo_metadata' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.seo_metadata ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            UPDATE public.seo_metadata SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
            ALTER TABLE public.seo_metadata ALTER COLUMN tenant_id SET NOT NULL;
            CREATE INDEX idx_seo_metadata_tenant_id ON public.seo_metadata(tenant_id);
        END IF;
    END IF;

    -- 3. Backups
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'backups') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'backups' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.backups ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            UPDATE public.backups SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
            ALTER TABLE public.backups ALTER COLUMN tenant_id SET NOT NULL;
            CREATE INDEX idx_backups_tenant_id ON public.backups(tenant_id);
        END IF;
    END IF;

    -- 4. Backup Logs
     IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'backup_logs') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'backup_logs' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.backup_logs ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            UPDATE public.backup_logs SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
            ALTER TABLE public.backup_logs ALTER COLUMN tenant_id SET NOT NULL;
            CREATE INDEX idx_backup_logs_tenant_id ON public.backup_logs(tenant_id);
        END IF;
    END IF;

    -- 5. Cart Items
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'cart_items') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'cart_items' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.cart_items ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            UPDATE public.cart_items SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
            ALTER TABLE public.cart_items ALTER COLUMN tenant_id SET NOT NULL;
            CREATE INDEX idx_cart_items_tenant_id ON public.cart_items(tenant_id);
        END IF;
    END IF;

    -- 6. Order Items
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'order_items') THEN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'order_items' AND column_name = 'tenant_id') THEN
            ALTER TABLE public.order_items ADD COLUMN tenant_id UUID REFERENCES public.tenants(id);
            UPDATE public.order_items SET tenant_id = default_tenant_id WHERE tenant_id IS NULL;
            ALTER TABLE public.order_items ALTER COLUMN tenant_id SET NOT NULL;
            CREATE INDEX idx_order_items_tenant_id ON public.order_items(tenant_id);
        END IF;
    END IF;

     -- 7. Payments (Index only)
    IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payments') THEN
        -- Check if index exists by name is tricky in PLPGSQL without catalog lookup, but CREATE INDEX IF NOT EXISTS works in PG 9.5+
        CREATE INDEX IF NOT EXISTS idx_payments_tenant_id ON public.payments(tenant_id);
    END IF;

END $$;

-- RLS Policies Update
-- We need to ensure these new tables have RLS policies using current_tenant_id()

-- Generic Policy Generator Macro (Concept) - tailored for each table

-- Contacts
DROP POLICY IF EXISTS "Tenant Isolation Select" ON public.contacts;
CREATE POLICY "Tenant Isolation Select" ON public.contacts FOR SELECT TO authenticated USING (tenant_id = public.current_tenant_id());

DROP POLICY IF EXISTS "Tenant Isolation Insert" ON public.contacts;
CREATE POLICY "Tenant Isolation Insert" ON public.contacts FOR INSERT TO authenticated WITH CHECK (tenant_id = public.current_tenant_id());

DROP POLICY IF EXISTS "Tenant Isolation Update" ON public.contacts;
CREATE POLICY "Tenant Isolation Update" ON public.contacts FOR UPDATE TO authenticated USING (tenant_id = public.current_tenant_id());

DROP POLICY IF EXISTS "Tenant Isolation Delete" ON public.contacts;
CREATE POLICY "Tenant Isolation Delete" ON public.contacts FOR DELETE TO authenticated USING (tenant_id = public.current_tenant_id());

-- Backups
DROP POLICY IF EXISTS "Tenant Isolation Select" ON public.backups;
CREATE POLICY "Tenant Isolation Select" ON public.backups FOR SELECT TO authenticated USING (tenant_id = public.current_tenant_id());

-- Cart/Orders (Commerce)
DROP POLICY IF EXISTS "Tenant Isolation Select" ON public.cart_items;
CREATE POLICY "Tenant Isolation Select" ON public.cart_items FOR SELECT TO authenticated USING (tenant_id = public.current_tenant_id());

DROP POLICY IF EXISTS "Tenant Isolation Select" ON public.order_items;
CREATE POLICY "Tenant Isolation Select" ON public.order_items FOR SELECT TO authenticated USING (tenant_id = public.current_tenant_id());

