import React from 'react';
import GenericContentManager from '@/components/dashboard/GenericContentManager';

function SettingsManager() {
    const columns = [
        { key: 'key', label: 'Setting Key', className: 'font-mono font-medium' },
        { key: 'value', label: 'Value', className: 'truncate max-w-[200px]' },
        { key: 'description', label: 'Description', className: 'text-slate-500 text-xs' }
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
        <GenericContentManager
            tableName="settings"
            resourceName="Setting"
            columns={columns}
            formFields={formFields}
            permissionPrefix="setting"
            viewPermission="tenant.setting.read"
            createPermission="tenant.setting.create"
        // Settings are critical, maybe restrict create/delete?
        // For now, allow full CRUD as it's an admin tool.
        />
    );
}

export default SettingsManager;
