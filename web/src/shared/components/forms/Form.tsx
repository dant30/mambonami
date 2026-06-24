// web/src/shared/components/forms/Form.tsx
import React from 'react';
import { cn } from '@/lib/utils';

interface FormProps extends React.FormHTMLAttributes<HTMLFormElement> {
  title?: string;
  description?: string;
  variant?: 'card' | 'plain';
  className?: string;
}

export default function Form({
  title,
  description,
  variant = 'card',
  className = '',
  children,
  ...props
}: FormProps) {
  const baseClasses = 'space-y-6';
  const variantClasses =
    variant === 'card'
      ? 'rounded-lg border border-border bg-card p-6 shadow-sm'
      : '';

  return (
    <form className={cn(baseClasses, variantClasses, className)} {...props}>
      {(title || description) && (
        <div className="space-y-1.5">
          {title && (
            <h2 className="text-2xl font-semibold tracking-tight text-foreground">
              {title}
            </h2>
          )}
          {description && (
            <p className="text-sm text-muted-foreground">{description}</p>
          )}
        </div>
      )}
      {children}
    </form>
  );
}