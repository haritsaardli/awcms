
import React, { useState, useEffect } from 'react';
import ContentTable from '@/components/dashboard/ContentTable';
import RoleEditor from '@/components/dashboard/RoleEditor';
import { usePermissions } from '@/contexts/PermissionContext';
// Standard Permissions: tenant.role.read, tenant.role.create, tenant.role.update, tenant.role.delete
import { useToast } from '@/components/ui/use-toast';
import { supabase } from '@/lib/customSupabaseClient';
import { Button } from '@/components/ui/button';
import { Plus, Shield, RefreshCw, Trash2, Crown } from 'lucide-react';
import { AdminPageLayout, PageHeader } from '@/templates/flowbite-admin';
import { useSearch } from '@/hooks/useSearch';
import MinCharSearchInput from '@/components/common/MinCharSearchInput';
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from '@/components/ui/alert-dialog';

import { useTenant } from '@/contexts/TenantContext';

function RolesManager() {
  const { toast } = useToast();
  const { hasPermission, isPlatformAdmin } = usePermissions();
  const { currentTenant } = useTenant();

  // State declarations
  const [roles, setRoles] = useState([]);
  const [loading, setLoading] = useState(true);

  // Search
  const {
    query,
    setQuery,
    debouncedQuery,
    isValid: isSearchValid,
    message: searchMessage,
    loading: searchLoading,
    minLength,
    clearSearch
  } = useSearch({ context: 'admin' });

  const [showEditor, setShowEditor] = useState(false);
  const [selectedRole, setSelectedRole] = useState(null);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [roleToDelete, setRoleToDelete] = useState(null);

  // Permission checks
  const canView = hasPermission('tenant.role.read');
  const canCreate = hasPermission('tenant.role.create');
  const canEdit = hasPermission('tenant.role.update');
  const canDelete = hasPermission('tenant.role.delete');

  useEffect(() => {
    fetchRoles();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const fetchRoles = async () => {
    setLoading(true);
    try {
      let dbQuery = supabase
        .from('roles')
        .select('*, owner:users!created_by(email), role_permissions(count), tenant:tenants(name)')
        .is('deleted_at', null)
        .order('created_at', { ascending: true });

      // Explicit Tenant Isolation (unless Platform Admin)
      if (!isPlatformAdmin && currentTenant?.id) {
        dbQuery = dbQuery.eq('tenant_id', currentTenant.id);
      }

      const { data, error } = await dbQuery;

      if (error) throw error;
      setRoles(data || []);
    } catch (err) {
      console.error(err);
      toast({ variant: 'destructive', title: 'Error', description: 'Failed to load roles' });
    } finally {
      setLoading(false);
    }
  };

  const handleEdit = (role) => {
    setSelectedRole(role);
    setShowEditor(true);
  };

  // Open delete confirmation dialog
  const openDeleteDialog = (role) => {
    if (['owner', 'super_admin', 'admin', 'public', 'guest'].includes(role.name)) {
      toast({ variant: 'destructive', title: 'Protected Role', description: 'System roles cannot be deleted.' });
      return;
    }
    setRoleToDelete(role);
    setDeleteDialogOpen(true);
  };

  // Execute the actual delete
  const handleConfirmDelete = async () => {
    if (!roleToDelete) return;

    setDeleteDialogOpen(false);
    setLoading(true);

    try {
      // Check if users are assigned
      const { count } = await supabase.from('users').select('*', { count: 'exact', head: true }).eq('role_id', roleToDelete.id);

      if (count > 0) {
        toast({ variant: 'destructive', title: 'Cannot Delete', description: `There are ${count} users assigned to this role. Reassign them first.` });
        return;
      }

      const { error } = await supabase
        .from('roles')
        .update({ deleted_at: new Date().toISOString() })
        .eq('id', roleToDelete.id);

      if (error) throw error;

      toast({ title: 'Success', description: 'Role deleted successfully' });
      fetchRoles();
    } catch (err) {
      toast({ variant: 'destructive', title: 'Error', description: err.message });
    } finally {
      setLoading(false);
      setRoleToDelete(null);
    }
  };

  const filteredRoles = roles.filter(role => {
    if (!debouncedQuery) return true;
    const lower = debouncedQuery.toLowerCase();
    return role.name.toLowerCase().includes(lower) ||
      role.description?.toLowerCase().includes(lower);
  });

  const columns = [
    {
      key: 'name',
      label: 'Role Name',
      className: 'font-bold w-[200px]',
      render: (name) => (
        <div className="flex items-center gap-2">
          <Shield className={`w-4 h-4 ${['super_admin'].includes(name) ? 'text-primary' : 'text-muted-foreground'}`} />
          {name === 'owner' && <Crown className="w-4 h-4 text-amber-500 fill-amber-500" />}
          <span>{name}</span>
          {name === 'owner' && <span className="bg-amber-500/10 text-amber-600 dark:text-amber-500 text-[10px] px-1.5 py-0.5 rounded-full uppercase font-bold border border-amber-500/20">Owner</span>}
          {name === 'super_admin' && <span className="bg-primary/10 text-primary text-[10px] px-1.5 py-0.5 rounded-full uppercase font-bold border border-primary/20">Tenant Root</span>}
        </div>
      )
    },
    { key: 'description', label: 'Description', className: 'text-muted-foreground' },
    {
      key: 'permissions_count',
      label: 'Permissions',
      className: 'text-center w-[120px]',
      render: (_, row) => {
        const count = row.role_permissions ? row.role_permissions[0]?.count : 0;
        if (['owner', 'super_admin'].includes(row.name)) {
          return <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-green-500/10 text-green-600 dark:text-green-400 border border-green-500/20">ALL ACCESS ({count || '∞'})</span>;
        }
        return <span className="inline-flex items-center px-2 py-0.5 rounded text-xs font-medium bg-secondary text-secondary-foreground">{count || 0} Permissions</span>;
      }
    },
    {
      key: 'owner',
      label: 'Created By',
      className: 'text-muted-foreground text-xs',
      render: (_, row) => row.owner?.email || '-'
    }
  ];

  if (isPlatformAdmin) {
    columns.push({
      key: 'tenant_id',
      label: 'Tenant Name',
      className: 'text-xs text-slate-500',
      render: (tid, row) => row.tenant?.name || (tid ? 'Unknown Tenant' : 'Global')
    });
  }

  // Header actions for PageHeader
  const headerActions = (
    <div className="flex gap-2">
      <Button variant="ghost" onClick={fetchRoles} title="Refresh" className="text-muted-foreground hover:text-foreground">
        <RefreshCw className="w-4 h-4" />
      </Button>
      {canCreate && (
        <Button onClick={() => { setSelectedRole(null); setShowEditor(true); }} className="bg-primary text-primary-foreground hover:bg-primary/90">
          <Plus className="w-4 h-4 mr-2" /> New Role
        </Button>
      )}
    </div>
  );

  // Breadcrumbs for PageHeader
  const breadcrumbs = [{ label: 'Roles & Permissions', icon: Shield }];

  if (!canView) return <div className="p-8 text-center text-slate-500">Access Denied</div>;

  return (
    <AdminPageLayout requiredPermission="tenant.role.read">
      {/* Delete Confirmation Dialog */}
      <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle className="flex items-center gap-2">
              <Trash2 className="w-5 h-5 text-red-500" />
              Delete Role
            </AlertDialogTitle>
            <AlertDialogDescription asChild>
              <div className="space-y-3">
                <p>
                  Are you sure you want to delete the role <strong>"{roleToDelete?.name}"</strong>?
                </p>
                <div className="bg-amber-50 border border-amber-200 rounded-lg p-3 text-amber-800 text-sm">
                  <p className="font-medium mb-1">⚠️ Before deleting:</p>
                  <p>Ensure no users are currently assigned to this role. Users with this role will lose access.</p>
                </div>
                <div className="bg-red-50 border border-red-200 rounded-lg p-3 text-red-700 text-sm">
                  <p className="font-medium">🚫 Warning:</p>
                  <p>This will move the role to trash. You can restore it if needed.</p>
                </div>
              </div>
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={handleConfirmDelete}
              className="bg-red-600 hover:bg-red-700"
            >
              Move to Trash
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {showEditor ? (
        <RoleEditor
          role={selectedRole}
          onClose={() => { setShowEditor(false); setSelectedRole(null); }}
          onSave={() => { setShowEditor(false); setSelectedRole(null); fetchRoles(); }}
        />
      ) : (
        <>
          <PageHeader
            title="Roles & Permissions"
            description="Manage access levels and configure granular permissions."
            icon={Shield}
            breadcrumbs={breadcrumbs}
            actions={headerActions}
          />

          <div className="bg-card rounded-xl border border-border shadow-sm overflow-hidden">
            <div className="p-4 border-b border-border bg-muted/20">
              <div className="max-w-sm">
                <MinCharSearchInput
                  value={query}
                  onChange={e => setQuery(e.target.value)}
                  onClear={clearSearch}
                  loading={loading || searchLoading}
                  isValid={isSearchValid}
                  message={searchMessage}
                  minLength={minLength}
                  placeholder="Search roles"
                />
              </div>
            </div>

            <ContentTable
              data={filteredRoles}
              columns={columns}
              loading={loading}
              onEdit={canEdit ? (role) => handleEdit(role) : null}
              onDelete={canDelete ? (role) => openDeleteDialog(role) : null}
            />
          </div>
        </>
      )}
    </AdminPageLayout>
  );
}

export default RolesManager;
