
import React from 'react';
import { Link } from 'react-router-dom';
import GenericContentManager from '@/components/dashboard/GenericContentManager';
import { Users, ChevronRight, Home } from 'lucide-react';

function TeamManager() {
    const columns = [
        {
            key: 'image',
            label: 'Photo',
            render: (value) => value ? <img src={value} alt="Team" className="w-8 h-8 rounded-full object-cover" /> : <div className="w-8 h-8 rounded-full bg-slate-200"></div>
        },
        { key: 'name', label: 'Name' },
        { key: 'role', label: 'Role' },
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
        { key: 'name', label: 'Full Name', required: true },
        { key: 'role', label: 'Job Role/Position', required: true },
        { key: 'image', label: 'Profile Photo', type: 'image' },
        {
            key: 'social_links',
            label: 'Social Links',
            type: 'json',
            description: 'Array of objects: [{"icon": "ti-facebook", "link": "https://..."}]',
            defaultValue: '[]'
        },
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
                    <Users className="w-4 h-4" />
                    Team
                </span>
            </nav>

            <GenericContentManager
                tableName="teams"
                resourceName="Team Member"
                columns={columns}
                formFields={formFields}
                permissionPrefix="teams"
                showBreadcrumbs={false}
                defaultSortColumn="order"
            />
        </div>
    );
}

export default TeamManager;
