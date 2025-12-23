-- Create STABLE function to optimize role checks
-- This prevents the complex subquery from being re-evaluated for every row
CREATE OR REPLACE FUNCTION public.get_my_role_name()
RETURNS TEXT AS $$
  SELECT r.name
  FROM public.users u
  JOIN public.roles r ON u.role_id = r.id
  WHERE u.id = auth.uid()
  LIMIT 1;
$$ LANGUAGE sql STABLE SECURITY DEFINER;

-- Optimize ORDERS Policies
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

-- Optimize ORDER_ITEMS Policies
-- Replaces complex EXISTS subquery with cleaner logic if possible, 
-- but we still need to check parent order ownership.
-- We optimize the admin check part at least.
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

-- Optimize SETTINGS Policies & Fix Multiple Permissive Policies
-- Consolidate Admin access + Public access into fewer policies where possible?
-- Actually, the warning "Multiple Permissive Policies" is for SELECT. 
-- "Public view public settings" covers everyone. "Admins manage settings" covers admins (SELECT included).
-- Providing a single SELECT policy handles the read path efficiently.

DROP POLICY IF EXISTS "Public view public settings" ON public.settings;
DROP POLICY IF EXISTS "Admins manage settings" ON public.settings;

-- New Consolidated Policy for SELECT
CREATE POLICY "View settings" ON public.settings
    FOR SELECT TO anon, authenticated
    USING (
        is_public = true 
        OR 
        (auth.uid() IS NOT NULL AND public.get_my_role_name() = 'super_admin')
    );

-- New Policy for INSERT/UPDATE/DELETE (Admins only)
CREATE POLICY "Super Admin manage settings" ON public.settings
    FOR ALL TO authenticated
    USING (public.get_my_role_name() = 'super_admin')
    WITH CHECK (public.get_my_role_name() = 'super_admin');

-- Optimize AUDIT_LOGS Policies
DROP POLICY IF EXISTS "Admins view audit logs" ON public.audit_logs;
CREATE POLICY "Admins view audit logs" ON public.audit_logs
    FOR SELECT TO authenticated
    USING (public.get_my_role_name() IN ('super_admin', 'admin'));
