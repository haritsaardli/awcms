-- Migration: Tenant Channels Schema
-- Creates channel-aware tenant domain configuration

-- ============================================
-- 1. Create tenant_channels table
-- ============================================
CREATE TABLE IF NOT EXISTS public.tenant_channels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES public.tenants(id) ON DELETE CASCADE,
  channel text NOT NULL,
  domain text NOT NULL,
  base_path text NOT NULL,
  is_primary boolean NOT NULL DEFAULT true,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  
  -- Constraints
  CONSTRAINT tenant_channels_channel_check 
    CHECK (channel IN ('web_admin', 'web_public', 'mobile', 'esp32')),
  CONSTRAINT tenant_channels_domain_unique UNIQUE (domain)
);

-- Index for fast lookups
CREATE INDEX IF NOT EXISTS idx_tenant_channels_domain 
  ON public.tenant_channels(domain) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_tenant_channels_tenant_channel 
  ON public.tenant_channels(tenant_id, channel);

-- ============================================
-- 2. Enable RLS
-- ============================================
ALTER TABLE public.tenant_channels ENABLE ROW LEVEL SECURITY;

-- Read policy: Anyone can read active channels for tenant resolution
CREATE POLICY tenant_channels_select_active ON public.tenant_channels
  FOR SELECT
  USING (is_active = true);

-- Write policies: Only authorized roles can modify
CREATE POLICY tenant_channels_insert ON public.tenant_channels
  FOR INSERT
  WITH CHECK (
    public.is_platform_admin() 
    OR (tenant_id = public.current_tenant_id() AND public.is_media_manage_role())
  );

CREATE POLICY tenant_channels_update ON public.tenant_channels
  FOR UPDATE
  USING (
    public.is_platform_admin() 
    OR (tenant_id = public.current_tenant_id() AND public.is_media_manage_role())
  );

CREATE POLICY tenant_channels_delete ON public.tenant_channels
  FOR DELETE
  USING (public.is_platform_admin());

-- ============================================
-- 3. Seed primary tenant channels
-- ============================================
INSERT INTO public.tenant_channels (tenant_id, channel, domain, base_path, is_primary, is_active)
SELECT 
  t.id,
  v.channel,
  v.domain,
  v.base_path,
  true,
  true
FROM public.tenants t
CROSS JOIN (VALUES
  ('web_admin', 'primary.ahliweb.com', '/cmspanel/'),
  ('web_public', 'primarypublic.ahliweb.com', '/awcms-public/primary/'),
  ('mobile', 'primarymobile.ahliweb.com', '/awcms-mobile/primary/'),
  ('esp32', 'primaryesp32.ahliweb.com', '/awcms-esp32/primary/')
) AS v(channel, domain, base_path)
WHERE t.slug = 'primary'
  AND NOT EXISTS (
    SELECT 1 FROM public.tenant_channels tc 
    WHERE tc.tenant_id = t.id AND tc.channel = v.channel
  );

-- ============================================
-- 4. Update get_tenant_id_by_host to use tenant_channels
-- ============================================
CREATE OR REPLACE FUNCTION public.get_tenant_id_by_host(lookup_host text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public'
AS $function$
DECLARE
  result_tenant_id uuid;
  target_host text;
  subdomain text;
  domain_suffix text;
BEGIN
  -- First, try exact match in tenant_channels (preferred)
  SELECT tenant_id INTO result_tenant_id
  FROM tenant_channels
  WHERE domain = lower(lookup_host) AND is_active = true
  LIMIT 1;

  IF result_tenant_id IS NOT NULL THEN
    RETURN result_tenant_id;
  END IF;

  -- Fallback: Legacy resolution from tenants table
  -- Handle Domain Alias: tenantpublic.domain.tld -> tenant.domain.tld
  subdomain := split_part(lookup_host, '.', 1);
  domain_suffix := substring(lookup_host from position('.' in lookup_host) + 1);
  
  IF subdomain LIKE '%public' AND length(subdomain) > 6 THEN
    target_host := left(subdomain, length(subdomain) - 6) || '.' || domain_suffix;
  ELSE
    target_host := lookup_host;
  END IF;

  -- Lookup in legacy tenants table
  SELECT id INTO result_tenant_id
  FROM tenants 
  WHERE host = target_host OR domain = target_host 
  LIMIT 1;

  -- Final fallback: if known production domain, default to primary
  IF result_tenant_id IS NULL AND lookup_host LIKE '%ahliweb.com' THEN
    SELECT id INTO result_tenant_id FROM tenants WHERE slug = 'primary' LIMIT 1;
  END IF;

  RETURN result_tenant_id;
END;
$function$;

-- ============================================
-- 5. Reload PostgREST schema cache
-- ============================================
NOTIFY pgrst, 'reload schema';

COMMENT ON TABLE public.tenant_channels IS 'Channel-aware tenant domain configuration';
