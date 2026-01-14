
import React from 'react';
import { Link } from 'react-router-dom';
import GenericContentManager from '@/components/dashboard/GenericContentManager';
import { Trophy, ChevronRight, Home } from 'lucide-react';

function FunFactsManager() {
    const columns = [
        { key: 'title', label: 'Title' },
        { key: 'count', label: 'Count' },
        {
            key: 'icon',
            label: 'Icon',
            render: (value) => value ? <i className={value}></i> : '-'
        },
        { key: 'order', label: 'Order', type: 'number' },
        {
            key: 'status',
            label: 'Status',
            render: (value) => (
                <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${value === 'published' ? 'bg-green-100 text-green-700 dark:bg-green-900/30 dark:text-green-400' :
                    value === 'draft' ? 'bg-amber-100 text-amber-700 dark:bg-amber-900/30 dark:text-amber-400' :
                        'bg-muted text-muted-foreground'
                    }`}>
                    {value || 'draft'}
                </span>
            )
        }
    ];

    const formFields = [
        { key: 'title', label: 'Title', required: true },
        { key: 'count', label: 'Count Display (e.g. 500+)', required: true },
        { key: 'icon', label: 'Icon Class (e.g. ti-user)', description: 'Themify icon class' },
        { key: 'order', label: 'Sort Order', type: 'number', defaultValue: 0 },
        {
            key: 'status',
            label: 'Status',
            type: 'select',
            options: [
                { value: 'draft', label: 'Draft' },
                { value: 'published', label: 'Published' },
                { value: 'archived', label: 'Archived' }
            ]
        }
    ];

    return (
        <div className="space-y-6">
            <nav className="flex items-center text-sm text-muted-foreground">
                <Link to="/cmspanel" className="hover:text-primary transition-colors flex items-center gap-1">
                    <Home className="w-4 h-4" />
                    Dashboard
                </Link>
                <ChevronRight className="w-4 h-4 mx-2 text-muted-foreground/50" />
                <span className="flex items-center gap-1 text-foreground font-medium">
                    <Trophy className="w-4 h-4" />
                    Fun Facts
                </span>
            </nav>

            <GenericContentManager
                tableName="funfacts"
                resourceName="Fun Fact"
                columns={columns}
                formFields={formFields}
                permissionPrefix="funfacts"
                showBreadcrumbs={false}
                defaultSortColumn="order"
            />
        </div>
    );
}

export default FunFactsManager;
