-- Add soft delete columns for extension registry tables

ALTER TABLE public.extension_menu_items
  ADD COLUMN IF NOT EXISTS deleted_at timestamp with time zone;

ALTER TABLE public.extension_routes_registry
  ADD COLUMN IF NOT EXISTS deleted_at timestamp with time zone;

CREATE INDEX IF NOT EXISTS idx_extension_menu_items_deleted_at
  ON public.extension_menu_items (deleted_at);

CREATE INDEX IF NOT EXISTS idx_extension_routes_registry_deleted_at
  ON public.extension_routes_registry (deleted_at);

-- Ensure registry selects ignore soft-deleted routes
DROP POLICY IF EXISTS extension_routes_registry_select ON public.extension_routes_registry;
CREATE POLICY extension_routes_registry_select ON public.extension_routes_registry
  FOR SELECT
  USING (
    deleted_at IS NULL
    AND (
      is_active = true
      OR public.get_my_role() = 'super_admin'
    )
  );
