-- 1. Create a mapping of duplicates to their primary ID
CREATE TEMP TABLE permission_mapping AS
WITH ranked_perms AS (
  SELECT
    id,
    module,
    resource,
    action,
    ROW_NUMBER() OVER (
      PARTITION BY module, resource, action
      ORDER BY created_at ASC, id ASC
    ) as rnk
  FROM permissions
  WHERE deleted_at IS NULL
)
SELECT
  d.id as duplicate_id,
  p.id as primary_id
FROM ranked_perms d
JOIN ranked_perms p ON
  (d.module IS NOT DISTINCT FROM p.module) AND
  (d.resource IS NOT DISTINCT FROM p.resource) AND
  (d.action IS NOT DISTINCT FROM p.action) AND
  p.rnk = 1
WHERE d.rnk > 1;

-- 2. Consolidate role_permissions
-- 2a. Insert Primary mapping for roles that have the Duplicate but NOT the Primary
INSERT INTO role_permissions (role_id, permission_id)
SELECT DISTINCT rp.role_id, pm.primary_id
FROM role_permissions rp
JOIN permission_mapping pm ON rp.permission_id = pm.duplicate_id
WHERE NOT EXISTS (
  SELECT 1 FROM role_permissions rp_existing
  WHERE rp_existing.role_id = rp.role_id
  AND rp_existing.permission_id = pm.primary_id
);

-- 2b. Delete all role_permissions pointing to duplicates
DELETE FROM role_permissions
WHERE permission_id IN (SELECT duplicate_id FROM permission_mapping);

-- 3. Delete duplicates from permissions table
DELETE FROM permissions
WHERE id IN (SELECT duplicate_id FROM permission_mapping);

-- 4. Sync Owner Role (Grant all permissions)
INSERT INTO role_permissions (role_id, permission_id)
SELECT
  (SELECT id FROM roles WHERE name = 'owner'),
  p.id
FROM permissions p
WHERE p.deleted_at IS NULL
AND NOT EXISTS (
  SELECT 1 FROM role_permissions rp
  WHERE rp.role_id = (SELECT id FROM roles WHERE name = 'owner')
  AND rp.permission_id = p.id
);

-- Clean up
DROP TABLE permission_mapping;
