
import React from 'react';
import { Link } from 'react-router-dom';
import GenericContentManager from '@/components/dashboard/GenericContentManager';
import { Briefcase, ChevronRight, Home, Wrench } from 'lucide-react';

function ServicesManager() {
    const columns = [
        { key: 'title', label: 'Title' },
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
        { key: 'description', label: 'Description', type: 'richtext' },
        { key: 'icon', label: 'Icon Class (e.g., ti-ruler-pencil)', description: 'Use Themify icon class names' },
        { key: 'image', label: 'Service Image', type: 'image' },
        { key: 'link', label: 'Link URL' },
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
                    <Wrench className="w-4 h-4" />
                    Services
                </span>
            </nav>

            <GenericContentManager
                tableName="services"
                resourceName="Service"
                columns={columns}
                formFields={formFields}
                permissionPrefix="services" // Ensure this maps to valid permissions or use generic ones
                showBreadcrumbs={false}
                defaultSortColumn="order"
            />
        </div>
    );
}

export default ServicesManager;
