import { forwardRef, type ReactNode } from 'react'
import { cn } from '../../../core/utils/cn'

export interface EmptyStateProps {
  title: string
  description?: string
  icon?: ReactNode
  action?: ReactNode
  className?: string
  size?: 'sm' | 'md' | 'lg'
}

const sizeClasses = {
  sm: 'py-8',
  md: 'py-12',
  lg: 'py-16',
}

export const EmptyState = forwardRef<HTMLDivElement, EmptyStateProps>(
  ({ title, description, icon, action, className, size = 'md', ...props }, ref) => {
    return (
      <div
        ref={ref}
        className={cn('empty-state text-center', sizeClasses[size], className)}
        {...props}
      >
        {icon && (
          <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-muted text-muted-foreground">
            {icon}
          </div>
        )}
        <h3 className="text-lg font-semibold text-foreground">{title}</h3>
        {description && <p className="mt-2 text-sm text-muted-foreground">{description}</p>}
        {action && <div className="mt-6">{action}</div>}
      </div>
    )
  },
)

EmptyState.displayName = 'EmptyState'