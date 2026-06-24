// web/src/shared/components/forms/FormInput.tsx
import React from 'react';
import { cn } from '@/lib/utils';
import FormField from './FormField';

interface FormInputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
  hint?: string;
}

export default function FormInput({
  label,
  error,
  hint,
  className = '',
  id,
  ...props
}: FormInputProps) {
  const inputId = id || props.name;

  return (
    <FormField
      id={inputId}
      label={label}
      errors={error}
      hint={hint}
      className="w-full"
    >
      <input
        id={inputId}
        className={cn(
          'flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background',
          'placeholder:text-muted-foreground',
          'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2',
          'disabled:cursor-not-allowed disabled:opacity-50',
          className
        )}
        {...props}
      />
    </FormField>
  );
}