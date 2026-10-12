// frontend/src/shared/components/ui/PageHeader.tsx
import React, { type ReactNode } from 'react'
import { Link } from 'react-router-dom'
import { ArrowLeft, ChevronRight } from 'lucide-react'

export interface PageHeaderBreadcrumb {
  label: string
  href?: string
  onClick?: () => void
}

export interface PageHeaderMetadataItem {
  icon?: ReactNode
  label?: string
  value: ReactNode
}

export interface PageHeaderBadge {
  text: string
  variant?: 'orange' | 'emerald' | 'blue' | 'amber' | 'neutral'
}

export interface PageHeaderStatus {
  label: string
  indicator?: 'online' | 'busy' | 'verified' | 'neutral'
}

export interface PageHeaderProps {
  eyebrow?: string
  title: string
  description?: string
  icon?: ReactNode
  actions?: ReactNode
  children?: ReactNode
  variant?: 'dark' | 'light' | 'primary' | 'minimal'
  className?: string
  // Navigation & Hierarchy
  breadcrumbs?: PageHeaderBreadcrumb[]
  onBack?: () => void
  backHref?: string
  backLabel?: string
  // Meta tags & Indicators
  badge?: ReactNode | PageHeaderBadge
  status?: PageHeaderStatus
  metadata?: PageHeaderMetadataItem[] | ReactNode
  // Tab strip slot docked at header bottom
  tabs?: ReactNode
}

