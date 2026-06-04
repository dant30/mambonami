import React from 'react';
import { cn } from '../../../lib/utils';

interface CheckboxProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
}

const Checkbox = React.forwardRef<HTMLInputElement, CheckboxProps>(({ label, className = '', ...props }, ref) => (
  <label className={cn('inline-flex items-center gap-3 text-sm text-foreground', className)}>
    <input
      ref={ref}
      type="checkbox"
      className="h-5 w-5 rounded-lg border border-border bg-input text-primary shadow-sm transition duration-200 focus:ring-2 focus:ring-ring focus:outline-none"
      {...props}
    />
    {label ? <span>{label}</span> : null}
  </label>
));

Checkbox.displayName = 'Checkbox';

export default Checkbox;

