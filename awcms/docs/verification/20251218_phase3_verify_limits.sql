-- Phase 3 Verification: Subscription Limits

BEGIN;

-- 1. Setup
-- Ensure we have a defined tenant on free tier
INSERT INTO public.tenants (id, name, slug, status, subscription_tier) 
VALUES ('33333333-3333-3333-3333-333333333333', 'Limit Test Tenant', 'limit-tenant', 'active', 'free')
ON CONFLICT (id) DO UPDATE SET subscription_tier = 'free';

-- 2. Test User Limits (Free = 5 users)
-- Insert 5 users (should succeed)
DO $$
DECLARE
    i INT;
    uid UUID;
BEGIN
    FOR i IN 1..5 LOOP
        uid := gen_random_uuid();
        -- Insert into auth.users first to satisfy FK
        INSERT INTO auth.users (id, email) VALUES (uid, 'user'||i||'@limit.com') ON CONFLICT DO NOTHING;
        
        INSERT INTO public.users (id, email, tenant_id) 
        VALUES (uid, 'user'||i||'@limit.com', '33333333-3333-3333-3333-333333333333')
        ON CONFLICT DO NOTHING;
    END LOOP;
END $$;

-- Try inserting 6th user (Should Fail)
-- We use a block to catch exception so the script doesn't abort entirely, allowing us to report success.
DO $$
DECLARE
    uid UUID;
BEGIN
    uid := gen_random_uuid();
    INSERT INTO auth.users (id, email) VALUES (uid, 'user_fail@limit.com');
    
    INSERT INTO public.users (id, email, tenant_id) 
    VALUES (uid, 'user_fail@limit.com', '33333333-3333-3333-3333-333333333333');
    RAISE NOTICE 'FAIL: 6th user insert did NOT fail as expected.';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'PASS: 6th user insert failed as expected: %', SQLERRM;
END $$;


-- 3. Test Storage Limits (Free = 100MB)
-- Insert file of 101MB (105906176 bytes)
DO $$
BEGIN
    INSERT INTO public.files (name, file_path, file_size, file_type, bucket_name, uploaded_by, tenant_id)
    VALUES ('big_file.jpg', '33333333-3333-3333-3333-333333333333/big.jpg', 105906176, 'image/jpeg', 'cms-uploads', NULL, '33333333-3333-3333-3333-333333333333');
    RAISE NOTICE 'FAIL: Oversized file insert did NOT fail as expected.';
EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'PASS: Oversized file insert failed as expected: %', SQLERRM;
END $$;

ROLLBACK;
