import * as React from 'react';
import { cn } from '@/shared/utils/classnames';

interface StatusDotProps extends React.HTMLAttributes<HTMLSpanElement> {
  status: 'success' | 'warning' | 'danger' | 'info' | 'neutral';
  size?: 'sm' | 'md' | 'lg';
  label?: string;
}

const colorMap = {
  success: 'bg-success',
  warning: 'bg-warning',
  danger: 'bg-danger',
  info: 'bg-accent-500',
  neutral: 'bg-neutral-500',
};

const sizeMap = {
  sm: 'h-2 w-2',
  md: 'h-3 w-3',
  lg: 'h-4 w-4',
};

export const StatusDot = React.forwardRef<HTMLSpanElement, StatusDotProps>(
  ({ className, status, size = 'md', label, ...props }, ref) => {
    return (
      <span className="inline-flex items-center gap-2">
        <span
          ref={ref}
          className={cn('rounded-full', colorMap[status], sizeMap[size], className)}
          {...props}
        />
        {label && <span className="text-sm text-text-secondary">{label}</span>}
      </span>
    );
  }
);
StatusDot.displayName = 'StatusDot';