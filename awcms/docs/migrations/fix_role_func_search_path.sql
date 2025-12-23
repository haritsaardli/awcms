-- Fix Security Advisor Warning: Function Search Path Mutable
-- Explicitly set search_path to 'public' for the helper function

ALTER FUNCTION public.get_my_role_name() SET search_path = public;
