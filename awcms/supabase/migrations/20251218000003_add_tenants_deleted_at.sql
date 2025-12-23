-- Add deleted_at column to tenants for soft delete
ALTER TABLE tenants ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP WITH TIME ZONE DEFAULT NULL;

-- Update RLS if necessary? 
-- Usually we want to hide deleted tenants from general queries.
-- But for now, just adding the column is enough for the Manager to use it.
