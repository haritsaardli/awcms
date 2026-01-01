
import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import GenericContentManager from '@/components/dashboard/GenericContentManager';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { FileText, FolderOpen, Tag, ChevronRight, Home, Layers } from 'lucide-react';

function ArticlesManager() {
  const [activeTab, setActiveTab] = useState('articles');

  // Article columns and fields
  const articleColumns = [
    { key: 'title', label: 'Title', className: 'font-medium' },
    {
      key: 'workflow_state',
      label: 'Workflow',
      render: (value) => {
        const colors = {
          published: 'bg-green-100 text-green-700 border-green-200',
          approved: 'bg-blue-100 text-blue-700 border-blue-200',
          reviewed: 'bg-yellow-100 text-yellow-700 border-yellow-200',
          draft: 'bg-slate-100 text-slate-700 border-slate-200'
        };
        return (
          <span className={`px-2 py-0.5 rounded-full text-xs font-medium border ${colors[value] || colors.draft} capitalize`}>
            {value}
          </span>
        );
      }
    },
    { key: 'status', label: 'Visibility', className: 'capitalize' },
    { key: 'published_at', label: 'Published', type: 'date' },
    { key: 'views', label: 'Views', type: 'number' }
  ];

  const articleFormFields = [
    { key: 'title', label: 'Title', required: true },
    { key: 'slug', label: 'Slug' },
    {
      key: 'status', label: 'Status', type: 'select', options: [
        { value: 'draft', label: 'Draft' },
        { value: 'published', label: 'Published' },
        { value: 'archived', label: 'Archived' }
      ]
    },
    { key: 'category_id', label: 'Category', type: 'resource_select', resourceTable: 'categories' },
    { key: 'excerpt', label: 'Excerpt', type: 'textarea' },
    { key: 'content', label: 'Content', type: 'richtext', description: 'Main article content with WYSIWYG editor' },
    { key: 'featured_image', label: 'Featured Image', type: 'image', description: 'Upload or select from Media Library' },
    { key: 'tags', label: 'Tags', type: 'tags' },
    { key: 'is_public', label: 'Publicly Visible', type: 'boolean' }
  ];

  // Category columns and fields
  const categoryColumns = [
    { key: 'name', label: 'Name', className: 'font-medium' },
    { key: 'slug', label: 'Slug' },
    { key: 'description', label: 'Description' },
    { key: 'created_at', label: 'Created', type: 'date' }
  ];

  const categoryFormFields = [
    { key: 'name', label: 'Name', required: true },
    { key: 'slug', label: 'Slug' },
    { key: 'description', label: 'Description', type: 'textarea' },
    {
      key: 'type', label: 'Type', type: 'select', options: [
        { value: 'article', label: 'Articles' },
        { value: 'product', label: 'Products' },
        { value: 'portfolio', label: 'Portfolio' }
      ], defaultValue: 'article'
    }
  ];

  // Tag columns and fields
  const tagColumns = [
    { key: 'name', label: 'Name', className: 'font-medium' },
    { key: 'slug', label: 'Slug' },
    { key: 'created_at', label: 'Created', type: 'date' }
  ];

  const tagFormFields = [
    { key: 'name', label: 'Name', required: true },
    { key: 'slug', label: 'Slug' }
  ];

  return (
    <div className="space-y-6">
      {/* Standard Breadcrumb */}
      <Breadcrumb className="mb-6">
        <BreadcrumbList>
          <BreadcrumbItem>
            <BreadcrumbLink asChild>
              <Link to="/cmspanel">Dashboard</Link>
            </BreadcrumbLink>
          </BreadcrumbItem>
          <BreadcrumbSeparator />
          <BreadcrumbItem>
            <BreadcrumbPage>Articles</BreadcrumbPage>
          </BreadcrumbItem>
          {activeTab !== 'articles' && (
            <>
              <BreadcrumbSeparator />
              <BreadcrumbItem>
                <BreadcrumbPage className="capitalize text-blue-600">{activeTab}</BreadcrumbPage>
              </BreadcrumbItem>
            </>
          )}
        </BreadcrumbList>
      </Breadcrumb>

      {/* Enhanced Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <div className="bg-white rounded-xl border border-slate-200 p-1.5 shadow-sm mb-6 inline-flex">
          <TabsList className="grid grid-cols-3 gap-1 bg-transparent p-0">
            <TabsTrigger
              value="articles"
              className="flex items-center gap-2 px-6 py-2.5 rounded-lg data-[state=active]:bg-gradient-to-r data-[state=active]:from-blue-600 data-[state=active]:to-blue-700 data-[state=active]:text-white data-[state=active]:shadow-md transition-all duration-200 font-medium"
            >
              <FileText className="w-4 h-4" />
              Articles
            </TabsTrigger>
            <TabsTrigger
              value="categories"
              className="flex items-center gap-2 px-6 py-2.5 rounded-lg data-[state=active]:bg-gradient-to-r data-[state=active]:from-purple-600 data-[state=active]:to-purple-700 data-[state=active]:text-white data-[state=active]:shadow-md transition-all duration-200 font-medium"
            >
              <FolderOpen className="w-4 h-4" />
              Categories
            </TabsTrigger>
            <TabsTrigger
              value="tags"
              className="flex items-center gap-2 px-6 py-2.5 rounded-lg data-[state=active]:bg-gradient-to-r data-[state=active]:from-emerald-600 data-[state=active]:to-emerald-700 data-[state=active]:text-white data-[state=active]:shadow-md transition-all duration-200 font-medium"
            >
              <Tag className="w-4 h-4" />
              Tags
            </TabsTrigger>
          </TabsList>
        </div>
      </Tabs>

      {/* Tab Content - Pure conditional rendering */}
      {activeTab === 'articles' && (
        <GenericContentManager
          tableName="articles"
          resourceName="Article"
          columns={articleColumns}
          formFields={articleFormFields}
          permissionPrefix="articles"
          showBreadcrumbs={false}
        />
      )}

      {activeTab === 'categories' && (
        <GenericContentManager
          tableName="categories"
          resourceName="Category"
          columns={categoryColumns}
          formFields={categoryFormFields}
          permissionPrefix="categories"
          showBreadcrumbs={false}
          customSelect="*, owner:users!created_by(email, full_name)"
          defaultFilters={{ type: 'article' }}
        />
      )}

      {activeTab === 'tags' && (
        <GenericContentManager
          tableName="tags"
          resourceName="Tag"
          columns={tagColumns}
          formFields={tagFormFields}
          permissionPrefix="tags"
          showBreadcrumbs={false}
        />
      )}
    </div>
  );
}

export default ArticlesManager;

