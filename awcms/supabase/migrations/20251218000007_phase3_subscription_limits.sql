-- Phase 3: Subscription & Limits

-- 1. Function to check tenant limits
CREATE OR REPLACE FUNCTION public.check_tenant_limit(
    check_tenant_id UUID,
    feature_key TEXT,
    proposed_usage BIGINT DEFAULT 0
)
RETURNS BOOLEAN AS $$
DECLARE
    tier TEXT;
    current_usage BIGINT := 0;
    max_limit BIGINT;
BEGIN
    -- Get Tenant Tier
    SELECT subscription_tier INTO tier
    FROM public.tenants
    WHERE id = check_tenant_id;

    -- Define Limits based on Tier
    -- Users Limit (count)
    IF feature_key = 'max_users' THEN
        IF tier = 'enterprise' THEN max_limit := -1; -- Unlimited
        ELSIF tier = 'pro' THEN max_limit := 50;
        ELSE max_limit := 5; -- Free
        END IF;
        
        -- Get Current Usage
        SELECT count(*) INTO current_usage
        FROM public.users
        WHERE tenant_id = check_tenant_id;

    -- Storage Limit (bytes)
    ELSIF feature_key = 'max_storage' THEN
        IF tier = 'enterprise' THEN max_limit := -1; -- Unlimited
        ELSIF tier = 'pro' THEN max_limit := 10737418240; -- 10GB
        ELSE max_limit := 104857600; -- 100MB
        END IF;

        -- Get Current Usage
        SELECT COALESCE(SUM(file_size), 0) INTO current_usage
        FROM public.files
        WHERE tenant_id = check_tenant_id AND deleted_at IS NULL;
    END IF;

    -- Check Limit (-1 means unlimited)
    IF max_limit = -1 THEN
        RETURN TRUE;
    END IF;

    -- For storage, we add the proposed file size. For users, the trigger happens BEFORE insert, so current usage is existing users.
    -- If adding a user, proposed_usage should be 1.
    -- If adding a file, proposed_usage is the file size.
    
    IF (current_usage + proposed_usage) > max_limit THEN
        RETURN FALSE;
    END IF;

    RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Trigger for Max Users
CREATE OR REPLACE FUNCTION public.enforce_user_limit()
RETURNS TRIGGER AS $$
DECLARE
    limit_ok BOOLEAN;
BEGIN
    -- Only check if tenant_id is set
    IF NEW.tenant_id IS NOT NULL THEN
        -- Check limit (proposed usage 1 because we are adding 1 user)
        limit_ok := public.check_tenant_limit(NEW.tenant_id, 'max_users', 1);
        
        IF NOT limit_ok THEN
            RAISE EXCEPTION 'Tenant user quota exceeded. Upgrade your plan to add more users.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_enforce_user_limit ON public.users;
CREATE TRIGGER tr_enforce_user_limit
BEFORE INSERT ON public.users
FOR EACH ROW
EXECUTE FUNCTION public.enforce_user_limit();

-- 3. Trigger for Max Storage
CREATE OR REPLACE FUNCTION public.enforce_storage_limit()
RETURNS TRIGGER AS $$
DECLARE
    limit_ok BOOLEAN;
BEGIN
    IF NEW.tenant_id IS NOT NULL AND NEW.file_size IS NOT NULL THEN
        -- Check limit (proposed usage is the new file's size)
        limit_ok := public.check_tenant_limit(NEW.tenant_id, 'max_storage', NEW.file_size);
        
        IF NOT limit_ok THEN
            RAISE EXCEPTION 'Tenant storage quota exceeded. Upgrade your plan to upload more files.';
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS tr_enforce_storage_limit ON public.files;
CREATE TRIGGER tr_enforce_storage_limit
BEFORE INSERT ON public.files
FOR EACH ROW
EXECUTE FUNCTION public.enforce_storage_limit();
