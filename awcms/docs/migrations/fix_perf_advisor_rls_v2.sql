-- Refined Performance Fixes

-- 1. FUNCTIONS
-- Ensure function is optimal
CREATE OR REPLACE FUNCTION public.get_my_role_name()
RETURNS TEXT AS $$
  SELECT r.name
  FROM public.users u
  JOIN public.roles r ON u.role_id = r.id
  WHERE u.id = (select auth.uid()) -- Wrap here too just in case
  LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- 2. ORDERS
DROP POLICY IF EXISTS "Users view own orders" ON public.orders;
CREATE POLICY "Users view own orders" ON public.orders 
    FOR SELECT TO authenticated 
    USING (
        (select auth.uid()) = user_id 
        OR 
        public.get_my_role_name() IN ('super_admin', 'admin', 'editor')
    );

DROP POLICY IF EXISTS "Users create own orders" ON public.orders;
CREATE POLICY "Users create own orders" ON public.orders 
    FOR INSERT TO authenticated 
    WITH CHECK ((select auth.uid()) = user_id);

-- 3. ORDER ITEMS
DROP POLICY IF EXISTS "Users view own order items" ON public.order_items;
CREATE POLICY "Users view own order items" ON public.order_items
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE id = order_items.order_id 
            AND (
                user_id = (select auth.uid())
                OR
                public.get_my_role_name() IN ('super_admin', 'admin', 'editor')
            )
        )
    );

DROP POLICY IF EXISTS "Users create own order items" ON public.order_items;
CREATE POLICY "Users create own order items" ON public.order_items
    FOR INSERT TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE id = order_items.order_id
            AND user_id = (select auth.uid())
        )
    );

-- 4. SETTINGS
-- Fix "Multiple Permissive Policies" by splitting Admin ALL into INSERT/UPDATE/DELETE
-- Fix "Auth RLS Init Plan" by wrapping auth.uid()

DROP POLICY IF EXISTS "Public view public settings" ON public.settings;
DROP POLICY IF EXISTS "Admins manage settings" ON public.settings;
DROP POLICY IF EXISTS "View settings" ON public.settings;
DROP POLICY IF EXISTS "Super Admin manage settings" ON public.settings;

-- Unified SELECT Policy
CREATE POLICY "View settings" ON public.settings
    FOR SELECT TO anon, authenticated
    USING (
        is_public = true 
        OR 
        ((select auth.uid()) IS NOT NULL AND public.get_my_role_name() = 'super_admin')
    );

-- Admin Write Policy (No SELECT)
CREATE POLICY "Super Admin manage settings" ON public.settings
    FOR INSERT TO authenticated
    WITH CHECK (public.get_my_role_name() = 'super_admin');

CREATE POLICY "Super Admin update settings" ON public.settings
    FOR UPDATE TO authenticated
    USING (public.get_my_role_name() = 'super_admin')
    WITH CHECK (public.get_my_role_name() = 'super_admin');

CREATE POLICY "Super Admin delete settings" ON public.settings
    FOR DELETE TO authenticated
    USING (public.get_my_role_name() = 'super_admin');

-- 5. AUDIT LOGS
DROP POLICY IF EXISTS "Admins view audit logs" ON public.audit_logs;
CREATE POLICY "Admins view audit logs" ON public.audit_logs
    FOR SELECT TO authenticated
    USING (public.get_my_role_name() IN ('super_admin', 'admin'));
