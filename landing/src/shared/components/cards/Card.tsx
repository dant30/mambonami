// frontend/src/shared/components/cards/Card.tsx
import React, { type ReactNode, type HTMLAttributes } from 'react'
import { cn } from '../../../core/utils/cn'

export interface CardProps extends HTMLAttributes<HTMLDivElement> {
  variant?: 'default' | 'flat' | 'dark' | 'gradient' | 'interactive'
  padding?: 'none' | 'sm' | 'md' | 'lg'
  children: ReactNode
  className?: string
  onClick?: () => void
}

export function Card({
  variant = 'default',
  padding = 'md',
  children,
  className,
  onClick,
  ...rest
}: CardProps) {
  const variantStyles = {
    default: 'border border-border bg-card text-card-foreground shadow-soft',
    flat: 'border border-border bg-muted/60 text-foreground',
    dark: 'border border-border bg-primary-dark text-primary-foreground shadow-soft',
    gradient:
      'border border-primary/15 bg-gradient-to-br from-card via-primary/5 to-secondary/10 text-foreground shadow-soft',
    interactive:
      'border border-border bg-card text-card-foreground shadow-soft hover:border-primary/60 hover:shadow-glow hover:-translate-y-0.5 transition-all duration-200 cursor-pointer active:scale-[0.99]',
  }[variant]

  const paddingStyles = {
    none: 'p-0',
    sm: 'p-3 sm:p-4',
    md: 'p-5 sm:p-6',
    lg: 'p-6 sm:p-8',
  }[padding]

  return (
    <div
      role={onClick ? 'button' : undefined}
      tabIndex={onClick ? 0 : undefined}
      onClick={onClick}
      className={cn('min-w-0 max-w-full overflow-hidden rounded-2xl transition-all duration-200', variantStyles, paddingStyles, className)}
      {...rest}
    >
      {children}
    </div>
  )
}

export interface CardHeaderProps {
  title?: ReactNode
  description?: ReactNode
  icon?: ReactNode
  action?: ReactNode
  badge?: ReactNode
  className?: string
  children?: ReactNode
}

export function CardHeader({
  title,
  description,
  icon,
  action,
  badge,
  className = '',
  children,
}: CardHeaderProps) {
  return (
    <div className={cn('mb-4 flex min-w-0 flex-wrap items-start justify-between gap-3', className)}>
      <div className="flex min-w-0 flex-1 items-start gap-3">
        {icon && (
          <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
            {icon}
          </span>
        )}
        <div className="min-w-0 flex-1">
          <div className="flex items-center gap-2">
            {typeof title === 'string' ? (
              <h3 className="truncate font-display text-base font-bold text-foreground sm:text-lg">
                {title}
              </h3>
            ) : (
              title
            )}
            {badge}
          </div>
          {description && (
            <p className="mt-0.5 text-xs text-muted-foreground line-clamp-2 sm:text-sm">
              {description}
            </p>
          )}
          {children}
        </div>
      </div>
      {action && <div className="max-w-full shrink-0">{action}</div>}
    </div>
  )
}

export function CardTitle({
  children,
  className = '',
}: {
  children: ReactNode
  className?: string
}) {
  return (
    <h3 className={cn('font-display text-lg font-bold tracking-tight text-foreground', className)}>
      {children}
    </h3>
  )
}

export function CardDescription({
  children,
  className = '',
}: {
  children: ReactNode
  className?: string
}) {
  return <p className={cn('text-xs leading-relaxed text-muted-foreground sm:text-sm', className)}>{children}</p>
}

export interface CardMetaItem {
  icon?: ReactNode
  label?: string
  value: ReactNode
}

export function CardMeta({
  items,
  className = '',
}: {
  items: CardMetaItem[]
  className?: string
}) {
  return (
    <div className={cn('flex min-w-0 flex-wrap items-center gap-2 border-t border-border pt-3 text-xs text-muted-foreground', className)}>
      {items.map((item, idx) => (
        <div key={idx} className="inline-flex min-w-0 max-w-full items-center gap-1.5 font-medium">
          {item.icon && <span className="text-primary">{item.icon}</span>}
          {item.label && <span className="text-muted-foreground">{item.label}:</span>}
          <span className="min-w-0 break-words font-semibold text-foreground">{item.value}</span>
        </div>
      ))}
    </div>
  )
}

export function CardContent({
  children,
  className = '',
}: {
  children: ReactNode
  className?: string
}) {
  return <div className={cn('space-y-3', className)}>{children}</div>
}

export function CardFooter({
  children,
  className = '',
  divider = true,
}: {
  children: ReactNode
  className?: string
  divider?: boolean
}) {
  return (
    <div
      className={cn(
        'mt-4 flex flex-wrap items-center justify-between gap-3 pt-3',
        divider ? 'border-t border-border' : '',
        className,
      )}
    >
      {children}
    </div>
  )
}
