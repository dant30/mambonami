import { TableColumn } from './Column';

interface DataTableProps<T> {
  columns: TableColumn<T>[];
  data: T[];
  className?: string;
}

export function DataTable<T extends Record<string, unknown>>({ columns, data, className = '' }: DataTableProps<T>) {
  return (
    <div className={`overflow-x-auto rounded-3xl border border-slate-200 bg-white shadow-soft ${className}`}>
      <table className="min-w-full divide-y divide-slate-200 text-sm">
        <thead className="bg-slate-50">
          <tr>
            {columns.map((column) => (
              <th key={String(column.key)} className="px-4 py-3 text-left font-semibold text-slate-600">
                {column.title}
              </th>
            ))}
          </tr>
        </thead>
        <tbody className="divide-y divide-slate-200">
          {data.length === 0 ? (
            <tr>
              <td colSpan={columns.length} className="px-4 py-6 text-center text-sm text-slate-500">
                No records found.
              </td>
            </tr>
          ) : (
            data.map((row, rowIndex) => (
              <tr key={rowIndex} className="even:bg-slate-50">
                {columns.map((column) => {
                  const value = row[column.key as keyof T];
                  return (
                    <td key={String(column.key)} className={`px-4 py-4 text-slate-700 ${column.className ?? ''}`}>
                      {column.render ? column.render(value, row, rowIndex) : String(value ?? '')}
                    </td>
                  );
                })}
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}
