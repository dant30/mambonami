import React from 'react';
import { cn } from '../../../lib/utils';

interface Option {
  value: string;
  label: string;
}

interface SelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  options?: Option[];
}

const Select = React.forwardRef<HTMLSelectElement, SelectProps>(
  ({ options = [], className = '', children, ...props }, ref) => (
    <select
      ref={ref}
      className={cn(
        'w-full appearance-none rounded-2xl border border-border bg-input px-4 py-3 pr-10 text-sm text-foreground shadow-soft transition duration-200 focus:border-primary focus:outline-none focus:ring-2 focus:ring-ring',
        className,
      )}
      {...props}
    >
      {children}
      {options.map((option) => (
        <option key={option.value} value={option.value}>
          {option.label}
        </option>
      ))}
    </select>
  ),
);

Select.displayName = 'Select';

export default Select;

