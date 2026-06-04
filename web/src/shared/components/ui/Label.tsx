import React from 'react';
import { cn } from '../../../lib/utils';

interface LabelProps extends React.LabelHTMLAttributes<HTMLLabelElement> {}

export default function Label({ className = '', children, ...props }: LabelProps) {
  return (
    <label className={cn('block text-sm font-semibold text-foreground', className)} {...props}>
      {children}
    </label>
  );
}
