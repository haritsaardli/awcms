
import React, { createContext, useContext, useState, useEffect, useCallback, useMemo } from 'react';
import { useAuth } from '@/contexts/SupabaseAuthContext';
import { supabase } from '@/lib/customSupabaseClient';

const PermissionContext = createContext(undefined);

export const PermissionProvider = ({ children }) => {
  const { user } = useAuth();
  const [permissions, setPermissions] = useState([]);
  const [userRole, setUserRole] = useState(null);
  const [tenantId, setTenantId] = useState(null);
  const [abacPolicies, setAbacPolicies] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchUserPermissions = useCallback(async () => {
    if (!user) {
      setPermissions([]);
      setUserRole(null);
      setTenantId(null);
      setLoading(false);
      return;
    }

    try {
      // 1. Fetch User Role & Permissions from Database
      // FIX: Explicitly specify the foreign key relationship 'users_role_id_fkey'
      const { data: userData, error: userError } = await supabase
        .from('users')
        .select(`
          tenant_id,
          role_id,
          roles!users_role_id_fkey (
            name,
            role_permissions (
              permissions (
                name
              )
            )
          )
        `)
        .eq('id', user.id)
        .maybeSingle();

      if (userError) {
        console.error('Error fetching user permissions:', userError);
      }

      let dbRole = null;
      let dbPermissions = [];
      let dbTenantId = null;

      if (userData) {
        dbTenantId = userData.tenant_id;
        if (userData.roles) {
          dbRole = userData.roles.name;
          // Load permissions based on role
          if (dbRole === 'super_admin' || dbRole === 'owner') {
            // Will fetch all perms later if this role is active
          } else {
            dbPermissions = userData.roles.role_permissions
              ?.map(rp => rp.permissions?.name)
              .filter(Boolean) || [];

            // Load ABAC Policies (DISABLED: Table role_policies does not exist yet)
            // const policies = userData.roles.role_policies
            //   ?.map(rp => rp.policies?.definition)
            //   .filter(Boolean) || [];
            // setAbacPolicies(policies);
          }
        }
      }

      setTenantId(dbTenantId);

      // 2. Determine Final Role (DB vs Env Var Safety Net)
      const superAdminEmail = import.meta.env.VITE_SUPER_ADMIN_EMAIL;
      let finalRole = dbRole || 'guest';
      let finalPermissions = dbPermissions;

      // Safety Net: If user matches env var AND has no higher role from DB, grant super_admin
      // If DB says 'owner', we KEEP that (it's higher).
      // If DB says 'guest' but env match, we UPGRADE to 'super_admin'.
      if (superAdminEmail && user.email === superAdminEmail) {
        if (finalRole !== 'owner') { // Only 'owner' is higher than 'super_admin' now
          finalRole = 'super_admin';
          // If we upgraded via safety net, we might need to rely on env-var based bypass, 
          // but we'll fetch all permissions below anyway.
        }
      }

      setUserRole(finalRole);

      // 3. Load Permissions for Admin Roles
      if (finalRole === 'super_admin' || finalRole === 'owner') {
        const { data: allPerms } = await supabase.from('permissions').select('name');
        if (allPerms) {
          finalPermissions = allPerms.map(p => p.name);
        }
      }

      setPermissions(finalPermissions);

    } catch (error) {
      console.error('Unexpected error fetching permissions:', error);
    } finally {
      setLoading(false);
    }
  }, [user]);

  useEffect(() => {
    fetchUserPermissions();
  }, [fetchUserPermissions]);

  const hasPermission = useCallback((permission) => {
    if (!permission) return true;
    // --- SUPER ADMIN / OWNER BYPASS ---
    // If user is super_admin or owner, they have ALL permissions
    if (['super_admin', 'owner'].includes(userRole)) {
      return true;
    }
    const superAdminEmail = import.meta.env.VITE_SUPER_ADMIN_EMAIL;
    if (superAdminEmail && user?.email === superAdminEmail) return true;

    return permissions.includes(permission);
  }, [permissions, userRole, user]);

  const hasAnyPermission = useCallback((permissionList) => {
    // --- SUPER ADMIN / OWNER BYPASS ---
    // If user is super_admin or owner, they have ALL permissions
    if (['super_admin', 'owner'].includes(userRole)) {
      return true;
    }
    const superAdminEmail = import.meta.env.VITE_SUPER_ADMIN_EMAIL;
    if (superAdminEmail && user?.email === superAdminEmail) return true;
    if (!permissionList || permissionList.length === 0) return true;

    return permissionList.some(p => permissions.includes(p));
  }, [permissions, userRole, user]);

  // Enhanced Ownership Check Helper (ERP Aligned)
  const checkAccess = useCallback((action, resource, record = null) => {
    // --- SUPER ADMIN / OWNER BYPASS ---
    // If user is super_admin or owner, they have ALL permissions
    if (['super_admin', 'owner'].includes(userRole)) {
      return true;
    }

    // Construct Permission Key (Standard: tenant.resource.action)
    // If resource already has a dot (e.g. 'platform.user'), use it as is.
    const hasScope = resource.includes('.');
    const permissionKey = hasScope ? `${resource}.${action}` : `tenant.${resource}.${action}`;

    // 1. Check Explicit Permission (Admin level access)
    // Also check legacy format for backward compatibility if needed, but we are migrating.
    if (permissions.includes(permissionKey)) return true;

    // 2. Check Ownership (Author level access)
    // ERP: Authors have U-own (Update Own) permission implicit if they don't have explicit Update permission
    // but usually they rely on this check.
    if (record && record.created_by && user) {
      if (record.created_by === user.id) return true;
    }

    return false;
  }, [permissions, userRole, user]);

  /**
   * ABAC Policy Check (ERP Standard)
   * Evaluates JSON-based policies against the current action/context.
   * @param {string} action - e.g. 'delete', 'publish'
   * @param {string} resource - e.g. 'users', 'posts'
   * @param {object} context - { channel: 'web'|'mobile', ip: '...', time: '...' }
   */
  const checkPolicy = useCallback((action, resource, context = {}) => {
    // 1. Super Admins bypass everything
    // --- SUPER ADMIN / OWNER BYPASS ---
    // If user is super_admin or owner, they have ALL permissions
    if (['super_admin', 'owner'].includes(userRole)) {
      return true;
    }

    // 2. Default Context
    const finalContext = {
      channel: 'web', // Default channel
      ...context
    };

    // 3. Evaluate Policies
    // Default effect is DENY if no policy matches explicitly (or ALLOW if we rely on RBAC as base)
    // Strategy: RBAC is base ALLOW. Policies are RESTRICTIVE overwrites (Deny overrides Allow).

    // Check deny policies first
    const denyMatch = abacPolicies.some(policy => {
      if (policy.effect !== 'deny') return false;
      if (!policy.actions.includes('*') && !policy.actions.includes(action)) return false;

      // Check conditions
      if (policy.conditions) {
        if (policy.conditions.channel && policy.conditions.channel !== finalContext.channel) return false;
        // Add more condition checks here (time, ip, etc.)
      }
      return true; // Policy matches and denies
    });

    if (denyMatch) return false;

    return true; // No deny policy found (Permissive on top of RBAC)
  }, [abacPolicies, userRole]);

  // Platform Admin: Owner or Super Admin
  const isPlatformAdmin = useMemo(() => {
    return ['owner', 'super_admin'].includes(userRole);
  }, [userRole]);

  const value = React.useMemo(() => ({
    permissions,
    userRole,
    tenantId,
    isPlatformAdmin,
    loading,
    hasPermission,
    hasAnyPermission,
    checkAccess,
    checkPolicy,
    refreshPermissions: fetchUserPermissions
  }), [permissions, userRole, tenantId, isPlatformAdmin, loading, hasPermission, hasAnyPermission, checkAccess, checkPolicy, fetchUserPermissions]);

  return (
    <PermissionContext.Provider value={value}>
      {children}
    </PermissionContext.Provider>
  );
};

export const usePermissions = () => {
  const context = useContext(PermissionContext);
  if (context === undefined) {
    throw new Error('usePermissions must be used within a PermissionProvider');
  }
  return context;
};
