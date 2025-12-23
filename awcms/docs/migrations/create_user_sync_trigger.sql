-- =====================================================
-- Migration: Auto-create public.users from auth.users
-- Date: 2025-12-15
-- Description: Create trigger to sync auth.users to public.users
-- =====================================================

-- Create function to handle new auth user
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
    default_role_id UUID;
BEGIN
    -- Get the 'user' role or first available role
    SELECT id INTO default_role_id 
    FROM public.roles 
    WHERE name = 'user' 
    LIMIT 1;
    
    -- If no 'user' role, get any role
    IF default_role_id IS NULL THEN
        SELECT id INTO default_role_id 
        FROM public.roles 
        LIMIT 1;
    END IF;

    -- Insert into public.users
    INSERT INTO public.users (id, email, full_name, role_id, created_at, updated_at)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
        default_role_id,
        NOW(),
        NOW()
    )
    ON CONFLICT (id) DO NOTHING;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = '';

-- Create trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Verify trigger exists
SELECT tgname, tgrelid::regclass 
FROM pg_trigger 
WHERE tgname = 'on_auth_user_created';
