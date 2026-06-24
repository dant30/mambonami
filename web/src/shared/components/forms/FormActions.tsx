// web/src/shared/components/forms/FormActions.tsx
import React from 'react';
import { Button } from '@/shared/components/ui';
import { cn } from '@/lib/utils';

type ButtonProps = React.ComponentPropsWithoutRef<typeof Button>;

interface FormActionsProps {
  primaryLabel?: string;
  secondaryLabel?: string;
  primaryProps?: ButtonProps;
  secondaryProps?: ButtonProps;
  align?: 'left' | 'center' | 'right';
  loading?: boolean;
  className?: string;
}

export default function FormActions({
  primaryLabel = 'Save',
  secondaryLabel = 'Cancel',
  primaryProps = {},
  secondaryProps = {},
  align = 'right',
  loading = false,
  className = '',
}: FormActionsProps) {
  const alignmentClass =
    align === 'left' ? 'justify-start' : align === 'center' ? 'justify-center' : 'justify-end';

  return (
    <div
      className={cn(
        'flex flex-wrap items-center gap-3 border-t border-border pt-4',
        alignmentClass,
        className
      )}
      role="group"
      aria-label="Form actions"
    >
      {secondaryLabel && (
        <Button
          variant="outline"
          type="button"
          disabled={loading}
          {...secondaryProps}
        >
          {secondaryLabel}
        </Button>
      )}
      <Button
        variant="default"
        type="submit"
        disabled={loading}
        {...primaryProps}
      >
        {loading ? 'Saving...' : primaryLabel}
      </Button>
    </div>
  );
}