export function PageHeader({
  eyebrow,
  title,
  description,
  icon,
  actions,
  children,
  variant = 'dark',
  className = '',
  breadcrumbs,
  onBack,
  backHref,
  backLabel = 'Back',
  badge,
  status,
  metadata,
  tabs,
}: PageHeaderProps) {
  const dark = variant === 'dark'
  const isPrimary = variant === 'primary'
  const isMinimal = variant === 'minimal'

  const getContainerStyles = () => {
    if (isMinimal) {
      return 'border-b border-border bg-transparent text-foreground pb-5'
    }
    if (isPrimary) {
      return 'border border-primary/20 bg-gradient-to-br from-primary via-primary-dark to-primary/90 text-primary-foreground shadow-soft'
    }
    if (dark) {
      return 'border border-primary/20 bg-primary-dark text-primary-foreground shadow-soft'
    }
    return 'border border-border bg-card text-card-foreground shadow-soft'
  }

  const renderBadge = () => {
    if (!badge) return null
    if (React.isValidElement(badge)) return badge

    const b = badge as PageHeaderBadge
    const badgeColors = {
      orange: dark || isPrimary
        ? 'bg-primary/15 text-primary-foreground border border-primary/30'
        : 'bg-primary/10 text-primary border border-primary/20',
      emerald: dark || isPrimary
        ? 'bg-emerald-500/20 text-emerald-200 border border-emerald-400/30'
        : 'bg-emerald-50 text-emerald-700 border border-emerald-200',
      blue: dark || isPrimary
        ? 'bg-blue-500/20 text-blue-100 border border-blue-300/30'
        : 'bg-blue-50 text-blue-700 border border-blue-200',
      amber: dark || isPrimary
        ? 'bg-amber-500/20 text-amber-100 border border-amber-300/30'
        : 'bg-amber-50 text-amber-700 border border-amber-200',
      neutral: dark || isPrimary
        ? 'bg-white/10 text-primary-foreground border border-white/10'
        : 'bg-muted text-foreground border border-border',
    }[b.variant || 'orange']

    return (
      <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-[11px] font-bold tracking-wide ${badgeColors}`}>
        {b.text}
      </span>
    )
  }

  const renderStatus = () => {
    if (!status) return null
    const dotColors = {
      online: 'bg-emerald-400 ring-emerald-400/30',
      busy: 'bg-destructive ring-destructive/30',
      verified: 'bg-primary ring-primary/30',
      neutral: 'bg-muted-foreground ring-muted-foreground/30',
    }[status.indicator || 'online']

    return (
      <div
        className={`inline-flex items-center gap-1.5 rounded-full px-2.5 py-1 text-xs font-semibold ${
          dark || isPrimary ? 'bg-white/10 text-primary-foreground' : 'bg-muted text-foreground'
        }`}
      >
        <span className={`h-2 w-2 rounded-full ring-4 ${dotColors}`} />
        <span>{status.label}</span>
      </div>
    )
  }

  const renderBackButton = () => {
    if (!onBack && !backHref) return null

    const buttonClasses = `inline-flex items-center gap-1.5 rounded-xl text-xs font-bold transition min-h-10 px-3 py-1.5 ${
      dark || isPrimary
        ? 'bg-white/10 text-primary-foreground hover:bg-white/20 active:scale-95'
        : 'bg-muted text-foreground hover:bg-muted/80 active:scale-95'
    }`

    if (backHref) {
      return (
        <Link to={backHref} className={buttonClasses}>
          <ArrowLeft className="h-3.5 w-3.5" />
          <span>{backLabel}</span>
        </Link>
      )
    }

    return (
      <button type="button" onClick={onBack} className={buttonClasses}>
        <ArrowLeft className="h-3.5 w-3.5" />
        <span>{backLabel}</span>
      </button>
    )
  }

  const renderMetadata = () => {
    if (!metadata) return null
    if (React.isValidElement(metadata)) return metadata

    const items = metadata as PageHeaderMetadataItem[]
    return (
      <div className="flex flex-wrap items-center gap-2 sm:gap-3 pt-2">
        {items.map((item, idx) => (
          <div
            key={idx}
            className={`inline-flex items-center gap-1.5 rounded-lg px-2.5 py-1 text-xs border ${
              dark || isPrimary
                ? 'border-white/10 bg-white/10 text-primary-foreground'
                : 'border-border bg-muted text-foreground'
            }`}
          >
            {item.icon && <span className="shrink-0 text-primary">{item.icon}</span>}
            {item.label && <span className="text-muted-foreground font-medium">{item.label}:</span>}
            <span className={`font-semibold ${dark || isPrimary ? 'text-primary-foreground' : 'text-foreground'}`}>
              {item.value}
            </span>
          </div>
        ))}
      </div>
    )
  }

  return (
    <header
      className={`relative overflow-hidden rounded-2xl sm:rounded-3xl ${
        isMinimal ? 'p-0' : 'p-4 sm:p-8'
      } ${getContainerStyles()} ${className}`}
    >
      {dark && (
        <>
          <div
            aria-hidden="true"
            className="pointer-events-none absolute -right-20 -top-20 h-64 w-64 rounded-full bg-primary/10 blur-3xl"
          />
          <div
            aria-hidden="true"
            className="pointer-events-none absolute -left-20 -bottom-20 h-48 w-48 rounded-full bg-secondary/10 blur-3xl"
          />
        </>
      )}

      {(breadcrumbs || onBack || backHref) && (
        <div className="relative z-10 mb-4 flex flex-wrap items-center justify-between gap-3 border-b border-border/70 pb-3">
          <div className="flex items-center gap-2">
            {renderBackButton()}
            {breadcrumbs && breadcrumbs.length > 0 && (
              <nav aria-label="Breadcrumb" className="flex items-center gap-1 text-xs">
                {breadcrumbs.map((crumb, i) => {
                  const isLast = i === breadcrumbs.length - 1
                  return (
                    <React.Fragment key={i}>
                      {i > 0 && (
                        <ChevronRight
                          className={`h-3 w-3 ${dark || isPrimary ? 'text-primary-foreground/70' : 'text-muted-foreground'}`}
                        />
                      )}
                      {crumb.href && !isLast ? (
                        <Link
                          to={crumb.href}
                          className={`transition ${
                            dark || isPrimary ? 'text-primary-foreground/80 hover:text-primary-foreground' : 'text-muted-foreground hover:text-foreground'
                          }`}
                        >
                          {crumb.label}
                        </Link>
                      ) : crumb.onClick && !isLast ? (
                        <button
                          type="button"
                          onClick={crumb.onClick}
                          className={`transition ${
                            dark || isPrimary ? 'text-primary-foreground/80 hover:text-primary-foreground' : 'text-muted-foreground hover:text-foreground'
                          }`}
                        >
                          {crumb.label}
                        </button>
                      ) : (
                        <span
                          className={`font-bold ${
                            isLast
                              ? dark || isPrimary
                                ? 'text-primary-foreground'
                                : 'text-foreground'
                              : dark || isPrimary
                              ? 'text-primary-foreground/70'
                              : 'text-muted-foreground'
                          }`}
                        >
                          {crumb.label}
                        </span>
                      )}
                    </React.Fragment>
                  )
                })}
              </nav>
            )}
          </div>

          {status && <div className="hidden sm:block">{renderStatus()}</div>}
        </div>
      )}

      <div className="relative z-10 flex flex-col justify-between gap-4 sm:flex-row sm:items-end sm:gap-6">
        <div className="min-w-0 flex-1">
          <div className="flex items-start gap-3 sm:gap-4">
            {icon && (
              <span
                className={`mt-1 flex h-11 w-11 sm:h-12 sm:w-12 shrink-0 items-center justify-center rounded-2xl border transition ${
                  dark || isPrimary
                    ? 'border-white/15 bg-white/10 text-primary shadow-soft'
                    : 'border-primary/15 bg-primary/5 text-primary'
                }`}
              >
                {icon}
              </span>
            )}
            <div className="min-w-0 flex-1">
              {(eyebrow || badge || status) && (
                <div className="mb-1.5 flex flex-wrap items-center gap-2">
                  {eyebrow && (
                    <p
                      className={`text-[11px] font-bold uppercase tracking-[0.2em] ${
                        dark || isPrimary ? 'text-primary-foreground/80' : 'text-primary'
                      }`}
                    >
                      {eyebrow}
                    </p>
                  )}
                  {renderBadge()}
                  {status && (!breadcrumbs && !onBack && !backHref) && (
                    <div className="sm:hidden">{renderStatus()}</div>
                  )}
                </div>
              )}

              <h1
                className={`font-display text-2xl font-black tracking-tight sm:text-3xl lg:text-4xl ${
                  dark || isPrimary ? 'text-primary-foreground' : 'text-foreground'
                }`}
              >
                {title}
              </h1>

              {description && (
                <p
                  className={`mt-2 max-w-3xl text-xs leading-relaxed sm:text-sm ${
                    dark || isPrimary ? 'text-primary-foreground/80' : 'text-muted-foreground'
                  }`}
                >
                  {description}
                </p>
              )}

              {renderMetadata()}
            </div>
          </div>

            {children && <div className="mt-4 sm:mt-5">{children}</div>}
        </div>

        {actions && <div className="relative z-10 w-full shrink-0 self-start sm:w-auto sm:self-end [&>div]:flex-nowrap [&>div]:w-full [&>div>button]:min-w-0 [&>div>button]:flex-1 [&>div>button]:whitespace-nowrap [&>div>a]:min-w-0 [&>div>a]:flex-1 [&>div>a]:whitespace-nowrap sm:[&>div>button]:flex-none sm:[&>div>a]:flex-none">{actions}</div>}
      </div>

      {tabs && (
          <div className="relative z-10 mt-4 border-t border-border/80 pt-3 sm:mt-6 sm:pt-4">
          {tabs}
        </div>
      )}
    </header>
  )
}
