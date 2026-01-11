drop policy "audit_logs_insert_unified" on "public"."audit_logs";

drop policy "audit_logs_select_unified" on "public"."audit_logs";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.cleanup_old_login_audit_logs()
 RETURNS integer
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
DECLARE
  deleted_count INTEGER;
BEGIN
  WITH ranked_logs AS (
    SELECT id, 
           ROW_NUMBER() OVER (PARTITION BY tenant_id ORDER BY created_at DESC) as rn
    FROM audit_logs 
    WHERE action = 'user.login'
  ),
  logs_to_delete AS (
    SELECT id FROM ranked_logs WHERE rn > 100
  )
  DELETE FROM audit_logs 
  WHERE id IN (SELECT id FROM logs_to_delete);
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.current_auth_user_id()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
  RETURN auth.uid();
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.current_user_tenant_id()
 RETURNS uuid
 LANGUAGE plpgsql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
  RETURN NULLIF(current_setting('app.current_tenant_id', true), '')::UUID;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.get_current_tenant_id()
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  SELECT NULLIF(current_setting('app.current_tenant_id', true), '')::UUID
$function$
;

CREATE OR REPLACE FUNCTION public.get_current_user_id()
 RETURNS uuid
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
  SELECT auth.uid()
$function$
;


  create policy "audit_logs_insert"
  on "public"."audit_logs"
  as permissive
  for insert
  to authenticated
with check (((user_id = public.get_current_user_id()) OR (action = 'user.login'::text)));



  create policy "audit_logs_select"
  on "public"."audit_logs"
  as permissive
  for select
  to authenticated
using (((tenant_id = public.get_current_tenant_id()) OR (tenant_id IS NULL)));



