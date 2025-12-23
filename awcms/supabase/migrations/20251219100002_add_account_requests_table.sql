-- Migration: Account Requests Staging Table (Option B)
-- Date: 2025-12-19
-- Description: Creates a staging table for public account applications.
-- This supports the "Verify Email AFTER Approval" workflow by delaying Auth User creation.

-- 1. Create account_requests table
CREATE TABLE IF NOT EXISTS public.account_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    full_name TEXT NOT NULL,
    tenant_id UUID REFERENCES public.tenants(id),
    status TEXT DEFAULT 'pending_admin' 
        CHECK (status IN ('pending_admin', 'pending_super_admin', 'approved', 'rejected', 'completed')),
    admin_approved_at TIMESTAMPTZ,
    admin_approved_by UUID REFERENCES public.users(id),
    super_admin_approved_at TIMESTAMPTZ,
    super_admin_approved_by UUID REFERENCES public.users(id),
    rejection_reason TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Indexes
CREATE INDEX IF NOT EXISTS idx_account_requests_status ON public.account_requests(status);
CREATE INDEX IF NOT EXISTS idx_account_requests_tenant ON public.account_requests(tenant_id);
CREATE INDEX IF NOT EXISTS idx_account_requests_email ON public.account_requests(email);

-- 3. RLS Policies
ALTER TABLE public.account_requests ENABLE ROW LEVEL SECURITY;

-- Policy: Platform Admins can view/manage ALL requests
CREATE POLICY "Platform Admins manage all requests"
ON public.account_requests
FOR ALL TO authenticated
USING (public.is_platform_admin())
WITH CHECK (public.is_platform_admin());

-- Policy: Tenant Admins can view/update requests for their tenant
CREATE POLICY "Tenant Admins manage own requests"
ON public.account_requests
FOR ALL TO authenticated
USING (
    tenant_id = public.current_tenant_id() 
    AND public.is_admin_or_above()
    -- Admin can only see pending_admin or rejected? 
    -- Actually they should see progress.
)
WITH CHECK (
    tenant_id = public.current_tenant_id() 
    AND public.is_admin_or_above()
);

-- Policy: Public can INSERT (submit application) via Edge Function (Service Role)
-- But typically we might allow INSERT to anon if we wanted direct table access.
-- However, we'll use Edge Function which bypasses RLS, so anon policy is NOT needed 
-- unless we want direct client insert. Using Edge Function is safer for Turnstile check.

-- 4. Audit Logging Trigger (Reuse existing)
DROP TRIGGER IF EXISTS audit_account_requests ON public.account_requests;
CREATE TRIGGER audit_account_requests
AFTER INSERT OR UPDATE OR DELETE ON public.account_requests
FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();
