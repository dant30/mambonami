// frontend/src/shared/components/tables/DataTable.tsx
import React, { useEffect, useState } from 'react';
import { Pagination } from '../ui/Pagination';

interface Column<T> {
  header: string;
  accessor?: keyof T;
  render?: (item: T) => React.ReactNode;
  className?: string;
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

  return (
      <div className="space-y-3 sm:space-y-4">
      <div className="overflow-x-auto bg-white rounded-xl border border-slate-200 shadow-xs sm:rounded-2xl">
        <table className="w-full min-w-[640px] text-left text-xs sm:text-sm">
        <thead className="bg-slate-50 border-b border-slate-200 text-[11px] font-bold text-slate-500 uppercase tracking-wider">
          <tr>
            {columns.map((col, idx) => (
              <th key={idx} className={`px-3 py-3 sm:px-5 sm:py-3.5 ${col.className || ''}`}>
                {col.header}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-slate-100">
          {visibleData.map((item) => (
            <tr key={keyExtractor(item)} className="hover:bg-slate-50/70 transition-colors">
              {columns.map((col, cIdx) => (
                <td key={cIdx} className={`px-3 py-3 sm:px-5 sm:py-4 ${col.className || ''}`}>
                  {col.render ? col.render(item) : col.accessor ? String(item[col.accessor]) : null}
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
