-- Migration: Add missing columns to testimonies table
-- Required by TestimonyManager form fields

-- Add published_at column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'testimonies' AND column_name = 'published_at'
    ) THEN
        ALTER TABLE testimonies ADD COLUMN published_at TIMESTAMPTZ;
    END IF;
END $$;

-- Add slug column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'testimonies' AND column_name = 'slug'
    ) THEN
        ALTER TABLE testimonies ADD COLUMN slug TEXT UNIQUE;
    END IF;
END $$;

-- Add author_position column if it doesn't exist  
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'testimonies' AND column_name = 'author_position'
    ) THEN
        ALTER TABLE testimonies ADD COLUMN author_position TEXT;
    END IF;
END $$;

-- Add author_image column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'testimonies' AND column_name = 'author_image'
    ) THEN
        ALTER TABLE testimonies ADD COLUMN author_image TEXT;
    END IF;
END $$;

-- Add category_id column if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'testimonies' AND column_name = 'category_id'
    ) THEN
        ALTER TABLE testimonies ADD COLUMN category_id UUID REFERENCES categories(id);
    END IF;
END $$;

-- Add index for faster lookup by status
CREATE INDEX IF NOT EXISTS idx_testimonies_status ON testimonies(status);
CREATE INDEX IF NOT EXISTS idx_testimonies_published_at ON testimonies(published_at);
