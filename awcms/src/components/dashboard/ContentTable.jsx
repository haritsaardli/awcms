
import React from 'react';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow
} from "@/components/ui/table";
import { Skeleton } from "@/components/ui/skeleton";
import { Button } from '@/components/ui/button';
import { Edit, Trash2, Eye } from 'lucide-react';
import { format } from 'date-fns';
import { Pagination } from '@/components/ui/pagination';

const ContentTable = ({
  data = [],
  columns = [],
  loading = false,
  onEdit,
  onDelete,
  onView,
  extraActions,
  pagination
}) => {

  const TableSkeleton = () => (
    <div className="rounded-md border bg-white overflow-hidden">
      <Table>
        <TableHeader className="bg-slate-50">
          <TableRow>
            {columns.map((col, i) => (
              <TableHead key={i} className={col.className}>
                <Skeleton className="h-4 w-24 bg-slate-200" />
              </TableHead>
            ))}
            <TableHead className="text-right"><Skeleton className="h-4 w-16 ml-auto bg-slate-200" /></TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          {[...Array(5)].map((_, i) => (
            <TableRow key={i}>
              {columns.map((col, j) => (
                <TableCell key={j} className={col.className}>
                  <Skeleton className="h-4 w-full bg-slate-100" />
                </TableCell>
              ))}
              <TableCell className="text-right">
                <div className="flex justify-end gap-2">
                  <Skeleton className="h-8 w-8 rounded-md bg-slate-100" />
                  <Skeleton className="h-8 w-8 rounded-md bg-slate-100" />
                </div>
              </TableCell>
            </TableRow>
          ))}
        </TableBody>
      </Table>
    </div>
  );

  if (loading) {
    return <TableSkeleton />;
  }

  if (!data || data.length === 0) {
    return (
      <div className="w-full bg-white rounded-md border p-12 flex flex-col items-center justify-center text-slate-500">
        <p className="text-lg font-medium">No items found</p>
        <p className="text-sm">Try adjusting your search or filters.</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="rounded-md border bg-white overflow-hidden">
        <Table>
          <TableHeader className="bg-slate-50">
            <TableRow>
              {columns.map((col) => (
                <TableHead key={col.key} className={col.className}>
                  {col.label}
                </TableHead>
              ))}
              {(onEdit || onDelete || onView || extraActions) && (
                <TableHead className="text-right">Actions</TableHead>
              )}
            </TableRow>
          </TableHeader>
          <TableBody>
            {data.map((item, index) => (
              <TableRow key={item.id || index} className="hover:bg-slate-50/50">
                {columns.map((col) => (
                  <TableCell key={`${item.id}-${col.key}`} className={col.className}>
                    {col.render ? (
                      col.render(item[col.key], item)
                    ) : col.type === 'date' ? (
                      item[col.key] ? format(new Date(item[col.key]), 'MMM d, yyyy') : '-'
                    ) : col.type === 'boolean' ? (
                      item[col.key] ? <span className="text-green-600">Yes</span> : <span className="text-red-600">No</span>
                    ) : (
                      item[col.key]
                    )}
                  </TableCell>
                ))}
                {(onEdit || onDelete || onView || extraActions) && (
                  <TableCell className="text-right">
                    <div className="flex justify-end gap-2">
                      {extraActions && extraActions(item)}
                      {onView && (
                        <Button variant="ghost" size="icon" onClick={() => onView(item)} className="h-8 w-8 text-blue-600 hover:text-blue-700 hover:bg-blue-50">
                          <Eye className="w-4 h-4" />
                        </Button>
                      )}
                      {onEdit && (
                        <Button variant="ghost" size="icon" onClick={() => onEdit(item)} className="h-8 w-8 text-slate-600 hover:text-blue-600 hover:bg-slate-100">
                          <Edit className="w-4 h-4" />
                        </Button>
                      )}
                      {onDelete && (
                        <Button variant="ghost" size="icon" onClick={() => onDelete(item)} className="h-8 w-8 text-slate-400 hover:text-red-600 hover:bg-red-50">
                          <Trash2 className="w-4 h-4" />
                        </Button>
                      )}
                    </div>
                  </TableCell>
                )}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </div>

      {pagination && (
        <div className="flex flex-col sm:flex-row justify-between items-center gap-4 px-2">
          <div className="text-sm text-slate-500">
            Showing {((pagination.currentPage - 1) * pagination.itemsPerPage) + 1} to {Math.min(pagination.currentPage * pagination.itemsPerPage, pagination.totalItems)} of {pagination.totalItems} entries
          </div>
          <div className="flex items-center gap-4">
            <select
              className="h-8 rounded-md border border-slate-300 bg-white text-sm text-slate-600 focus:outline-none focus:ring-2 focus:ring-blue-500"
              value={pagination.itemsPerPage}
              onChange={(e) => pagination.onLimitChange(Number(e.target.value))}
            >
              <option value={10}>10 / page</option>
              <option value={20}>20 / page</option>
              <option value={50}>50 / page</option>
            </select>
            <Pagination
              currentPage={pagination.currentPage}
              totalPages={pagination.totalPages}
              onPageChange={pagination.onPageChange}
            />
          </div>
        </div>
      )}
    </div>
  );
};

export default ContentTable;
