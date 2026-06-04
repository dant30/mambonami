import React from 'react';

interface TableProps extends React.TableHTMLAttributes<HTMLTableElement> {}

export default function Table({ className = '', children, ...props }: TableProps) {
  return (
    <table className={`min-w-full divide-y divide-slate-200 overflow-hidden rounded-2xl border border-slate-200 bg-white ${className}`} {...props}>
      {children}
    </table>
  );
}
