import React from 'react';
import { Link } from 'react-router-dom';
import GenericContentManager from '@/components/dashboard/GenericContentManager';
import { Settings, ChevronRight, Home } from 'lucide-react';

function SettingsManager() {
    const columns = [
        { key: 'key', label: 'Setting Key', className: 'font-mono font-medium' },
        { key: 'value', label: 'Value', className: 'truncate max-w-[200px]' },
        { key: 'description', label: 'Description', className: 'text-muted-foreground text-xs' }
    ];

    const formFields = [
        { key: 'key', label: 'Key', required: true, description: 'Unique identifier (e.g., site_name, maintenance_mode)' },
        { key: 'value', label: 'Value', type: 'textarea', required: true, description: 'The value for this setting' },
        { key: 'description', label: 'Description', type: 'textarea', description: 'What this setting controls' },
        {
            key: 'type',
            label: 'Type',
            type: 'select',
            options: [
                { value: 'string', label: 'String' },
                { value: 'boolean', label: 'Boolean (true/false)' },
                { value: 'number', label: 'Number' },
                { value: 'json', label: 'JSON' }
            ]
        }
    ];

    return (
        <div className="space-y-6">
            {/* Breadcrumb Navigation */}
            <nav className="flex items-center text-sm text-muted-foreground">
                <Link to="/cmspanel" className="hover:text-foreground transition-colors flex items-center gap-1">
                    <Home className="w-4 h-4" />
                    Dashboard
                </Link>
                <ChevronRight className="w-4 h-4 mx-2 text-muted" />
                <span className="flex items-center gap-1 text-foreground font-medium">
                    <Settings className="w-4 h-4" />
                    Settings
                </span>
            </nav>

            <GenericContentManager
                tableName="settings"
                resourceName="Setting"
                columns={columns}
                formFields={formFields}
                permissionPrefix="setting"
                viewPermission="tenant.setting.read"
                createPermission="tenant.setting.create"
                customSelect="*"
                enableSoftDelete={false}
                defaultSortColumn="key"
                showBreadcrumbs={false}
            />
        </div>
    );
}

export default SettingsManager;
