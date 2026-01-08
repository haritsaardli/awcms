-- Migration: Photo Gallery Schema Fix
-- Adds missing workflow columns and enforces tenant_id NOT NULL

-- ============================================
-- 1. Add missing workflow timestamp columns
-- ============================================
ALTER TABLE public.photo_gallery 
  ADD COLUMN IF NOT EXISTS published_at timestamptz;

ALTER TABLE public.photo_gallery 
  ADD COLUMN IF NOT EXISTS reviewed_at timestamptz;

ALTER TABLE public.photo_gallery 
  ADD COLUMN IF NOT EXISTS approved_at timestamptz;

-- ============================================
-- 2. Fix tenant_id constraint
-- ============================================
-- First backfill any NULL tenant_id with primary tenant
UPDATE public.photo_gallery 
SET tenant_id = (SELECT id FROM public.tenants WHERE slug = 'primary' LIMIT 1)
WHERE tenant_id IS NULL;

-- Now make it NOT NULL
ALTER TABLE public.photo_gallery 
  ALTER COLUMN tenant_id SET NOT NULL;

-- ============================================
-- 3. Add index for tenant isolation
-- ============================================
CREATE INDEX IF NOT EXISTS idx_photo_gallery_tenant_id 
  ON public.photo_gallery(tenant_id);

-- ============================================
-- 4. Reload PostgREST schema cache
-- ============================================
NOTIFY pgrst, 'reload schema';

COMMENT ON COLUMN public.photo_gallery.published_at IS 'Date/time when the album was published';
COMMENT ON COLUMN public.photo_gallery.reviewed_at IS 'Date/time when the album was reviewed';
COMMENT ON COLUMN public.photo_gallery.approved_at IS 'Date/time when the album was approved';
