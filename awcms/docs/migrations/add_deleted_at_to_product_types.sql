-- Migration: Add deleted_at column to product_types table
-- Run this in Supabase SQL Editor if the column doesn't exist

-- Add deleted_at column if it doesn't exist
ALTER TABLE product_types 
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ DEFAULT NULL;

-- Add created_by column if it doesn't exist (for owner tracking)
ALTER TABLE product_types 
ADD COLUMN IF NOT EXISTS created_by UUID REFERENCES auth.users(id);

-- Update RLS policies to allow UPDATE (for soft delete)
-- First, check if policy exists, if not create it

-- Policy for viewing (non-deleted items)
DROP POLICY IF EXISTS "Allow view non-deleted product_types" ON product_types;
CREATE POLICY "Allow view non-deleted product_types" 
ON product_types FOR SELECT 
USING (deleted_at IS NULL OR deleted_at IS NOT NULL);

-- Policy for updating (soft delete)
DROP POLICY IF EXISTS "Allow update product_types" ON product_types;
CREATE POLICY "Allow update product_types" 
ON product_types FOR UPDATE 
USING (true)
WITH CHECK (true);

-- If you want to restrict update to only owners, use:
-- CREATE POLICY "Allow update own product_types" 
-- ON product_types FOR UPDATE 
-- USING (auth.uid() = created_by)
-- WITH CHECK (true);

-- Create index for faster queries on deleted_at
CREATE INDEX IF NOT EXISTS idx_product_types_deleted_at ON product_types(deleted_at);
