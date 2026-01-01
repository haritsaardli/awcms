import React, { useState, useEffect } from 'react';
import { useRegions } from '../../hooks/useRegions';
import { usePermissions } from '@/contexts/PermissionContext';
import { Button } from '@/components/ui/button';
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from '@/components/ui/table';
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogTrigger,
} from '@/components/ui/dialog';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Breadcrumb, BreadcrumbItem, BreadcrumbLink, BreadcrumbList, BreadcrumbSeparator } from '@/components/ui/breadcrumb';
import { ShieldAlert, FolderTree, ChevronRight, Edit, Trash2, Plus } from 'lucide-react';

/**
 * RegionsManager
 * Manages administrative regions hierarchy
 */
const RegionsManager = () => {
    const { getRegions, createRegion, updateRegion, deleteRegion, loading } = useRegions();
    const { hasPermission } = usePermissions();

    // State
    const [currentParent, setCurrentParent] = useState(null);
    const [ancestors, setAncestors] = useState([]);
    const [regions, setRegions] = useState([]);
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [editingRegion, setEditingRegion] = useState(null);

    const canRead = hasPermission('tenant.region.read');
    const canCreate = hasPermission('tenant.region.create');
    const canUpdate = hasPermission('tenant.region.update');
    const canDelete = hasPermission('tenant.region.delete');

    // Data Fetching
    useEffect(() => {
        if (canRead) {
            loadRegions();
        }
    }, [currentParent, canRead]);

    const loadRegions = async () => {
        const data = await getRegions({ parentId: currentParent?.id || null });
        setRegions(data || []);
    };

    // Navigation
    const handleNavigateDown = (region) => {
        setAncestors([...ancestors, region]);
        setCurrentParent(region);
    };

    const handleNavigateUp = (index) => {
        if (index === -1) {
            setAncestors([]);
            setCurrentParent(null);
        } else {
            const newAncestors = ancestors.slice(0, index + 1);
            setAncestors(newAncestors);
            setCurrentParent(newAncestors[newAncestors.length - 1]);
        }
    };

    // CRUD Handlers (Placeholder for now as logic was incomplete in original)
    const handleSave = async (e) => {
        e.preventDefault();
        // Implement save logic later
        setIsModalOpen(false);
    };

    if (!canRead) {
        return (
            <div className="flex flex-col items-center justify-center min-h-[400px] bg-white rounded-xl border border-slate-200 p-12 text-center">
                <div className="p-4 bg-red-50 rounded-full mb-4">
                    <ShieldAlert className="w-12 h-12 text-red-500" />
                </div>
                <h3 className="text-xl font-bold text-slate-800">Access Denied</h3>
                <p className="text-slate-500 mt-2">You do not have permission to manage regions.</p>
            </div>
        );
    }

    return (
        <div className="p-8 space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-2xl font-bold flex items-center gap-2">
                        <FolderTree className="w-6 h-6" />
                        Administrative Regions
                    </h1>
                    <p className="text-slate-500">Manage hierarchical regions</p>
                </div>
                {canCreate && (
                    <Button onClick={() => { setEditingRegion(null); setIsModalOpen(true); }}>
                        <Plus className="w-4 h-4 mr-2" /> Add Region
                    </Button>
                )}
            </div>

            {/* Breadcrumbs */}
            <div className="bg-slate-50 p-2 rounded-md border">
                <Breadcrumb>
                    <BreadcrumbList>
                        <BreadcrumbItem>
                            <BreadcrumbLink onClick={() => handleNavigateUp(-1)} className="cursor-pointer font-medium hover:text-blue-600">
                                Root
                            </BreadcrumbLink>
                        </BreadcrumbItem>
                        {ancestors.map((region, idx) => (
                            <React.Fragment key={region.id}>
                                <BreadcrumbSeparator><ChevronRight className="w-4 h-4" /></BreadcrumbSeparator>
                                <BreadcrumbItem>
                                    <BreadcrumbLink onClick={() => handleNavigateUp(idx)} className="cursor-pointer font-medium hover:text-blue-600">
                                        {region.name}
                                    </BreadcrumbLink>
                                </BreadcrumbItem>
                            </React.Fragment>
                        ))}
                    </BreadcrumbList>
                </Breadcrumb>
            </div>

            {/* Table */}
            <div className="border rounded-lg bg-white overflow-hidden shadow-sm">
                <Table>
                    <TableHeader>
                        <TableRow className="bg-slate-50">
                            <TableHead>Code</TableHead>
                            <TableHead>Name</TableHead>
                            <TableHead>Level</TableHead>
                            <TableHead className="text-right">Actions</TableHead>
                        </TableRow>
                    </TableHeader>
                    <TableBody>
                        {regions.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={4} className="text-center py-8 text-slate-500">
                                    No regions found at this level.
                                </TableCell>
                            </TableRow>
                        ) : (
                            regions.map(region => (
                                <TableRow key={region.id}>
                                    <TableCell className="font-mono text-xs">{region.code || '-'}</TableCell>
                                    <TableCell>
                                        <div
                                            className="font-medium cursor-pointer text-blue-600 hover:underline flex items-center gap-2"
                                            onClick={() => handleNavigateDown(region)}
                                        >
                                            <FolderTree className="w-4 h-4 text-slate-400" />
                                            {region.name}
                                        </div>
                                    </TableCell>
                                    <TableCell>
                                        <span className="inline-flex items-center px-2 py-1 rounded text-xs font-medium bg-slate-100 text-slate-800">
                                            {region.level?.name || 'Unknown'}
                                        </span>
                                    </TableCell>
                                    <TableCell className="text-right space-x-2">
                                        {canUpdate && (
                                            <Button variant="ghost" size="sm" onClick={() => { setEditingRegion(region); setIsModalOpen(true); }}>
                                                <Edit className="w-4 h-4" />
                                            </Button>
                                        )}
                                        {canDelete && (
                                            <Button variant="ghost" size="sm" className="text-red-500 hover:text-red-600" onClick={() => deleteRegion(region.id)}>
                                                <Trash2 className="w-4 h-4" />
                                            </Button>
                                        )}
                                    </TableCell>
                                </TableRow>
                            ))
                        )}
                    </TableBody>
                </Table>
            </div>

            {/* Modal */}
            <Dialog open={isModalOpen} onOpenChange={setIsModalOpen}>
                <DialogContent>
                    <DialogHeader>
                        <DialogTitle>{editingRegion ? 'Edit' : 'Add'} Region</DialogTitle>
                    </DialogHeader>
                    <div className="py-4">
                        <p className="text-sm text-slate-500 mb-4">
                            Parent: <strong>{currentParent ? currentParent.name : 'Root'}</strong>
                        </p>
                        <div className="space-y-4">
                            <div className="space-y-2">
                                <Label htmlFor="name">Region Name</Label>
                                <Input id="name" placeholder="e.g. Jawa Tengah" />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="code">Region Code</Label>
                                <Input id="code" placeholder="e.g. 33" />
                            </div>
                        </div>
                    </div>
                </DialogContent>
            </Dialog>
        </div>
    );
};

export default RegionsManager;
