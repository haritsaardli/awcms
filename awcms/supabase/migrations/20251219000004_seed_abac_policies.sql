-- Migration: Seed ABAC Policies
-- Description: Inserts standard ABAC policies and assigns them to roles

DO $$
DECLARE
  v_policy_id UUID;
  v_admin_role_id UUID;
  v_author_role_id UUID;
  v_tenant_id UUID; -- Optional: if we want to bind to a specific tenant, but here we'll duplicate or make global?
                    -- The schema allows tenant_id to be NULL for global policies.
BEGIN

  -- 1. Create "Restrict Mobile Deletion" Policy (Global)
  INSERT INTO public.policies (name, description, definition, tenant_id)
  VALUES (
    'Restrict Mobile Deletion',
    'Prevents deletion of resources when using mobile devices',
    '{
      "effect": "deny",
      "actions": ["delete", "delete_permanent"],
      "conditions": {
        "channel": "mobile"
      }
    }'::jsonb,
    NULL -- Global policy
  )
  ON CONFLICT DO NOTHING
  RETURNING id INTO v_policy_id;

  -- Verify/Get ID if it already existed
  IF v_policy_id IS NULL THEN
    SELECT id INTO v_policy_id FROM public.policies WHERE name = 'Restrict Mobile Deletion';
  END IF;

  -- 2. Assign to 'admin' role (Tenant Admin)
  -- Rationale: Admins on Mobile should not be deleting critical data easily, or maybe they CAN?
  -- ABAC_SYSTEM.md says: Admin (Tenant) on Mobile -> "tanpa publish & delete".
  -- So YES, we apply this to Admin.
  
  SELECT id INTO v_admin_role_id FROM public.roles WHERE name = 'admin';

  IF v_admin_role_id IS NOT NULL AND v_policy_id IS NOT NULL THEN
    INSERT INTO public.role_policies (role_id, policy_id)
    VALUES (v_admin_role_id, v_policy_id)
    ON CONFLICT DO NOTHING;
  END IF;

  -- 3. Assign to 'editor' role as well?
  -- Editor (Tenant) -> Mobile access is generally restricted heavily too?
  -- ABAC_SYSTEM.md says Editor has "Mobile -> ❌" generally or limited?
  -- Actually Editor table says: Web ✅. Mobile column is not fully generic there but implied similar.
  -- Let's stick to Admin for now as the clear example.

END $$;
