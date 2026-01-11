-- Migration: Configure SSO Providers for Primary Tenant
-- Date: 2026-01-12
-- Description: Disables Google, GitHub, and Azure providers. Enables Email provider.

DO $$
DECLARE
    v_tenant_id UUID;
BEGIN
    -- 1. Get Tenant ID
    SELECT id INTO v_tenant_id FROM tenants WHERE slug = 'primary';
    
    IF v_tenant_id IS NOT NULL THEN
        RAISE NOTICE 'Configuring SSO for Tenant: %', v_tenant_id;

        -- Disable Google, GitHub, Azure
        UPDATE sso_providers 
        SET is_active = false 
        WHERE tenant_id = v_tenant_id 
        AND provider_id IN ('google', 'github', 'azure');

        -- Enable Email (UPSERT to ensure it exists if the UI expects it in this table)
        -- Note: If 'email' provider row doesn't exist, we insert it.
        -- Assuming 'Email/Password' corresponds to provider_id 'email' based on UI.
        
        IF EXISTS (SELECT 1 FROM sso_providers WHERE tenant_id = v_tenant_id AND provider_id = 'email') THEN
            UPDATE sso_providers 
            SET is_active = true 
            WHERE tenant_id = v_tenant_id 
            AND provider_id = 'email';
        ELSE
            INSERT INTO sso_providers (tenant_id, provider_id, name, is_active)
            VALUES (v_tenant_id, 'email', 'Email/Password', true);
        END IF;
        
    ELSE
         RAISE NOTICE 'Tenant "primary" not found. Skipping SSO config.';
    END IF;
END $$;
