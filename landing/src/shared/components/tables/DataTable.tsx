// frontend/src/shared/components/tables/DataTable.tsx
import React, { useEffect, useState } from 'react';
import { Pagination } from '../ui/Pagination';

interface Column<T> {
  header: string;
  accessor?: keyof T;
  render?: (item: T) => React.ReactNode;
  className?: string;
  mobileRole?: 'title' | 'summary' | 'status' | 'detail' | 'action';
}

interface DataTableProps<T> {
  data: T[];
  columns: Column<T>[];
  keyExtractor: (item: T) => string;
  emptyMessage?: string;
}

export function DataTable<T>({
  data = [],
  columns,
  keyExtractor,
  emptyMessage = 'No records found.',
}: DataTableProps<T>) {
  const [page, setPage] = useState(1);
  const pageSize = 15;

  useEffect(() => {
    setPage(1);
  }, [data]);

  if (!data || data.length === 0) {
    return (
      <div className="p-5 text-center bg-white rounded-xl border border-slate-200 text-slate-400 text-sm sm:rounded-2xl sm:p-8">
        {emptyMessage}
      </div>
    );
  }

  const visibleData = data.slice((page - 1) * pageSize, page * pageSize);
  const renderCell = (column: Column<T>, item: T) =>
    column.render ? column.render(item) : column.accessor ? String(item[column.accessor]) : null;

  return (
    <div className="space-y-3 sm:space-y-4">
      <div className="space-y-3 md:hidden" aria-label="Records">
        {visibleData.map((item) => {
          const titleIndex = Math.max(0, columns.findIndex((column) => column.mobileRole === 'title'));
          const summaryIndex = columns.findIndex((column) => column.mobileRole === 'summary');
          const statusIndex = columns.findIndex((column) => column.mobileRole === 'status');
          const actionIndex = columns.findIndex((column) => column.mobileRole === 'action');
          const detailIndices = columns.flatMap((column, index) => {
            if (column.mobileRole === 'detail') return [index];
            if (column.mobileRole) return [];
            if (index === titleIndex || index === summaryIndex || index === statusIndex || index === actionIndex) return [];
            return [index];
          });

          return (
            <article key={keyExtractor(item)} className="rounded-xl border border-border bg-card p-3 shadow-sm">
              <div className="flex items-start justify-between gap-3">
                <div className="min-w-0 flex-1">
                  <div className="break-words text-sm font-semibold text-foreground">{renderCell(columns[titleIndex], item)}</div>
                  {statusIndex >= 0 && <div className="mt-2">{renderCell(columns[statusIndex], item)}</div>}
                </div>
                {summaryIndex >= 0 && <div className="shrink-0 text-right text-sm font-semibold text-foreground">{renderCell(columns[summaryIndex], item)}</div>}
              </div>
              {detailIndices.length > 0 && (
                <details className="mt-3 border-t border-border pt-2">
                  <summary className="min-h-10 cursor-pointer py-2 text-xs font-semibold text-primary">More details</summary>
                  <dl className="space-y-2 pb-2">
                    {detailIndices.map((index) => (
                      <div key={index} className="grid grid-cols-[minmax(0,0.8fr)_minmax(0,1.2fr)] gap-3 text-xs">
                        <dt className="text-muted-foreground">{columns[index].header || 'Action'}</dt>
                        <dd className="min-w-0 break-words text-right text-foreground">{renderCell(columns[index], item)}</dd>
                      </div>
                    ))}
                  </dl>
                </details>
              )}
              {actionIndex >= 0 && <div className="mt-3 border-t border-border pt-3">{renderCell(columns[actionIndex], item)}</div>}
            </article>
          );
        })}
      </div>
      <div className="hidden overflow-x-auto rounded-xl border border-slate-200 bg-white shadow-xs sm:rounded-2xl md:block">
        <table className="w-full min-w-[640px] text-left text-xs sm:text-sm">
          <thead className="border-b border-slate-200 bg-slate-50 text-[11px] font-bold uppercase tracking-wider text-slate-500">
            <tr>
              {columns.map((column, index) => (
                <th key={index} className={`px-3 py-3 sm:px-5 sm:py-3.5 ${column.className || ''}`}>
                  {column.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100">
            {visibleData.map((item) => (
              <tr key={keyExtractor(item)} className="transition-colors hover:bg-slate-50/70">
                {columns.map((column, index) => (
                  <td key={index} className={`px-3 py-3 sm:px-5 sm:py-4 ${column.className || ''}`}>
                    {renderCell(column, item)}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      <Pagination page={page} pageSize={pageSize} total={data.length} onPageChange={setPage} />
    </div>
  );
}
