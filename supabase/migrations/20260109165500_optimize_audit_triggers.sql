-- Drop the redundant trigger on public.users
-- We keep 'audit_log_changes_users' as the primary trigger
DROP TRIGGER IF EXISTS audit_users ON public.users;
