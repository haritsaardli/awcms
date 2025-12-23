
import React from 'react';
import GenericContentManager from '@/components/dashboard/GenericContentManager';

function PhotoGalleryManager() {
    const columns = [
        { key: 'title', label: 'Album Title' },
        {
            key: 'photos',
            label: 'Photos',
            render: (value) => (
                <span className="text-sm text-muted-foreground">
                    {Array.isArray(value) ? value.length : 0} photos
                </span>
            )
        },
        {
            key: 'status',
            label: 'Status',
            render: (value) => (
                <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${value === 'published' ? 'bg-green-100 text-green-700' :
                    value === 'draft' ? 'bg-amber-100 text-amber-700' :
                        'bg-slate-100 text-slate-600'
                    }`}>
                    {value || 'draft'}
                </span>
            )
        },
        {
            key: 'published_at',
            label: 'Publish Date',
            type: 'date', // ContentTable handles 'date' type for display
            render: (value) => value ? new Date(value).toLocaleDateString() : '-'
        }
    ];

    const formFields = [
        { key: 'title', label: 'Album Title', required: true },
        { key: 'slug', label: 'Slug', description: 'URL-friendly name (auto-generated if empty)' },
        { key: 'description', label: 'Description', type: 'richtext' },
        { key: 'cover_image', label: 'Cover Image', type: 'image', description: 'Main album thumbnail' },
        { key: 'photos', label: 'Photos', type: 'images', description: 'Add multiple photos to album', maxImages: 50 },
        { key: 'category_id', label: 'Category', type: 'relation', table: 'categories', filter: { type: 'photo_gallery' } },
        { key: 'published_at', label: 'Publish Date', type: 'datetime', description: 'Schedule for future release (optional)' },
        {
            key: 'status', label: 'Status', type: 'select', options: [
                { value: 'draft', label: 'Draft' },
                { value: 'published', label: 'Published' }
            ]
        }
    ];

    return <GenericContentManager tableName="photo_gallery" resourceName="Photo Album" columns={columns} formFields={formFields} permissionPrefix="photo_gallery" />;
}
export default PhotoGalleryManager;
