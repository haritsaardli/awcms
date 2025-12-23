import React, { useState, useEffect } from 'react';
import { usePermissions } from '@/contexts/PermissionContext';
import { supabase } from '@/lib/customSupabaseClient';
import { format } from 'date-fns';
import { Search, Eye, Smartphone, Globe, Server, RefreshCw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Helmet } from 'react-helmet';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';

function AuditLogsManager() {
    const { tenantId, userRole, hasPermission } = usePermissions();
    const [logs, setLogs] = useState([]);
    const [loading, setLoading] = useState(false);
    const [searchQuery, setSearchQuery] = useState('');
    const [selectedLog, setSelectedLog] = useState(null);

    // Pagination
    const [page, setPage] = useState(1);
    const [limit, setLimit] = useState(50);
    const [totalCount, setTotalCount] = useState(0);

    const canView = hasPermission('tenant.audit.read') || ['super_admin', 'owner'].includes(userRole);

    const fetchLogs = async () => {
        if (!canView) return;

        setLoading(true);
        try {
            const from = (page - 1) * limit;
            const to = from + limit - 1;

            let query = supabase
                .from('audit_logs')
                .select('*, user:users(email, full_name)', { count: 'exact' })
                .order('created_at', { ascending: false })
                .range(from, to);

            if (searchQuery) {
                query = query.or(`action.ilike.%${searchQuery}%,resource.ilike.%${searchQuery}%`);
            }

            const { data, count, error } = await query;

            if (error) throw error;

            setLogs(data || []);
            setTotalCount(count || 0);
        } catch (err) {
            console.error('Error fetching audit logs:', err);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        if (canView && (tenantId || userRole === 'owner')) {
            fetchLogs();
        }
    }, [tenantId, userRole, page, limit, searchQuery, canView]);

    const getChannelIcon = (channel) => {
        switch (channel) {
            case 'mobile': return <Smartphone className="w-3 h-3" />;
            case 'api': return <Server className="w-3 h-3" />;
            default: return <Globe className="w-3 h-3" />;
        }
    };

    const getActionBadge = (action) => {
        const colors = {
            create: 'bg-green-100 text-green-800 border-green-200',
            update: 'bg-blue-100 text-blue-800 border-blue-200',
            delete: 'bg-red-100 text-red-800 border-red-200',
            publish: 'bg-purple-100 text-purple-800 border-purple-200',
            login: 'bg-cyan-100 text-cyan-800 border-cyan-200'
        };

        const type = action?.split('.')[1] || action;
        const colorClass = colors[type] || 'bg-slate-100 text-slate-800 border-slate-200';

        return (
            <Badge variant="outline" className={`${colorClass} font-mono text-[10px] uppercase`}>
                {action}
            </Badge>
        );
    };

    if (!canView) {
        return (
            <div className="p-8 text-center">
                <p className="text-slate-500">You don't have permission to view audit logs.</p>
            </div>
        );
    }

    return (
        <div className="space-y-6">
            <Helmet>
                <title>Audit Logs - CMS</title>
            </Helmet>

            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                    <h1 className="text-2xl font-bold tracking-tight text-slate-900">Audit Trail</h1>
                    <p className="text-slate-500">Enterprise-grade activity logging and compliance trail.</p>
                </div>
                <Button variant="outline" onClick={fetchLogs} disabled={loading}>
                    <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
                    Refresh
                </Button>
            </div>

            <div className="bg-white rounded-lg border shadow-sm p-4 flex items-center gap-4">
                <div className="relative flex-1 max-w-md">
                    <Search className="absolute left-3 top-2.5 h-4 w-4 text-slate-400" />
                    <Input
                        placeholder="Search action or resource..."
                        className="pl-9"
                        value={searchQuery}
                        onChange={(e) => setSearchQuery(e.target.value)}
                    />
                </div>
            </div>

            <Card>
                <CardHeader>
                    <CardTitle>Activity History</CardTitle>
                    <CardDescription>
                        All system actions are logged with full audit trail for compliance.
                    </CardDescription>
                </CardHeader>
                <CardContent>
                    <div className="overflow-x-auto">
                        <table className="w-full text-sm">
                            <thead className="bg-slate-50 border-b">
                                <tr>
                                    <th className="px-4 py-3 text-left font-medium text-slate-600">Timestamp</th>
                                    <th className="px-4 py-3 text-left font-medium text-slate-600">User</th>
                                    <th className="px-4 py-3 text-left font-medium text-slate-600">Action</th>
                                    <th className="px-4 py-3 text-left font-medium text-slate-600">Resource</th>
                                    <th className="px-4 py-3 text-left font-medium text-slate-600">Changes</th>
                                    <th className="px-4 py-3 text-center font-medium text-slate-600">Channel</th>
                                </tr>
                            </thead>
                            <tbody className="divide-y">
                                {loading ? (
                                    <tr>
                                        <td colSpan="6" className="p-8 text-center text-slate-400">
                                            Loading audit trail...
                                        </td>
                                    </tr>
                                ) : logs.length === 0 ? (
                                    <tr>
                                        <td colSpan="6" className="p-8 text-center text-slate-400">
                                            No logs found.
                                        </td>
                                    </tr>
                                ) : (
                                    logs.map((log) => (
                                        <tr key={log.id} className="hover:bg-slate-50/50 transition-colors">
                                            <td className="px-4 py-3 text-slate-600 whitespace-nowrap">
                                                {format(new Date(log.created_at), 'MMM dd, yyyy HH:mm:ss')}
                                            </td>
                                            <td className="px-4 py-3">
                                                <div className="font-medium text-slate-900">
                                                    {log.user?.full_name || 'Unknown'}
                                                </div>
                                                <div className="text-xs text-slate-500">{log.user?.email}</div>
                                            </td>
                                            <td className="px-4 py-3">{getActionBadge(log.action)}</td>
                                            <td className="px-4 py-3 text-slate-600">
                                                <div className="font-medium">{log.resource}</div>
                                                {log.resource_id && (
                                                    <div className="text-xs text-slate-400">#{log.resource_id}</div>
                                                )}
                                            </td>
                                            <td className="px-4 py-3">
                                                {log.old_value || log.new_value ? (
                                                    <Button
                                                        variant="ghost"
                                                        size="sm"
                                                        onClick={() => setSelectedLog(log)}
                                                        className="h-7 px-2 text-xs text-blue-600 hover:text-blue-800"
                                                    >
                                                        <Eye className="w-3 h-3 mr-1" /> View Diff
                                                    </Button>
                                                ) : (
                                                    <span className="text-slate-400 text-xs italic">No modifications</span>
                                                )}
                                            </td>
                                            <td className="px-4 py-3">
                                                <div
                                                    className="flex items-center justify-center gap-1 text-slate-500 text-xs uppercase font-semibold"
                                                    title={log.user_agent}
                                                >
                                                    {getChannelIcon(log.channel)}
                                                    <span>{log.channel || 'web'}</span>
                                                </div>
                                            </td>
                                        </tr>
                                    ))
                                )}
                            </tbody>
                        </table>
                    </div>

                    {/* Pagination */}
                    {totalCount > 0 && (
                        <div className="flex flex-col sm:flex-row justify-between items-center gap-4 mt-4 pt-4 border-t">
                            <div className="text-sm text-slate-600">
                                Showing {(page - 1) * limit + 1} to {Math.min(page * limit, totalCount)} of {totalCount} logs
                            </div>
                            <div className="flex items-center gap-4">
                                <select
                                    value={limit}
                                    onChange={(e) => {
                                        setLimit(Number(e.target.value));
                                        setPage(1);
                                    }}
                                    className="border rounded px-3 py-1.5 text-sm"
                                >
                                    <option value={25}>25 per page</option>
                                    <option value={50}>50 per page</option>
                                    <option value={100}>100 per page</option>
                                </select>
                                <div className="flex gap-1">
                                    <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={() => setPage(p => Math.max(1, p - 1))}
                                        disabled={page === 1}
                                    >
                                        Previous
                                    </Button>
                                    <Button
                                        variant="outline"
                                        size="sm"
                                        onClick={() => setPage(p => p + 1)}
                                        disabled={page * limit >= totalCount}
                                    >
                                        Next
                                    </Button>
                                </div>
                            </div>
                        </div>
                    )}
                </CardContent>
            </Card>

            {/* Diff Viewer Dialog */}
            <Dialog open={!!selectedLog} onOpenChange={() => setSelectedLog(null)}>
                <DialogContent className="max-w-3xl max-h-[80vh] overflow-hidden flex flex-col">
                    <DialogHeader>
                        <DialogTitle>Change Details</DialogTitle>
                    </DialogHeader>
                    <div className="overflow-y-auto space-y-4 p-1">
                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <h4 className="text-xs font-bold text-red-600 uppercase tracking-wider">
                                    Old Value
                                </h4>
                                <pre className="bg-red-50 border border-red-200 p-3 rounded text-xs overflow-x-auto text-red-900 min-h-[150px]">
                                    {selectedLog?.old_value
                                        ? JSON.stringify(JSON.parse(selectedLog.old_value), null, 2)
                                        : 'null'}
                                </pre>
                            </div>
                            <div className="space-y-2">
                                <h4 className="text-xs font-bold text-green-600 uppercase tracking-wider">
                                    New Value
                                </h4>
                                <pre className="bg-green-50 border border-green-200 p-3 rounded text-xs overflow-x-auto text-green-900 min-h-[150px]">
                                    {selectedLog?.new_value
                                        ? JSON.stringify(JSON.parse(selectedLog.new_value), null, 2)
                                        : 'null'}
                                </pre>
                            </div>
                        </div>
                        <div className="pt-4 border-t space-y-2 text-sm">
                            <div className="flex justify-between">
                                <span className="text-slate-500">Action:</span>
                                <span className="font-medium">{selectedLog?.action}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-slate-500">Resource:</span>
                                <span className="font-medium">{selectedLog?.resource}</span>
                            </div>
                            <div className="flex justify-between">
                                <span className="text-slate-500">IP Address:</span>
                                <span className="font-mono text-xs">{selectedLog?.ip_address || 'N/A'}</span>
                            </div>
                        </div>
                    </div>
                </DialogContent>
            </Dialog>
        </div>
    );
}

export default AuditLogsManager;
