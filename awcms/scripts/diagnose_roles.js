
import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://imveukxxtdwjgwsafwfl.supabase.co';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImltdmV1a3h4dGR3amd3c2Fmd2ZsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2NDgwNTQ2NCwiZXhwIjoyMDgwMzgxNDY0fQ.Frr49_TePnOOnI6vW-jUBUY_lf6d721YrKXRtngYXXM';

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function diagnose() {
    console.log('=== DB DIAGNOSTIC ===');

    // 1. Get user cms@ahliweb.com
    console.log('1. Fetching user cms@ahliweb.com...');
    const { data: user, error: userError } = await supabase
        .from('users')
        .select('id, email, role_id, tenant_id')
        .eq('email', 'cms@ahliweb.com')
        .single();

    if (userError) { console.error('User Error:', userError); return; }
    console.log('User:', user);

    // 2. Check if role_id is valid
    console.log('\n2. Fetching role by role_id:', user.role_id);
    const { data: role, error: roleError } = await supabase
        .from('roles')
        .select('id, name, tenant_id')
        .eq('id', user.role_id)
        .single();

    if (roleError) { console.error('Role Error:', roleError); }
    else console.log('Role:', role);

    // 3. List all roles to see what's available
    console.log('\n3. Listing all roles...');
    const { data: allRoles, error: allRolesError } = await supabase
        .from('roles')
        .select('id, name, tenant_id')
        .is('deleted_at', null);

    if (allRolesError) { console.error('All Roles Error:', allRolesError); }
    else console.log('Available Roles:', allRoles);

    // 4. Check owner role specifically
    console.log('\n4. Checking owner role...');
    const { data: ownerRole, error: ownerRoleError } = await supabase
        .from('roles')
        .select('id, name, tenant_id')
        .eq('name', 'owner')
        .single();

    if (ownerRoleError) { console.error('Owner Role Error:', ownerRoleError); }
    else console.log('Owner Role:', ownerRole);

    console.log('\n=== DIAGNOSIS COMPLETE ===');
}

diagnose();
