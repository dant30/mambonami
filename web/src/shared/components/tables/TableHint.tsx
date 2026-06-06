// frontend/src/shared/components/tables/TableHint.tsx
import * as React from 'react';
import { cn } from '../../../lib/utils';

interface TableHintProps extends React.HTMLAttributes<HTMLElement> {
  as?: React.ElementType;
}

export const TableHint = React.forwardRef<HTMLElement, TableHintProps>(
  ({ className, as: Component = 'div', ...props }, ref) => {
    const Element = Component as React.ElementType;
    return (
      <Element
        ref={ref as React.LegacyRef<HTMLElement>}
        className={cn('mt-2 text-sm text-text-muted', className)}
        {...props}
      />
    );
  },
);
TableHint.displayName = 'TableHint';
