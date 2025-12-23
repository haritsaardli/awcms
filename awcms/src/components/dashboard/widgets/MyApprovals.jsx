import React, { useEffect, useState } from 'react';
import { CheckCircle, Clock, ArrowRight, FileText } from 'lucide-react';
import { supabase } from '@/lib/customSupabaseClient';
import { usePermissions } from '@/contexts/PermissionContext';
import { Link } from 'react-router-dom';
import { Button } from '@/components/ui/button';
import { formatDistanceToNow } from 'date-fns';

export function MyApprovals() {
    const { hasPermission } = usePermissions();
    const [approvals, setApprovals] = useState([]);
    const [loading, setLoading] = useState(true);

    const canApprove = hasPermission('tenant.post.publish'); // Simpler check for now

    useEffect(() => {
        if (canApprove) {
            fetchPendingApprovals();
        } else {
            setLoading(false);
        }
    }, [canApprove]);

    const fetchPendingApprovals = async () => {
        try {
            // Fetch posts in 'reviewed' state
            const { data: posts, error } = await supabase
                .from('articles') // Note: table is 'articles' not 'posts' in some schemas, checking ArticlesManager it uses 'articles'
                .select('id, title, updated_at, author:users!created_by(email)')
                .eq('workflow_state', 'reviewed')
                .limit(5);

            if (error) throw error;
            setApprovals(posts || []);
        } catch (err) {
            console.error('Error fetching approvals:', err);
        } finally {
            setLoading(false);
        }
    };

    if (!canApprove) return null;

    if (loading) return <div className="h-[200px] bg-slate-100 animate-pulse rounded-xl" />;

    return (
        <div className="bg-white rounded-xl border border-slate-200 shadow-sm p-6 h-full flex flex-col">
            <div className="flex items-center justify-between mb-4">
                <h3 className="font-bold text-slate-800 flex items-center gap-2">
                    <CheckCircle className="w-5 h-5 text-blue-600" />
                    Pending Approvals
                    {approvals.length > 0 && (
                        <span className="bg-blue-100 text-blue-700 text-xs px-2 py-0.5 rounded-full">
                            {approvals.length}
                        </span>
                    )}
                </h3>
            </div>

            <div className="flex-1 overflow-y-auto space-y-3">
                {approvals.length > 0 ? (
                    approvals.map(item => (
                        <div key={item.id} className="p-3 bg-slate-50 border border-slate-100 rounded-lg group hover:border-blue-200 transition-colors">
                            <div className="flex justify-between items-start mb-1">
                                <h4 className="font-medium text-slate-900 line-clamp-1">{item.title}</h4>
                                <span className="text-xs text-slate-400 whitespace-nowrap">
                                    {formatDistanceToNow(new Date(item.updated_at), { addSuffix: true })}
                                </span>
                            </div>
                            <div className="flex items-center justify-between mt-2">
                                <span className="text-xs text-slate-500 flex items-center gap-1">
                                    <FileText className="w-3 h-3" />
                                    by {item.author?.email || 'Unknown'}
                                </span>
                                <Button asChild size="sm" variant="ghost" className="h-6 text-xs text-blue-600 hover:text-blue-700 hover:bg-blue-50">
                                    <Link to={`/cmspanel/articles?edit=${item.id}`}>Review</Link>
                                </Button>
                            </div>
                        </div>
                    ))
                ) : (
                    <div className="flex flex-col items-center justify-center h-40 text-slate-400">
                        <CheckCircle className="w-8 h-8 mb-2 opacity-20" />
                        <p className="text-sm">No items waiting for review</p>
                    </div>
                )}
            </div>

            <div className="mt-4 pt-3 border-t border-slate-100">
                <Link to="/cmspanel/articles?status=reviewed" className="text-sm text-slate-500 hover:text-blue-600 flex items-center justify-center w-full">
                    View All Queue <ArrowRight className="w-4 h-4 ml-1" />
                </Link>
            </div>
        </div>
    );
}
