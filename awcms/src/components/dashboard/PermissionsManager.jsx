
import React, { useState, useEffect } from 'react';
import { Shield, Search, Plus, Trash2, RotateCcw, Ban, X, Loader2 } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { useToast } from '@/components/ui/use-toast';
import { supabase } from '@/lib/customSupabaseClient';
import { usePermissions } from '@/contexts/PermissionContext';
import { useSearch } from '@/hooks/useSearch';
import ContentTable from '@/components/dashboard/ContentTable';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from "@/components/ui/dialog";
import { Label } from '@/components/ui/label';

function PermissionsManager() {
  const { toast } = useToast();
  const { hasPermission, userRole, loading: permsLoading } = usePermissions();

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

  const [permissions, setPermissions] = useState([]);
  const [filteredPermissions, setFilteredPermissions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [isEditorOpen, setIsEditorOpen] = useState(false);
  const [editingPermission, setEditingPermission] = useState(null);
  const [formData, setFormData] = useState({ name: '', description: '', resource: '', action: '' });

  const isSuperAdmin = ['super_admin', 'owner'].includes(userRole);

  useEffect(() => {
    if (!permsLoading) {
      if (isSuperAdmin) {
        fetchPermissions();
      } else {
        setLoading(false);
      }
    }
  }, [permsLoading, isSuperAdmin]);

  useEffect(() => {
    if (!debouncedQuery) {
      setFilteredPermissions(permissions);
    } else {
      const lower = debouncedQuery.toLowerCase();
      setFilteredPermissions(permissions.filter(p =>
        p.name.toLowerCase().includes(lower) ||
        (p.description && p.description.toLowerCase().includes(lower))
      ));
    }
  }, [debouncedQuery, permissions]);

  const fetchPermissions = async () => {
    try {
      setLoading(true);
      const { data, error } = await supabase
        .from('permissions')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setPermissions(data || []);
      setFilteredPermissions(data || []);
    } catch (error) {
      console.error('Fetch permissions error:', error);
      toast({
        variant: "destructive",
        title: "Error",
        description: "Failed to fetch permissions."
      });
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async (e) => {
    e.preventDefault();
    try {
      const payload = {
        name: formData.name,
        description: formData.description,
        resource: formData.resource,
        action: formData.action,
        updated_at: new Date().toISOString()
      };

      if (editingPermission) {
        const { error } = await supabase
          .from('permissions')
          .update(payload)
          .eq('id', editingPermission.id);
        if (error) throw error;
        toast({ title: "Success", description: "Permission updated" });
      } else {
        payload.created_at = new Date().toISOString();
        const { error } = await supabase
          .from('permissions')
          .insert([payload]);
        if (error) throw error;
        toast({ title: "Success", description: "Permission created" });
      }
      setIsEditorOpen(false);
      fetchPermissions();
    } catch (error) {
      toast({ variant: "destructive", title: "Error", description: error.message });
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm("Are you sure? This might break role access.")) return;
    try {
      const { error } = await supabase.from('permissions').delete().eq('id', id);
      if (error) throw error;
      toast({ title: "Success", description: "Permission deleted" });
      fetchPermissions();
    } catch (error) {
      toast({ variant: "destructive", title: "Error", description: error.message });
    }
  };

  const columns = [
    { key: 'name', label: 'Permission Name' },
    { key: 'resource', label: 'Resource' },
    { key: 'action', label: 'Action' },
    { key: 'description', label: 'Description' }
  ];

  if (!isSuperAdmin) {
    return <div className="p-8 text-center text-red-500">Access Restricted: Owner or Super Admin only.</div>;
  }

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-3xl font-bold text-slate-800">Permissions</h2>
          <p className="text-slate-600">Manage system permissions</p>
        </div>
        <Button onClick={() => {
          setEditingPermission(null);
          setFormData({ name: '', description: '', resource: '', action: '' });
          setIsEditorOpen(true);
        }} className="bg-slate-900 text-white">
          <Plus className="w-4 h-4 mr-2" /> New Permission
        </Button>
      </div>

      <div className="bg-white p-4 rounded-xl border border-slate-200 shadow-sm">
        <div className="relative">
          <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
          <Input
            placeholder={`Search permissions... (${minLength}+ chars)`}
            value={query}
            onChange={e => setQuery(e.target.value)}
            className={`pl-9 pr-24 ${!isSearchValid ? 'border-red-300 focus:ring-red-200' : ''}`}
          />
          <div className="absolute right-3 top-2.5 flex items-center gap-2">
            {(loading || searchLoading) && <Loader2 className="h-4 w-4 animate-spin text-slate-400" />}
            {query && (
              <button onClick={clearSearch} className="text-slate-400 hover:text-slate-600">
                <X className="h-4 w-4" />
              </button>
            )}
            <span className={`text-xs font-mono ${query.length > 0 && query.length < minLength ? 'text-red-500 font-bold' : 'text-slate-400'}`}>
              {query.length}/{minLength}
            </span>
          </div>
          {!isSearchValid && (
            <div className="absolute top-full left-0 mt-1 text-xs text-red-500 font-medium animate-in slide-in-from-top-1 px-1">
              {searchMessage}
            </div>
          )}
        </div>
      </div>

      <ContentTable
        data={filteredPermissions}
        columns={columns}
        loading={loading}
        onEdit={(perm) => {
          setEditingPermission(perm);
          setFormData(perm);
          setIsEditorOpen(true);
        }}
        onDelete={handleDelete}
      />

      <Dialog open={isEditorOpen} onOpenChange={setIsEditorOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>{editingPermission ? 'Edit Permission' : 'New Permission'}</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleSave} className="space-y-4">
            <div>
              <Label>Name (e.g. view_articles)</Label>
              <Input value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} required />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div>
                <Label>Resource</Label>
                <Input value={formData.resource} onChange={e => setFormData({ ...formData, resource: e.target.value })} required />
              </div>
              <div>
                <Label>Action</Label>
                <Input value={formData.action} onChange={e => setFormData({ ...formData, action: e.target.value })} required />
              </div>
            </div>
            <div>
              <Label>Description</Label>
              <Input value={formData.description} onChange={e => setFormData({ ...formData, description: e.target.value })} />
            </div>
            <DialogFooter>
              <Button type="submit">Save</Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  );
}

export default PermissionsManager;
