
import React from 'react';
import GenericContentManager from '@/components/dashboard/GenericContentManager';

function PromotionsManager() {
    const columns = [
        { key: 'title', label: 'Promotion' },
        { key: 'code', label: 'Promo Code' },
        {
            key: 'link',
            label: 'Link',
            render: (value) => value ? <a href={value} target="_blank" rel="noopener noreferrer" className="text-blue-600 hover:underline truncate max-w-[150px] block">{value}</a> : '-'
        },
        {
            key: 'status',
            label: 'Status',
            render: (value) => (
                <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${value === 'active' ? 'bg-green-100 text-green-700' :
                    value === 'inactive' ? 'bg-slate-100 text-slate-600' :
                        value === 'expired' ? 'bg-red-100 text-red-600' :
                            'bg-slate-100 text-slate-600'
                    }`}>
                    {value || 'inactive'}
                </span>
            )
        }
    ];

    const formFields = [
        { key: 'title', label: 'Title', required: true },
        { key: 'code', label: 'Promo Code', description: 'e.g. WINTER50, SALE2025' },
        { key: 'featured_image', label: 'Banner Image', type: 'image' },
        { key: 'description', label: 'Description', type: 'richtext' },
        { key: 'link', label: 'Redirect URL', type: 'url', description: 'Where to send the user when clicked (https://...)' },
        { key: 'cta_text', label: 'Button Text', description: 'e.g. Shop Now, Learn More' },
        {
            key: 'target',
            label: 'Open In',
            type: 'select',
            options: [{ value: '_self', label: 'Same Tab' }, { value: '_blank', label: 'New Tab' }],
            defaultValue: '_self'
        },
        { key: 'category_id', label: 'Category', type: 'relation', table: 'categories', filter: { type: 'promotion' } },
        { key: 'discount_percentage', label: 'Discount %', type: 'number', description: 'Leave empty if using fixed amount' },
        { key: 'discount_amount', label: 'Discount Amount', type: 'number', description: 'Fixed discount value' },
        { key: 'start_date', label: 'Start Date', type: 'datetime' },
        { key: 'end_date', label: 'End Date', type: 'datetime' },
        {
            key: 'status', label: 'Status', type: 'select', options: [
                { value: 'inactive', label: 'Inactive' },
                { value: 'active', label: 'Active' },
                { value: 'expired', label: 'Expired' }
            ]
        }
    ];

    return <GenericContentManager tableName="promotions" resourceName="Promotion" columns={columns} formFields={formFields} permissionPrefix="promotions" />;
}
export default PromotionsManager;
