
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
BEGIN
    RAISE NOTICE 'Starting Multi-Tenancy Isolation Test (Transaction-safe)...';

    -- 1. Get Existing Users
    SELECT id INTO user_a_id FROM auth.users ORDER BY created_at ASC LIMIT 1;
    SELECT id INTO user_b_id FROM auth.users ORDER BY created_at ASC OFFSET 1 LIMIT 1;
    
    IF user_a_id IS NULL OR user_b_id IS NULL THEN
        RAISE EXCEPTION 'Not enough users in auth.users to run test (need 2)';
    END IF;

    -- 2. Get Safe Role (Viewer) to ensure no admin privileges
    SELECT id INTO safe_role_id FROM public.roles WHERE name = 'viewer' LIMIT 1;
    IF safe_role_id IS NULL THEN
        -- Fallback to 'public' or just pick a non-admin role
        SELECT id INTO safe_role_id FROM public.roles WHERE name NOT IN ('super_admin', 'super_super_admin', 'admin') LIMIT 1;
    END IF;
    RAISE NOTICE 'Using Safe Role ID: %', safe_role_id;

    -- 3. Create Tenants
    INSERT INTO public.tenants (name, slug, status, subscription_tier) 
    VALUES ('VOLATILE-TEST-A', 'volatile-test-a', 'active', 'free') 
    RETURNING id INTO tenant_a_id;

    INSERT INTO public.tenants (name, slug, status, subscription_tier) 
    VALUES ('VOLATILE-TEST-B', 'volatile-test-b', 'active', 'free') 
    RETURNING id INTO tenant_b_id;

    -- 4. Update/Insert Public Users
    -- Assign them to Test Tenants AND Safe Role
    INSERT INTO public.users (id, email, full_name, tenant_id, role_id)
    VALUES (user_a_id, 'test_a@example.com', 'Test User A', tenant_a_id, safe_role_id)
    ON CONFLICT (id) DO UPDATE SET tenant_id = tenant_a_id, role_id = safe_role_id;

    INSERT INTO public.users (id, email, full_name, tenant_id, role_id)
    VALUES (user_b_id, 'test_b@example.com', 'Test User B', tenant_b_id, safe_role_id)
    ON CONFLICT (id) DO UPDATE SET tenant_id = tenant_b_id, role_id = safe_role_id;

    -- 5. Create Data (Products)
    INSERT INTO public.products (name, slug, tenant_id, status, is_available, price) 
    VALUES ('Product A', 'prod-a', tenant_a_id, 'active', true, 100)
    RETURNING id INTO prod_a_id;

    INSERT INTO public.products (name, slug, tenant_id, status, is_available, price) 
    VALUES ('Product B', 'prod-b', tenant_b_id, 'active', true, 200)
    RETURNING id INTO prod_b_id;

    -- 6. VERIFY Data Visibility
    
    -- SWITCH CONTEXT TO USER A
    PERFORM set_config('request.jwt.claim.sub', user_a_id::text, true);
    PERFORM set_config('request.jwt.claim.role', 'authenticated', true);
    
    -- Check Products Count
    SELECT count(*) INTO count_result FROM public.products;
    
    IF count_result != 1 THEN 
         -- Check if they see existing data? (Maybe old products with null tenant?)
         -- If old products exist, count might be > 1.
         -- WE NEED TO FILTER BY OUR TEST IDS in validation to be sure?
         -- But RLS should hide everything else if tenant_id doesn't match!
         -- Unless existing products have tenant_id = tenant_a_id (impossible, new uuid).
         -- Or existing products have proper RLS to be hidden.
         -- If User A sees 3 products, it means they see 2 EXTRA products.
         RAISE EXCEPTION 'FAIL: User A saw % products (Expected 1). Context: Tenant A=%', count_result, tenant_a_id;
    END IF;
    
    -- Check Access to Own Product
    SELECT count(*) INTO count_result FROM public.products WHERE id = prod_a_id;
    IF count_result != 1 THEN
        RAISE EXCEPTION 'FAIL: User A cannot see their own product';
    END IF;

    -- Check Access to Tenant B Product
    SELECT count(*) INTO count_result FROM public.products WHERE id = prod_b_id;
    IF count_result != 0 THEN
        RAISE EXCEPTION 'FAIL: User A can see Tenant B product';
    END IF;

    RAISE NOTICE 'User A Isolation: PASS';

    -- SWITCH CONTEXT TO USER B
    PERFORM set_config('request.jwt.claim.sub', user_b_id::text, true);
    PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

    SELECT count(*) INTO count_result FROM public.products;
    IF count_result != 1 THEN
         RAISE EXCEPTION 'FAIL: User B saw % products (Expected 1)', count_result;
    END IF;

    RAISE NOTICE 'User B Isolation: PASS';

    -- 7. Trigger Rollback (Success)
    RAISE EXCEPTION 'SUCCESS: ISO_TEST_PASSED';

EXCEPTION WHEN OTHERS THEN
    IF SQLERRM = 'SUCCESS: ISO_TEST_PASSED' THEN
        RAISE NOTICE 'Verification Complete: Isolation is working correctly.';
        RAISE EXCEPTION 'SUCCESS: ISO_TEST_PASSED (Rolled Back)';
    ELSE
        RAISE NOTICE 'Test Failed with: %', SQLERRM;
        RAISE; -- Re-raise to rollback
    END IF;
END $$;
