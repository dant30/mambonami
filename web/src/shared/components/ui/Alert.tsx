import React from 'react';
import { cn } from '../../../lib/utils';

interface AlertProps extends React.HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'success' | 'warning' | 'destructive';
}

const variantStyles = {
  default: 'border border-border bg-muted/50 text-foreground',
  success: 'border border-emerald-200 bg-emerald-100 text-emerald-900',
  warning: 'border border-amber-200 bg-amber-100 text-amber-900',
  destructive: 'border border-destructive/20 bg-destructive/10 text-destructive',
};

export default function Alert({ variant = 'default', className = '', children, ...props }: AlertProps) {
  return (
    <div
      role="status"
      className={cn('rounded-3xl px-4 py-4 text-sm shadow-soft', variantStyles[variant], className)}
      {...props}
    >
      {children}
    </div>
  );
}

