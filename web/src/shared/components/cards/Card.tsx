// web/src/shared/components/cards/Card.tsx
import type { ComponentPropsWithoutRef, PropsWithChildren, ReactNode } from 'react';
import { forwardRef } from 'react';

import { cn } from '../../../lib/utils';

type CardVariant = 'default' | 'elevated' | 'outlined' | 'filled';
type CardPadding = 'none' | 'sm' | 'md' | 'lg' | 'xl';

const variantClasses: Record<CardVariant, string> = {
  default: 'card',
  elevated: 'card',
  outlined: 'card border border-surface-border',
  filled: 'card bg-surface-subtle',
};

const paddingClasses: Record<CardPadding, string> = {
  none: '',
  sm: 'p-4',
  md: 'p-4',
  lg: 'p-4',
  xl: 'p-4',
};

export interface CardProps extends ComponentPropsWithoutRef<'div'> {
  children: ReactNode;
  className?: string;
  variant?: CardVariant;
  padding?: CardPadding;
  hover?: boolean;
  as?: 'div' | 'section' | 'article';
}

export const Card = forwardRef<HTMLDivElement, CardProps>(
  (
    {
      children,
      className,
      variant = 'default',
      padding = 'md',
      hover = false,
      as: Component = 'div',
      ...props
    },
    ref,
  ) => {
    return (
      <Component
        ref={ref}
        className={cn(
          variantClasses[variant],
          paddingClasses[padding],
          hover && 'hover-lift',
          className,
        )}
        {...props}
      >
        {children}
      </Component>
    );
  },
);

Card.displayName = 'Card';
export default Card;

export function CardHeader({
  children,
  className,
  ...props
}: PropsWithChildren<{ className?: string }>) {
  return (
    <div className={cn('card-header', className)} {...props}>
      {children}
    </div>
  );
}

export function CardBody({
  children,
  className,
  ...props
}: PropsWithChildren<{ className?: string }>) {
  return (
    <div className={cn('card-body', className)} {...props}>
      {children}
    </div>
  );
}

export function CardFooter({
  children,
  className,
  ...props
}: PropsWithChildren<{ className?: string }>) {
  return (
    <div className={cn('card-footer', className)} {...props}>
      {children}
    </div>
  );
}

export const CardContent = forwardRef<
  HTMLDivElement,
  PropsWithChildren<{ className?: string }> & ComponentPropsWithoutRef<'div'>
>(({ children, className, ...props }, ref) => (
  <div ref={ref} className={cn('ui-card__content', className)} {...props}>
    {children}
  </div>
));

CardContent.displayName = 'CardContent';
