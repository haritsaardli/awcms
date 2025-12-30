
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://imveukxxtdwjgwsafwfl.supabase.co';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImltdmV1a3h4dGR3amd3c2Fmd2ZsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDgwNTQ2NCwiZXhwIjoyMDgwMzgxNDY0fQ.Frr49_TePnOOnI6vW-jUBUY_lf6d721YrKXRtngYXXM';

const supabase = createClient(supabaseUrl, supabaseServiceKey);

// NOTE: This script cannot execute DDL (CREATE POLICY).
// For this fix to take effect, the migration SQL MUST be run in Supabase Dashboard SQL Editor.

console.log('==================================================');
console.log('ACTION REQUIRED: Apply RLS FIX MANUALLY');
console.log('==================================================');
console.log();
console.log('Open your Supabase Dashboard SQL Editor and run:');
console.log();
console.log('--- SQL START ---');
console.log(`
DROP POLICY IF EXISTS "roles_select_unified" ON public.roles;

CREATE POLICY "roles_select_unified" ON public.roles FOR SELECT USING (
    tenant_id = public.current_tenant_id() 
    OR tenant_id IS NULL
    OR public.is_platform_admin()
);
`);
console.log('--- SQL END ---');
console.log();
console.log('This will allow users to read global roles (owner, super_admin).');
console.log('After applying, refresh your browser.');
