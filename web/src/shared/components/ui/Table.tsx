import React from 'react';
import { cn } from '../../../lib/utils';

interface TableProps extends React.TableHTMLAttributes<HTMLTableElement> {}

export default function Table({ className = '', children, ...props }: TableProps) {
  return (
    <table
      className={cn(
        'min-w-full divide-y divide-border overflow-hidden rounded-3xl border border-border bg-card text-sm text-card-foreground',
        className,
      )}
      {...props}
    >
      {children}
    </table>
  );
}
