-- Performance Index Optimization Migration (Fixed)
-- Adds missing indexes for foreign keys as recommended by Supabase Performance Advisor
-- Date: 2026-01-09

-- ============================================
-- INDEXES FOR UNINDEXED FOREIGN KEYS
-- ============================================

-- notification_readers: Add index on foreign key columns
CREATE INDEX IF NOT EXISTS idx_notification_readers_notification_id 
  ON public.notification_readers(notification_id);

CREATE INDEX IF NOT EXISTS idx_notification_readers_user_id 
  ON public.notification_readers(user_id);

-- template_parts: Add index on tenant_id FK
CREATE INDEX IF NOT EXISTS idx_template_parts_tenant_id 
  ON public.template_parts(tenant_id);

-- two_factor_audit_logs: Add index on foreign key columns
CREATE INDEX IF NOT EXISTS idx_two_factor_audit_logs_user_id 
  ON public.two_factor_audit_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_two_factor_audit_logs_tenant_id 
  ON public.two_factor_audit_logs(tenant_id);

-- widgets: Add index on foreign key columns
CREATE INDEX IF NOT EXISTS idx_widgets_tenant_id 
  ON public.widgets(tenant_id);

CREATE INDEX IF NOT EXISTS idx_widgets_area_id 
  ON public.widgets(area_id);

-- ============================================
-- COMMENTS
-- ============================================

COMMENT ON INDEX idx_notification_readers_notification_id IS 'Performance: Index for FK constraint lookups';
COMMENT ON INDEX idx_notification_readers_user_id IS 'Performance: Index for FK constraint lookups';
COMMENT ON INDEX idx_template_parts_tenant_id IS 'Performance: Index for tenant isolation';
COMMENT ON INDEX idx_two_factor_audit_logs_user_id IS 'Performance: Index for FK constraint lookups';
COMMENT ON INDEX idx_two_factor_audit_logs_tenant_id IS 'Performance: Index for tenant isolation';
COMMENT ON INDEX idx_widgets_tenant_id IS 'Performance: Index for tenant isolation';
COMMENT ON INDEX idx_widgets_area_id IS 'Performance: Index for FK constraint lookups';
