-- Create Orders Table
CREATE TABLE IF NOT EXISTS public.orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id),
    total_amount NUMERIC(12, 2) DEFAULT 0,
    status TEXT DEFAULT 'pending',
    shipping_address TEXT,
    tracking_number TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Create Order Items Table
CREATE TABLE IF NOT EXISTS public.order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id),
    quantity INTEGER DEFAULT 1,
    price NUMERIC(12, 2) DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Create Audit Logs Table
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.users(id),
    action TEXT NOT NULL,
    resource TEXT NOT NULL,
    details JSONB DEFAULT '{}'::jsonb,
    ip_address TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Create Settings Table
CREATE TABLE IF NOT EXISTS public.settings (
    key TEXT PRIMARY KEY,
    value TEXT,
    type TEXT DEFAULT 'string',
    description TEXT,
    is_public BOOLEAN DEFAULT false,
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

-- Indexes for Performance
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON public.orders(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX IF NOT EXISTS idx_order_items_product_id ON public.order_items(product_id);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON public.audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON public.audit_logs(action);
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at ON public.audit_logs(created_at DESC);

-- RLS Policies

-- Helper for Role Check (Inlined for simplicity in SQL)
-- (SELECT name FROM public.roles WHERE id = (SELECT role_id FROM public.users WHERE id = auth.uid()))

-- Orders: Users see own, Admins see all
DROP POLICY IF EXISTS "Users view own orders" ON public.orders;
CREATE POLICY "Users view own orders" ON public.orders 
    FOR SELECT TO authenticated 
    USING (
        auth.uid() = user_id 
        OR 
        (SELECT name FROM public.roles WHERE id = (SELECT role_id FROM public.users WHERE id = auth.uid())) IN ('super_admin', 'admin', 'editor')
    );

DROP POLICY IF EXISTS "Users create own orders" ON public.orders;
CREATE POLICY "Users create own orders" ON public.orders 
    FOR INSERT TO authenticated 
    WITH CHECK (auth.uid() = user_id);
    
-- Settings: Public read if is_public, Admin all
DROP POLICY IF EXISTS "Public view public settings" ON public.settings;
CREATE POLICY "Public view public settings" ON public.settings
    FOR SELECT TO anon, authenticated
    USING (
        is_public = true 
        OR 
        (auth.uid() IS NOT NULL AND (SELECT name FROM public.roles WHERE id = (SELECT role_id FROM public.users WHERE id = auth.uid())) = 'super_admin')
    );

DROP POLICY IF EXISTS "Admins manage settings" ON public.settings;
CREATE POLICY "Admins manage settings" ON public.settings
    FOR ALL TO authenticated
    USING ((SELECT name FROM public.roles WHERE id = (SELECT role_id FROM public.users WHERE id = auth.uid())) = 'super_admin');

-- Audit Logs: Admin read only
DROP POLICY IF EXISTS "Admins view audit logs" ON public.audit_logs;
CREATE POLICY "Admins view audit logs" ON public.audit_logs
    FOR SELECT TO authenticated
    USING ((SELECT name FROM public.roles WHERE id = (SELECT role_id FROM public.users WHERE id = auth.uid())) IN ('super_admin', 'admin'));

-- Grant access
GRANT SELECT, INSERT, UPDATE ON public.orders TO authenticated;
GRANT SELECT, INSERT ON public.order_items TO authenticated;
GRANT SELECT ON public.settings TO anon, authenticated;
