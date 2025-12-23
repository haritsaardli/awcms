-- Fix Security Advisor Warning: Function Search Path Mutable
-- Explicitly set search_path to 'public' for the audit triggering function to prevent search_path hijacking

ALTER FUNCTION public.log_audit_event() SET search_path = public;
