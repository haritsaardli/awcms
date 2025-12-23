
CREATE OR REPLACE FUNCTION public.verify_isolation_debug()
RETURNS TEXT AS $$
DECLARE
    tenant_a_id UUID;
    tenant_b_id UUID;
    user_a_id UUID;
    user_b_id UUID;
    prod_a_id UUID;
    prod_b_id UUID;
    safe_role_id UUID;
    count_result INTEGER;
    debug_tid UUID;
    debug_is_admin BOOLEAN;
    
    orig_tid_a UUID;
    orig_role_a UUID;
    orig_tid_b UUID;
    orig_role_b UUID;
    
    log_text TEXT := '';
    
    a_count INT;
    b_count INT;
    other_count INT;
BEGIN
    log_text := log_text || 'Starting Multi-Tenancy Isolation Test (Function Mode - FORCE RLS)...' || E'\n';

    -- 1. Get Existing Users
    SELECT id INTO user_a_id FROM auth.users ORDER BY created_at ASC LIMIT 1;
    SELECT id INTO user_b_id FROM auth.users ORDER BY created_at ASC OFFSET 1 LIMIT 1;
    
    -- Save Original State
    SELECT tenant_id, role_id INTO orig_tid_a, orig_role_a FROM public.users WHERE id = user_a_id;
    SELECT tenant_id, role_id INTO orig_tid_b, orig_role_b FROM public.users WHERE id = user_b_id;

    -- 2. Safe Role
    SELECT id INTO safe_role_id FROM public.roles WHERE name = 'viewer' LIMIT 1;

    -- 3. Create Tenants
    INSERT INTO public.tenants (name, slug, status, subscription_tier) 
    VALUES ('VOLATILE-TEST-A', 'volatile-test-a', 'active', 'free') 
    RETURNING id INTO tenant_a_id;

    INSERT INTO public.tenants (name, slug, status, subscription_tier) 
    VALUES ('VOLATILE-TEST-B', 'volatile-test-b', 'active', 'free') 
    RETURNING id INTO tenant_b_id;

    -- 4. Update Users
    UPDATE public.users SET tenant_id = tenant_a_id, role_id = safe_role_id WHERE id = user_a_id;
    UPDATE public.users SET tenant_id = tenant_b_id, role_id = safe_role_id WHERE id = user_b_id;

    -- 5. Create Data
    INSERT INTO public.products (name, slug, tenant_id, status, is_available, price) 
    VALUES ('Product A', 'prod-a', tenant_a_id, 'active', true, 100)
    RETURNING id INTO prod_a_id;

    INSERT INTO public.products (name, slug, tenant_id, status, is_available, price) 
    VALUES ('Product B', 'prod-b', tenant_b_id, 'active', true, 200)
    RETURNING id INTO prod_b_id;

    -- FORCE RLS (To test as superuser)
    ALTER TABLE public.products FORCE ROW LEVEL SECURITY;

    -- DEBUG: Check Context
    PERFORM set_config('request.jwt.claim.sub', user_a_id::text, true);
    PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

    SELECT public.current_tenant_id() INTO debug_tid;
    SELECT public.is_platform_admin() INTO debug_is_admin;
    
    log_text := log_text || format('DEBUG: User A (%s), TenantDB: %s, CurrentTenantFunc: %s, IsAdmin: %s', user_a_id, tenant_a_id, debug_tid, debug_is_admin) || E'\n';

    -- Verify Products
    SELECT count(*) INTO count_result FROM public.products;
    log_text := log_text || format('DEBUG: User A sees %s products.', count_result) || E'\n';
    
    -- Breakdown
    SELECT count(*) INTO a_count FROM public.products WHERE tenant_id = tenant_a_id;
    SELECT count(*) INTO b_count FROM public.products WHERE tenant_id = tenant_b_id;
    SELECT count(*) INTO other_count FROM public.products WHERE tenant_id NOT IN (tenant_a_id, tenant_b_id);
    
    log_text := log_text || format('DEBUG Breakdown: Tenant A Rows: %s, Tenant B Rows: %s, Other Rows: %s', a_count, b_count, other_count) || E'\n';

    -- DISABLE FORCE RLS
    ALTER TABLE public.products NO FORCE ROW LEVEL SECURITY;

    -- CLEANUP
    
    -- RESET CONTEXT TO SUPERUSER (Bypass RLS execution context, but we are already superuser)
    PERFORM set_config('request.jwt.claim.sub', NULL, true);
    PERFORM set_config('request.jwt.claim.role', NULL, true);

    -- 1. Restore Users
    UPDATE public.users SET tenant_id = orig_tid_a, role_id = orig_role_a WHERE id = user_a_id;
    UPDATE public.users SET tenant_id = orig_tid_b, role_id = orig_role_b WHERE id = user_b_id;
    
    -- 2. Delete Data
    DELETE FROM public.products WHERE id IN (prod_a_id, prod_b_id);
    
    -- 3. Delete Audit Logs
    DELETE FROM public.audit_logs WHERE tenant_id IN (tenant_a_id, tenant_b_id);
    
    -- 4. Delete Tenants
    DELETE FROM public.tenants WHERE id IN (tenant_a_id, tenant_b_id);

    RETURN log_text;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
