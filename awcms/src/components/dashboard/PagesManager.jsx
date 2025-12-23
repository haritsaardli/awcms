
import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import GenericContentManager from '@/components/dashboard/GenericContentManager';
import VisualPageBuilder from '@/components/visual-builder/VisualPageBuilder';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { FileText, FolderOpen, ChevronRight, Home, Layers, Paintbrush, Edit } from 'lucide-react';
import { Button } from '@/components/ui/button';

function PagesManager({ onlyVisual = false }) {
  const [activeTab, setActiveTab] = useState('pages');
  const [visualBuilderPage, setVisualBuilderPage] = useState(null);

  // Tab labels for breadcrumb
  const tabLabels = {
    pages: onlyVisual ? 'Visual Pages' : 'Pages',
    categories: 'Categories'
  };

  // Page columns with editor type indicator
  const pageColumns = [
    { key: 'title', label: 'Page Title', className: 'font-medium' },
    { key: 'slug', label: 'Path' },
    {
      key: 'page_type',
      label: 'Type',
      render: (value) => {
        const colors = {
          homepage: 'bg-blue-100 text-blue-700',
          header: 'bg-emerald-100 text-emerald-700',
          footer: 'bg-emerald-100 text-emerald-700',
          single_page: 'bg-purple-100 text-purple-700',
          single_post: 'bg-pink-100 text-pink-700',
          '404': 'bg-red-100 text-red-700',
          regular: 'bg-slate-100 text-slate-600'
        };
        const labels = {
          homepage: 'Home',
          header: 'Header',
          footer: 'Footer',
          single_page: 'Page Tpl',
          single_post: 'Post Tpl',
          '404': '404',
          regular: 'Page'
        };
        return (
          <span className={`px-2 py-1 text-xs rounded-full font-medium ${colors[value] || colors.regular}`}>
            {labels[value] || value || 'Page'}
          </span>
        );
      }
    },
    {
      key: 'editor_type',
      label: 'Editor',
      render: (value) => (
        <span className={`px-2 py-1 text-xs rounded-full ${value === 'visual'
          ? 'bg-purple-100 text-purple-700'
          : 'bg-slate-100 text-slate-600'
          }`}>
          {value === 'visual' ? '🎨 Visual' : '📝 Rich Text'}
        </span>
      )
    },
    { key: 'status', label: 'Status' },
    { key: 'published_at', label: 'Published', type: 'date' },
    { key: 'updated_at', label: 'Updated', type: 'date' }
  ];

  const pageFormFields = [
    { key: 'title', label: 'Title', required: true },
    {
      key: 'page_type',
      label: 'Page Type',
      type: 'select',
      options: [
        { value: 'regular', label: 'Regular Page' },
        { value: 'homepage', label: 'Homepage' },
        { value: 'header', label: 'Global Header' },
        { value: 'footer', label: 'Global Footer' },
        { value: 'single_page', label: 'Single Page Template' },
        { value: 'single_post', label: 'Single Post Template' },
        { value: '404', label: '404 Error Page' },
        { value: 'archive', label: 'Archive Template' }
      ],
      defaultValue: 'regular',
      description: 'System page type (Homepage, Header, etc.)'
    },
    { key: 'slug', label: 'URL Slug', required: true },
    {
      key: 'status', label: 'Status', type: 'select', options: [
        { value: 'published', label: 'Published' },
        { value: 'draft', label: 'Draft' }
      ]
    },
    {
      key: 'editor_type', label: 'Editor Type', type: 'select', options: [
        { value: 'richtext', label: '📝 Rich Text Editor' },
        { value: 'visual', label: '🎨 Visual Page Builder' }
      ],
      defaultValue: onlyVisual ? 'visual' : 'richtext',
      description: 'Choose the editor type for this page',
      // If ONLY visual, maybe hide this or disable it? 
      // User might still want to switch, but default is visual.
    },
    { key: 'category_id', label: 'Category', type: 'resource_select', resourceTable: 'categories' },
    {
      key: 'content',
      label: 'Content',
      type: 'richtext',
      description: 'Page content (for Rich Text editor)',
      conditionalShow: (formData) => formData.editor_type !== 'visual'
    },
    { key: 'excerpt', label: 'Excerpt', type: 'textarea' },
    { key: 'featured_image', label: 'Featured Image', type: 'image' },
    { key: 'meta_description', label: 'SEO Description', type: 'textarea' },
    { key: 'is_active', label: 'Active', type: 'boolean' }
  ];

  // Custom row actions for Visual Builder
  const customRowActions = (page) => {
    if (page.editor_type === 'visual') {
      return (
        <Button
          size="sm"
          onClick={(e) => {
            e.stopPropagation();
            setVisualBuilderPage(page);
          }}
          className="h-8 px-3 bg-gradient-to-r from-purple-600 to-indigo-600 text-white hover:from-purple-700 hover:to-indigo-700 shadow-sm transition-all hover:shadow-md"
          title="Edit with Visual Builder"
        >
          <Paintbrush className="w-3.5 h-3.5 mr-1.5" />
          Edit Visual
        </Button>
      );
    }
    return null;
  };

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
        { value: 'page', label: 'Pages' },
        { value: 'article', label: 'Articles' },
        { value: 'product', label: 'Products' }
      ], defaultValue: 'page'
    }
  ];

  // If Visual Builder is open, show it full screen
  if (visualBuilderPage) {
    return (
      <VisualPageBuilder
        page={visualBuilderPage}
        onClose={() => setVisualBuilderPage(null)}
        onSuccess={() => setVisualBuilderPage(null)}
      />
    );
  }

  return (
    <div className="space-y-6">
      {/* Breadcrumb Navigation */}
      <nav className="flex items-center text-sm text-slate-500">
        <Link to="/cmspanel" className="hover:text-blue-600 transition-colors flex items-center gap-1">
          <Home className="w-4 h-4" />
          Dashboard
        </Link>
        <ChevronRight className="w-4 h-4 mx-2 text-slate-300" />
        <span className="flex items-center gap-1 text-slate-700 font-medium">
          <Layers className="w-4 h-4" />
          Pages
        </span>
        {activeTab !== 'pages' && (
          <>
            <ChevronRight className="w-4 h-4 mx-2 text-slate-300" />
            <span className="text-blue-600 font-medium capitalize">{tabLabels[activeTab]}</span>
          </>
        )}
      </nav>

      {/* Enhanced Tabs */}
      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        {!onlyVisual && (
          <div className="bg-white rounded-xl border border-slate-200 p-1.5 shadow-sm mb-6 inline-flex">
            <TabsList className="grid grid-cols-2 gap-1 bg-transparent p-0">
              <TabsTrigger
                value="pages"
                className="flex items-center gap-2 px-6 py-2.5 rounded-lg data-[state=active]:bg-gradient-to-r data-[state=active]:from-blue-600 data-[state=active]:to-blue-700 data-[state=active]:text-white data-[state=active]:shadow-md transition-all duration-200 font-medium"
              >
                <FileText className="w-4 h-4" />
                Pages
              </TabsTrigger>
              <TabsTrigger
                value="categories"
                className="flex items-center gap-2 px-6 py-2.5 rounded-lg data-[state=active]:bg-gradient-to-r data-[state=active]:from-purple-600 data-[state=active]:to-purple-700 data-[state=active]:text-white data-[state=active]:shadow-md transition-all duration-200 font-medium"
              >
                <FolderOpen className="w-4 h-4" />
                Categories
              </TabsTrigger>
            </TabsList>
          </div>
        )}

        <TabsContent value="pages" className="mt-0">
          <GenericContentManager
            tableName="pages"
            resourceName={onlyVisual ? "Visual Page" : "Page"}
            columns={pageColumns}
            formFields={pageFormFields}
            permissionPrefix={onlyVisual ? "visual_pages" : "pages"}
            customRowActions={customRowActions}
            defaultFilters={onlyVisual ? { editor_type: 'visual' } : {}}
            showBreadcrumbs={false}
          />
        </TabsContent>

        <TabsContent value="categories" className="mt-0">
          <GenericContentManager
            tableName="categories"
            resourceName="Category"
            columns={categoryColumns}
            formFields={categoryFormFields}
            permissionPrefix="categories"
            customSelect="*, owner:users!created_by(email, full_name)"
            defaultFilters={{ type: 'page' }}
            showBreadcrumbs={false}
          />
        </TabsContent>
      </Tabs>
    </div>
  );
}

export default PagesManager;
