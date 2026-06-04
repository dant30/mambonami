import React from 'react';
import { cn } from '../../../lib/utils';

interface CardProps extends React.HTMLAttributes<HTMLDivElement> {}

export default function Card({ className = '', children, ...props }: CardProps) {
  return (
    <div
      className={cn(
        'overflow-hidden rounded-[28px] border border-border bg-card p-6 shadow-soft text-card-foreground',
        className,
      )}
      {...props}
    >
      {children}
    </div>
  );
}

