// web/src/shared/components/forms/FormSelect.tsx
import React from 'react';
import { cn } from '@/lib/utils';
import FormField from './FormField';

interface FormSelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  label?: string;
  error?: string;
  hint?: string;
  options?: Array<{ value: string; label: string }>;
}

export default function FormSelect({
  label,
  error,
  hint,
  className = '',
  id,
  options = [],
  children,
  ...props
}: FormSelectProps) {
  const selectId = id || props.name;

  return (
    <FormField
      id={selectId}
      label={label}
      errors={error}
      hint={hint}
      className="w-full"
    >
      <select
        id={selectId}
        className={cn(
          'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background',
          'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
          'disabled:cursor-not-allowed disabled:opacity-50',
          className
        )}
        {...props}
      >
        {options.length > 0
          ? options.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))
          : children}
      </select>
    </FormField>
  );
}