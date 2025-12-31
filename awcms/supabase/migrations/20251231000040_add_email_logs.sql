-- Migration: Add email_logs table for Mailketing webhook events
-- Run: npx supabase db push

-- Create email_logs table
CREATE TABLE IF NOT EXISTS public.email_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tenant_id UUID REFERENCES public.tenants(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL, -- sent, opened, clicked, bounced, subscribed, unsubscribed
    recipient TEXT NOT NULL,
    subject TEXT,
    template_id TEXT,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Create index for common queries
CREATE INDEX IF NOT EXISTS idx_email_logs_tenant ON public.email_logs(tenant_id);
CREATE INDEX IF NOT EXISTS idx_email_logs_recipient ON public.email_logs(recipient);
CREATE INDEX IF NOT EXISTS idx_email_logs_event_type ON public.email_logs(event_type);
CREATE INDEX IF NOT EXISTS idx_email_logs_created_at ON public.email_logs(created_at DESC);

-- Enable RLS
ALTER TABLE public.email_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "email_logs_select_unified" ON public.email_logs
    FOR SELECT USING (
        tenant_id = public.current_tenant_id()
        OR public.is_platform_admin()
    );

CREATE POLICY "email_logs_insert_unified" ON public.email_logs
    FOR INSERT WITH CHECK (
        public.is_admin_or_above()
        OR public.is_platform_admin()
    );

-- Comment
COMMENT ON TABLE public.email_logs IS 'Logs for email events from Mailketing webhooks';
