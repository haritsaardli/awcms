
import React from 'react';
import GenericContentManager from '@/components/dashboard/GenericContentManager';
import { Package, Box, DollarSign, Tag } from 'lucide-react';

function ProductsManager() {
  const columns = [
    {
      key: 'featured_image',
      label: '',
      className: 'w-16',
      render: (val) => val ? (
        <img src={val} alt="" className="w-12 h-12 object-cover rounded-lg border" />
      ) : (
        <div className="w-12 h-12 bg-slate-100 rounded-lg flex items-center justify-center">
          <Package className="w-6 h-6 text-slate-300" />
        </div>
      )
    },
    { key: 'name', label: 'Product Name', className: 'font-medium' },
    {
      key: 'sku',
      label: 'SKU',
      className: 'font-mono text-xs text-slate-500',
      render: (val) => val || <span className="text-slate-300">-</span>
    },
    {
      key: 'price',
      label: 'Price',
      render: (val, row) => (
        <div className="flex flex-col">
          {row.discount_price && row.discount_price < val ? (
            <>
              <span className="text-green-600 font-semibold">
                {new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(row.discount_price)}
              </span>
              <span className="text-xs text-slate-400 line-through">
                {new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)}
              </span>
            </>
          ) : (
            <span className="font-semibold">
              {new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(val)}
            </span>
          )}
        </div>
      )
    },
    {
      key: 'stock',
      label: 'Stock',
      render: (val) => (
        <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${val > 10 ? 'bg-green-100 text-green-700' :
            val > 0 ? 'bg-amber-100 text-amber-700' :
              'bg-red-100 text-red-700'
          }`}>
          {val > 0 ? val : 'Out of Stock'}
        </span>
      )
    },
    {
      key: 'status',
      label: 'Status',
      render: (value) => (
        <span className={`px-2 py-0.5 rounded-full text-xs font-medium ${value === 'active' ? 'bg-green-100 text-green-700' :
            value === 'out_of_stock' ? 'bg-red-100 text-red-700' :
              value === 'draft' ? 'bg-amber-100 text-amber-700' :
                'bg-slate-100 text-slate-600'
          }`}>
          {value?.replace(/_/g, ' ') || 'draft'}
        </span>
      )
    },
    {
      key: 'is_available',
      label: 'Available',
      render: (val) => val ? (
        <span className="text-green-600 text-xs font-medium">✓ Yes</span>
      ) : (
        <span className="text-slate-400 text-xs">No</span>
      )
    }
  ];

  const formFields = [
    // Basic Info
    { key: 'name', label: 'Product Name', required: true, description: 'Display name for the product' },
    { key: 'slug', label: 'Slug', description: 'URL-friendly name (auto-generated if empty)' },
    { key: 'sku', label: 'SKU', description: 'Stock Keeping Unit - unique product identifier' },

    // Pricing
    { key: 'price', label: 'Price (IDR)', type: 'number', required: true },
    { key: 'discount_price', label: 'Discount Price (IDR)', type: 'number', description: 'Sale price (leave empty if no discount)' },

    // Inventory
    { key: 'stock', label: 'Stock Quantity', type: 'number', description: 'Available inventory count' },
    { key: 'is_available', label: 'Available for Purchase', type: 'boolean', description: 'Toggle product availability' },

    // Shipping
    { key: 'shipping_cost', label: 'Shipping Cost (IDR)', type: 'number', description: 'Standard shipping cost' },
    { key: 'weight', label: 'Weight (kg)', type: 'number', description: 'Product weight for shipping calculation' },
    { key: 'dimensions', label: 'Dimensions', description: 'L x W x H in cm (e.g., 30x20x10)' },

    // Media
    { key: 'featured_image', label: 'Main Image', type: 'image', description: 'Product cover/thumbnail' },
    { key: 'images', label: 'Gallery', type: 'images', description: 'Additional product images', maxImages: 10 },

    // Content
    { key: 'description', label: 'Description', type: 'richtext' },

    // Categorization
    { key: 'category_id', label: 'Category', type: 'relation', table: 'categories', filter: { type: 'product' } },
    { key: 'product_type_id', label: 'Product Type', type: 'relation', table: 'product_types', description: 'Specific type/brand/collection' },
    { key: 'tags', label: 'Tags', type: 'tags' },

    // Publishing
    { key: 'published_at', label: 'Launch Date', type: 'datetime' },
    {
      key: 'status', label: 'Status', type: 'select', options: [
        { value: 'draft', label: 'Draft' },
        { value: 'active', label: 'Active' },
        { value: 'out_of_stock', label: 'Out of Stock' },
        { value: 'archived', label: 'Archived' }
      ]
    }
  ];

  return (
    <GenericContentManager
      tableName="products"
      resourceName="Product"
      columns={columns}
      formFields={formFields}
      permissionPrefix="products"
      customSelect="*, category:categories(name), product_type:product_types(name)"
    />
  );
}

export default ProductsManager;
