-- Function to log changes to the audit_logs table
CREATE OR REPLACE FUNCTION public.log_audit_event()
RETURNS TRIGGER AS $$
DECLARE
    actor_id UUID;
    action_type TEXT;
    payload JSONB;
BEGIN
    -- Determine Actor (User who caused the change)
    -- Fallback to system if not auth.uid() (e.g. service role)
    actor_id := auth.uid();
    
    -- Determine Action Type
    IF (TG_OP = 'INSERT') THEN
        action_type := 'CREATE';
        payload := to_jsonb(NEW);
    ELSIF (TG_OP = 'UPDATE') THEN
        action_type := 'UPDATE';
        payload := to_jsonb(NEW); -- Or jsonb_build_object('old', OLD, 'new', NEW)
    ELSIF (TG_OP = 'DELETE') THEN
        action_type := 'DELETE';
        payload := to_jsonb(OLD);
    END IF;

    -- Insert Log
    INSERT INTO public.audit_logs (user_id, action, resource, details, created_at)
    VALUES (
        actor_id,
        action_type,
        TG_TABLE_NAME, 
        payload,
        now()
    );

    RETURN NULL;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply Triggers to Critical Tables

-- Users
DROP TRIGGER IF EXISTS audit_users ON public.users;
CREATE TRIGGER audit_users
AFTER INSERT OR UPDATE OR DELETE ON public.users
FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();

-- Roles
DROP TRIGGER IF EXISTS audit_roles ON public.roles;
CREATE TRIGGER audit_roles
AFTER INSERT OR UPDATE OR DELETE ON public.roles
FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();

-- Permissions
DROP TRIGGER IF EXISTS audit_role_permissions ON public.role_permissions;
CREATE TRIGGER audit_role_permissions
AFTER INSERT OR UPDATE OR DELETE ON public.role_permissions
FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();

-- Orders (Financial Data)
DROP TRIGGER IF EXISTS audit_orders ON public.orders;
CREATE TRIGGER audit_orders
AFTER INSERT OR UPDATE OR DELETE ON public.orders
FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();

-- Products (Inventory)
DROP TRIGGER IF EXISTS audit_products ON public.products;
CREATE TRIGGER audit_products
AFTER INSERT OR UPDATE OR DELETE ON public.products
FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();

-- Settings (Config)
DROP TRIGGER IF EXISTS audit_settings ON public.settings;
CREATE TRIGGER audit_settings
AFTER INSERT OR UPDATE OR DELETE ON public.settings
FOR EACH ROW EXECUTE FUNCTION public.log_audit_event();
