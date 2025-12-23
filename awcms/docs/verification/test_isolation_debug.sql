
DO $$
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
BEGIN
    RAISE NOTICE 'Starting Multi-Tenancy Isolation Test (DEBUG MODE)...';

    -- 1. Get Existing Users
    SELECT id INTO user_a_id FROM auth.users ORDER BY created_at ASC LIMIT 1;
    SELECT id INTO user_b_id FROM auth.users ORDER BY created_at ASC OFFSET 1 LIMIT 1;
    
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
    INSERT INTO public.users (id, email, full_name, tenant_id, role_id)
    VALUES (user_a_id, 'test_a@example.com', 'Test User A', tenant_a_id, safe_role_id)
    ON CONFLICT (id) DO UPDATE SET tenant_id = tenant_a_id, role_id = safe_role_id;

    INSERT INTO public.users (id, email, full_name, tenant_id, role_id)
    VALUES (user_b_id, 'test_b@example.com', 'Test User B', tenant_b_id, safe_role_id)
    ON CONFLICT (id) DO UPDATE SET tenant_id = tenant_b_id, role_id = safe_role_id;

    -- 5. Create Data
    INSERT INTO public.products (name, slug, tenant_id, status, is_available, price) 
    VALUES ('Product A', 'prod-a', tenant_a_id, 'active', true, 100)
    RETURNING id INTO prod_a_id;

    INSERT INTO public.products (name, slug, tenant_id, status, is_available, price) 
    VALUES ('Product B', 'prod-b', tenant_b_id, 'active', true, 200)
    RETURNING id INTO prod_b_id;

    -- DEBUG: Check Context
    PERFORM set_config('request.jwt.claim.sub', user_a_id::text, true);
    PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

    SELECT public.current_tenant_id() INTO debug_tid;
    SELECT public.is_platform_admin() INTO debug_is_admin;
    RAISE NOTICE 'DEBUG: User A (%), Tenant in DB Should Be: %. CurrentTenantFunc: %. IsPlatformAdmin: %', 
        user_a_id, tenant_a_id, debug_tid, debug_is_admin;

    -- Verify Products
    SELECT count(*) INTO count_result FROM public.products;
    RAISE NOTICE 'DEBUG: User A sees % products.', count_result;
    
    -- Dump visible products tenant_ids to understand what is leaking
    -- We need to iterate or array agg.
    -- Cannot easily print table in NOTICE.
    -- But we can count how many match tenant_a_id vs others.
    
    DECLARE
        a_count INT;
        b_count INT;
        other_count INT;
    BEGIN
        SELECT count(*) INTO a_count FROM public.products WHERE tenant_id = tenant_a_id;
        SELECT count(*) INTO b_count FROM public.products WHERE tenant_id = tenant_b_id;
        SELECT count(*) INTO other_count FROM public.products WHERE tenant_id NOT IN (tenant_a_id, tenant_b_id);
        
        RAISE NOTICE 'DEBUG Breakdown: Tenant A Rows: %, Tenant B Rows: %, Other Rows: %', a_count, b_count, other_count;
    END;

    RAISE EXCEPTION 'DEBUG_STOP (Rolled Back)';
END $$;
