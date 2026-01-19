-- Rename tables to match Public Portal expectations
ALTER TABLE IF EXISTS portfolio RENAME TO projects;
ALTER TABLE IF EXISTS testimonies RENAME TO testimonials;

-- Update permissions to match new resource names
-- This assumes standard AWCMS permission structure (resource, action)
UPDATE permissions 
SET resource = 'projects' 
WHERE resource = 'portfolio';

UPDATE permissions 
SET resource = 'testimonials' 
WHERE resource = 'testimonies';

-- Update any RLS policies that might reference the table name specifically in their name
-- (Note: Policies attached to the table move with the table, but their names might be confusing)
-- Optional: We can leave policy names as is, or rename them for clarity.
-- Since this is just a structure update, we will assume RLS policies are attached to the OID and persist.
