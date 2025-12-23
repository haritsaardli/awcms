-- Consolidated Fixes for Sidebar, Testimonials, and Categories
-- Run this entire script in Supabase SQL Editor

-- 1. Fix Testimonials Menu Path
UPDATE admin_menus SET path = 'testimonies', updated_at = NOW() WHERE key = 'testimonies' AND path = 'testimonials';
UPDATE admin_menus SET path = 'testimonies', updated_at = NOW() WHERE label = 'Testimonials' AND path = 'testimonials';

-- 2. Add Missing Columns to Testimonies Table
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'testimonies' AND column_name = 'published_at') THEN
        ALTER TABLE testimonies ADD COLUMN published_at TIMESTAMPTZ;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'testimonies' AND column_name = 'slug') THEN
        ALTER TABLE testimonies ADD COLUMN slug TEXT UNIQUE;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'testimonies' AND column_name = 'author_position') THEN
        ALTER TABLE testimonies ADD COLUMN author_position TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'testimonies' AND column_name = 'author_image') THEN
        ALTER TABLE testimonies ADD COLUMN author_image TEXT;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'testimonies' AND column_name = 'category_id') THEN
        ALTER TABLE testimonies ADD COLUMN category_id UUID REFERENCES categories(id);
    END IF;
END $$;
CREATE INDEX IF NOT EXISTS idx_testimonies_status ON testimonies(status);

-- 3. Add Missing Columns to Categories Table
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'categories' AND column_name = 'deleted_at') THEN
        ALTER TABLE categories ADD COLUMN deleted_at TIMESTAMPTZ;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'categories' AND column_name = 'created_by') THEN
        ALTER TABLE categories ADD COLUMN created_by UUID REFERENCES auth.users(id);
    END IF;
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'categories' AND column_name = 'created_at') THEN
        ALTER TABLE categories ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
     IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'categories' AND column_name = 'updated_at') THEN
        ALTER TABLE categories ADD COLUMN updated_at TIMESTAMPTZ DEFAULT NOW();
    END IF;
END $$;
CREATE INDEX IF NOT EXISTS idx_categories_deleted_at ON categories(deleted_at);
