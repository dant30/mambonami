import * as React from 'react';
import { cn } from '@/shared/utils/classnames';

interface DividerProps extends React.HTMLAttributes<HTMLHRElement> {
  orientation?: 'horizontal' | 'vertical';
  variant?: 'solid' | 'dashed' | 'dotted';
}

export const Divider = React.forwardRef<HTMLHRElement, DividerProps>(
  ({ className, orientation = 'horizontal', variant = 'solid', ...props }, ref) => {
    const orientationClasses = orientation === 'horizontal' ? 'w-full' : 'h-full';
    const variantClasses = {
      solid: 'border-solid',
      dashed: 'border-dashed',
      dotted: 'border-dotted',
    };
    return (
      <hr
        ref={ref}
        className={cn(
          orientationClasses,
          'border-t border-border',
          variantClasses[variant],
          className
        )}
        {...props}
      />
    );
  }
);
Divider.displayName = 'Divider';