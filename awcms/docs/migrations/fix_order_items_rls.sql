-- Fix RLS for order_items (was missing policies)
-- Allow users to view items if they own the parent order
-- Allow admins to view all

DROP POLICY IF EXISTS "Users view own order items" ON public.order_items;
CREATE POLICY "Users view own order items" ON public.order_items
    FOR SELECT TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM public.orders 
            WHERE id = order_items.order_id 
            AND (
                user_id = auth.uid()
                OR
                (SELECT name FROM public.roles WHERE id = (SELECT role_id FROM public.users WHERE id = auth.uid())) IN ('super_admin', 'admin', 'editor')
            )
        )
    );

-- Allow users to create items only for their own orders (usually handled by backend, but good for safety)
DROP POLICY IF EXISTS "Users create own order items" ON public.order_items;
CREATE POLICY "Users create own order items" ON public.order_items
    FOR INSERT TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.orders
            WHERE id = order_items.order_id
            AND user_id = auth.uid()
        )
    );

-- Grant access
GRANT SELECT, INSERT ON public.order_items TO authenticated;
