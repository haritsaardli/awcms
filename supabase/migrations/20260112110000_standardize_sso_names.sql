-- Migration: Standardize SSO Provider Names
-- Date: 2026-01-12
-- Description: Updates provider names to standard 'Google', 'GitHub', 'Microsoft Azure' labels.

DO $$
DECLARE
    v_tenant_id UUID;
BEGIN
    -- 1. Get Tenant ID
    SELECT id INTO v_tenant_id FROM tenants WHERE slug = 'primary';
    
    IF v_tenant_id IS NOT NULL THEN
        RAISE NOTICE 'Standardizing SSO Names for Tenant: %', v_tenant_id;

        -- Update Google
        UPDATE sso_providers 
        SET name = 'Google' 
        WHERE tenant_id = v_tenant_id AND provider_id = 'google';

        -- Update GitHub
        UPDATE sso_providers 
        SET name = 'GitHub' 
        WHERE tenant_id = v_tenant_id AND provider_id = 'github';

        -- Update Azure
        UPDATE sso_providers 
        SET name = 'Microsoft Azure' 
        WHERE tenant_id = v_tenant_id AND provider_id = 'azure';
        
        -- Update Email
        UPDATE sso_providers 
        SET name = 'Email/Password' 
        WHERE tenant_id = v_tenant_id AND provider_id = 'email';

    END IF;
END $$;
