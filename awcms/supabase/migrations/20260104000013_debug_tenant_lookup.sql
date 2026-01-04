-- Migration: 20260104000013_debug_tenant_lookup.sql
-- Description: Debug tenant lookup to verify existence and RPC resolution within the database

DO $$
DECLARE
    target_tenant_id uuid;
    resolved_id uuid;
    tenant_exists boolean;
    tenant_record record;
BEGIN
    RAISE NOTICE '--- DEBUG START ---';

    -- 1. Check if tenant exists directly
    SELECT * INTO tenant_record FROM tenants WHERE host = 'primary.ahliweb.com';
    
    IF tenant_record.id IS NOT NULL THEN
        RAISE NOTICE 'Tenant FOUND direct lookup (primary.ahliweb.com): ID=%, Name=%', tenant_record.id, tenant_record.name;
    ELSE
        RAISE NOTICE 'Tenant NOT FOUND by direct lookup (primary.ahliweb.com)';
    END IF;

    -- 2. Test RPC function with Alias
    resolved_id := get_tenant_id_by_host('primarypublic.ahliweb.com');
    
    IF resolved_id IS NOT NULL THEN
        RAISE NOTICE 'RPC Resolution SUCCESS (primarypublic.ahliweb.com) -> ID=%', resolved_id;
    ELSE
        RAISE NOTICE 'RPC Resolution FAILED (primarypublic.ahliweb.com) -> NULL';
    END IF;

    RAISE NOTICE '--- DEBUG END ---';
END $$;
