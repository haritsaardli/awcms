-- Migration: Add missing columns to categories table
-- Required for GenericContentManager soft delete functionality

-- Add deleted_at column if it doesn't exist (required for soft delete filtering)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'categories' AND column_name = 'deleted_at'
    ) THEN
        ALTER TABLE categories ADD COLUMN deleted_at TIMESTAMPTZ;
    END IF;
END $$;

-- Add created_by column if it doesn't exist (for owner tracking)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'categories' AND column_name = 'created_by'
    ) THEN
        ALTER TABLE categories ADD COLUMN created_by UUID REFERENCES auth.users(id);
    END IF;
END $$;

-- Add created_at column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'categories' AND column_name = 'created_at'
    ) THEN
        ALTER TABLE categories ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;

-- Add updated_at column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'categories' AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE categories ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;

-- Create index for soft delete queries
CREATE INDEX IF NOT EXISTS idx_categories_deleted_at ON categories(deleted_at);
CREATE INDEX IF NOT EXISTS idx_categories_type ON categories(type);
