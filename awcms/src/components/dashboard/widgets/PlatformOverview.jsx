import React from 'react';
import { usePlatformStats } from '@/hooks/usePlatformStats';
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Building2, Users, Database, ShieldCheck, TrendingUp } from 'lucide-react';
import { format } from 'date-fns';
import { Badge } from '@/components/ui/badge';

export function PlatformOverview() {
    const { stats, loading } = usePlatformStats();

    if (loading) {
        return <div className="animate-pulse h-48 bg-slate-100 rounded-xl mb-8"></div>;
    }

    const formatBytes = (bytes) => {
        if (bytes === 0) return '0 B';
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    };

    return (
        <div className="space-y-6 mb-8">
            <div className="flex items-center gap-2 mb-4">
                <ShieldCheck className="w-6 h-6 text-indigo-600" />
                <h2 className="text-xl font-bold text-slate-900">Platform Overview</h2>
            </div>

            {/* Top Stats */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">Total Tenants</CardTitle>
                        <Building2 className="h-4 w-4 text-slate-500" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{stats.totalTenants}</div>
                        <p className="text-xs text-slate-500">
                            {stats.tenantsByTier.pro} Pro, {stats.tenantsByTier.enterprise} Enterprise
                        </p>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">System Users</CardTitle>
                        <Users className="h-4 w-4 text-slate-500" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{stats.totalUsers}</div>
                        <p className="text-xs text-slate-500">Across all tenants</p>
                    </CardContent>
                </Card>
                <Card>
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium">System Storage</CardTitle>
                        <Database className="h-4 w-4 text-slate-500" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold">{formatBytes(stats.totalStorage)}</div>
                        <p className="text-xs text-slate-500">Total assets stored</p>
                    </CardContent>
                </Card>
                <Card className="bg-gradient-to-br from-indigo-50 to-white border-indigo-100">
                    <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                        <CardTitle className="text-sm font-medium text-indigo-900">Platform Health</CardTitle>
                        <TrendingUp className="h-4 w-4 text-indigo-600" />
                    </CardHeader>
                    <CardContent>
                        <div className="text-2xl font-bold text-indigo-700">100%</div>
                        <p className="text-xs text-indigo-600">All services operational</p>
                    </CardContent>
                </Card>
            </div>

            {/* Recent Tenants Table */}
            <Card>
                <CardHeader>
                    <CardTitle className="text-base">Recent Tenants</CardTitle>
                </CardHeader>
                <CardContent>
                    <div className="space-y-4">
                        {stats.recentTenants.map(tenant => (
                            <div key={tenant.id} className="flex items-center justify-between border-b border-slate-100 last:border-0 pb-3 last:pb-0">
                                <div className="flex items-center gap-3">
                                    <div className="w-8 h-8 rounded-full bg-slate-100 flex items-center justify-center">
                                        <Building2 className="w-4 h-4 text-slate-600" />
                                    </div>
                                    <div>
                                        <p className="font-medium text-sm text-slate-900">{tenant.name}</p>
                                        <p className="text-xs text-slate-500">Created {format(new Date(tenant.created_at), 'MMM d, yyyy')}</p>
                                    </div>
                                </div>
                                <div className="flex items-center gap-2">
                                    <Badge variant={tenant.subscription_tier === 'free' ? 'secondary' : 'default'} className="uppercase text-[10px]">
                                        {tenant.subscription_tier}
                                    </Badge>
                                </div>
                            </div>
                        ))}
                    </div>
                </CardContent>
            </Card>
        </div>
    );
}
