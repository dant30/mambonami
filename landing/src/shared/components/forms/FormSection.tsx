import React from 'react'

export interface FormSectionProps {
  title: string
  description?: string
  icon?: React.ReactNode
  badge?: React.ReactNode
  children: React.ReactNode
  className?: string
  divider?: boolean
}

export const FormSection: React.FC<FormSectionProps> = ({
  title,
  description,
  icon,
  badge,
  children,
  className = '',
  divider = true,
}) => {
  return (
    <div className={`space-y-4 ${divider ? 'mb-6 border-b border-border pb-6 last:mb-0 last:border-b-0 last:pb-0' : ''} ${className}`}>
      <div className="flex items-start justify-between gap-3">
        <div className="flex items-start gap-2.5">
          {icon && (
            <div className="mt-0.5 rounded-lg bg-primary/10 p-1.5 text-primary">
              {icon}
            </div>
          )}
          <div>
            <h3 className="text-sm font-black tracking-tight text-foreground">{title}</h3>
            {description && <p className="mt-0.5 text-xs leading-relaxed text-muted-foreground">{description}</p>}
          </div>
        </div>
        {badge && <div>{badge}</div>}
      </div>

      <div className="space-y-4 pt-1">{children}</div>
    </div>
  )
}
