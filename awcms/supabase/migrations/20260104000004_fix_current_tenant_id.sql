-- Migration: 20260104000004_fix_current_tenant_id.sql
-- Description: Update current_tenant_id to support app.current_tenant_id config (set by pre-request hook).

CREATE OR REPLACE FUNCTION public.current_tenant_id()
RETURNS uuid
LANGUAGE plpgsql
STABLE SECURITY DEFINER
SET search_path TO 'public'
AS $$
DECLARE
  config_tenant text;
BEGIN
  -- 1. Try JWT (Auth)
  IF (auth.jwt() -> 'app_metadata' ->> 'tenant_id') IS NOT NULL THEN
    RETURN (auth.jwt() -> 'app_metadata' ->> 'tenant_id')::uuid;
  END IF;

  -- 2. Try User Record (Auth)
  IF auth.uid() IS NOT NULL THEN
     RETURN (SELECT tenant_id FROM public.users WHERE id = auth.uid());
  END IF;

  -- 3. Try Config (Anon / Pre-request hook)
  config_tenant := current_setting('app.current_tenant_id', true);
  IF config_tenant IS NOT NULL AND config_tenant ~ '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$' THEN
    RETURN config_tenant::uuid;
  END IF;

  RETURN NULL;
END;
$$;
