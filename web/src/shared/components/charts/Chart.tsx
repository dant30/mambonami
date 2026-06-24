// web/src/shared/components/charts/Chart.tsx
import React from 'react';
import { cn } from '@/lib/utils';

interface ChartProps extends React.HTMLAttributes<HTMLDivElement> {
  title?: string;
  description?: string;
  children: React.ReactNode;
  className?: string;
}

export default function Chart({ title, description, children, className, ...props }: ChartProps) {
  return (
    <div
      className={cn(
        "rounded-2xl border border-border bg-card p-5 shadow-sm transition-colors",
        className
      )}
      {...props}
    >
      {(title || description) && (
        <div className="mb-4">
          {title && (
            <h3 className="text-base font-semibold text-foreground">{title}</h3>
          )}
          {description && (
            <p className="text-sm text-muted-foreground">{description}</p>
          )}
        </div>
      )}
      <div className="w-full min-h-[220px]">{children}</div>
    </div>
  );
}