// frontend/src/shared/components/cards/StatCard.tsx
import React, { useId } from 'react'
import { cn } from '../../../core/utils/cn'

export interface StatCardSparkline {
  data: number[]
  color?: string
  type?: 'line' | 'bar'
  height?: number
}

export interface StatCardProgress {
  value: number
  max?: number
  label?: string
  color?: string
}

export interface StatCardMetaItem {
  label?: string
  value: React.ReactNode
  icon?: React.ReactNode
}

export interface StatCardBadge {
  text: string
  variant?: 'success' | 'warning' | 'orange' | 'neutral' | 'blue'
}

export interface StatCardProps {
  title: string
  value: string | number
  subtitle?: string
  change?: string
  changeType?: 'positive' | 'negative' | 'neutral'
  icon?: React.ReactNode
  iconBg?: string
  className?: string
  // Enhanced features
  badge?: string | StatCardBadge | React.ReactNode
  metadata?: StatCardMetaItem[] | React.ReactNode
  chart?: React.ReactNode
  sparkline?: StatCardSparkline | number[]
  progress?: StatCardProgress
  footer?: React.ReactNode
  variant?: 'default' | 'flat' | 'gradient' | 'highlight'
  onClick?: () => void
}

export const StatCard: React.FC<StatCardProps> = ({
  title,
  value,
  subtitle,
  change,
  changeType = 'neutral',
  icon,
  iconBg = 'bg-[#0A2540]/10 text-[#0A2540]',
  className,
  badge,
  metadata,
  chart,
  sparkline,
  progress,
  footer,
  variant = 'default',
  onClick,
}) => {
  const titleId = useId()

  const changeColors = {
    positive: 'text-emerald-700 bg-emerald-50 border border-emerald-200/60',
    negative: 'text-rose-700 bg-rose-50 border border-rose-200/60',
    neutral: 'text-slate-700 bg-slate-100 border border-slate-200/60',
  }[changeType]

  // Render SVG Sparkline
  const renderSparkline = () => {
    if (!sparkline) return null

    const points = Array.isArray(sparkline) ? sparkline : sparkline.data
    if (!points || points.length < 2) return null

    const chartType = Array.isArray(sparkline) ? 'line' : sparkline.type || 'line'
    const sparkHeight = Array.isArray(sparkline) ? 36 : sparkline.height || 36
    const strokeColor = Array.isArray(sparkline)
      ? changeType === 'positive'
        ? '#059669'
        : changeType === 'negative'
        ? '#E11D48'
        : '#FF6B00'
      : sparkline.color || (changeType === 'positive' ? '#059669' : '#FF6B00')

    const width = 120
    const height = sparkHeight
    const padding = 4

    const min = Math.min(...points)
    const max = Math.max(...points)
    const range = max - min || 1

    if (chartType === 'bar') {
      const barWidth = Math.max(2, (width - padding * 2) / points.length - 2)
      return (
        <svg
          viewBox={`0 0 ${width} ${height}`}
          className="h-8 w-14 shrink-0 overflow-visible sm:h-9 sm:w-28"
          aria-hidden="true"
        >
          {points.map((val, idx) => {
            const barHeight = Math.max(3, ((val - min) / range) * (height - padding * 2))
            const x = padding + idx * ((width - padding * 2) / points.length)
            const y = height - padding - barHeight
            const isLast = idx === points.length - 1
            return (
              <rect
                key={idx}
                x={x}
                y={y}
                width={barWidth}
                height={barHeight}
                rx={1.5}
                fill={strokeColor}
                opacity={isLast ? 1 : 0.45 + (idx / points.length) * 0.4}
              />
            )
          })}
        </svg>
      )
    }

    // Line / Area sparkline
    const coordinates = points.map((val, idx) => {
      const x = padding + (idx / (points.length - 1)) * (width - padding * 2)
      const y = height - padding - ((val - min) / range) * (height - padding * 2)
      return { x, y }
    })

    const pathD = coordinates.reduce(
      (acc, curr, idx) => (idx === 0 ? `M ${curr.x} ${curr.y}` : `${acc} L ${curr.x} ${curr.y}`),
      '',
    )

    const areaD = `${pathD} L ${coordinates[coordinates.length - 1].x} ${height} L ${
      coordinates[0].x
    } ${height} Z`

    const gradientId = `spark-grad-${titleId.replace(/:/g, '')}`

    return (
      <svg
        viewBox={`0 0 ${width} ${height}`}
        className="h-8 w-14 shrink-0 overflow-visible sm:h-9 sm:w-28"
        aria-hidden="true"
      >
        <defs>
          <linearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor={strokeColor} stopOpacity="0.3" />
            <stop offset="100%" stopColor={strokeColor} stopOpacity="0.0" />
          </linearGradient>
        </defs>
        <path d={areaD} fill={`url(#${gradientId})`} />
        <path
          d={pathD}
          fill="none"
          stroke={strokeColor}
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
        {/* Endpoint marker dot */}
        <circle
          cx={coordinates[coordinates.length - 1].x}
          cy={coordinates[coordinates.length - 1].y}
          r="3"
          fill={strokeColor}
        />
      </svg>
    )
  }

  // Render Badge
  const renderBadge = () => {
    if (!badge) return null
    if (typeof badge === 'string') {
      return (
        <span className="inline-flex items-center rounded-md bg-orange-50 px-2 py-0.5 text-[10px] font-bold text-[#FF6B00] border border-orange-200/60">
          {badge}
        </span>
      )
    }
    if (React.isValidElement(badge)) return badge

    const b = badge as StatCardBadge
    const badgeColors = {
      success: 'bg-emerald-50 text-emerald-700 border-emerald-200',
      warning: 'bg-amber-50 text-amber-700 border-amber-200',
      orange: 'bg-orange-50 text-[#FF6B00] border-orange-200',
      blue: 'bg-sky-50 text-sky-700 border-sky-200',
      neutral: 'bg-slate-100 text-slate-700 border-slate-200',
    }[b.variant || 'orange']

    return (
      <span
        className={`inline-flex items-center rounded-md px-1.5 py-0.5 text-[10px] font-bold border ${badgeColors}`}
      >
        {b.text}
      </span>
    )
  }

  // Render Metadata row
  const renderMetadata = () => {
    if (!metadata) return null
    if (React.isValidElement(metadata)) return metadata

    const items = metadata as StatCardMetaItem[]
    return (
      <div className="flex flex-wrap items-center gap-2 pt-2 border-t border-slate-100 mt-2">
        {items.map((item, idx) => (
          <div
            key={idx}
            className="inline-flex items-center gap-1 text-[11px] text-slate-500 font-medium"
          >
            {item.icon && <span className="text-[#FF6B00]">{item.icon}</span>}
            {item.label && <span className="text-slate-400">{item.label}:</span>}
            <span className="font-semibold text-slate-800">{item.value}</span>
          </div>
        ))}
      </div>
    )
  }

  // Render Progress bar
  const renderProgress = () => {
    if (!progress) return null
    const max = progress.max || 100
    const percentage = Math.min(100, Math.max(0, (progress.value / max) * 100))
    const barColor = progress.color || '#FF6B00'

    return (
      <div className="space-y-1 pt-2 mt-1 border-t border-slate-100">
        <div className="flex justify-between text-[11px] font-semibold text-slate-600">
          <span>{progress.label || 'Progress'}</span>
          <span>
            {Math.round(percentage)}% ({progress.value}/{max})
          </span>
        </div>
        <div className="h-1.5 w-full overflow-hidden rounded-full bg-slate-100">
          <div
            className="h-full rounded-full transition-all duration-300"
            style={{ width: `${percentage}%`, backgroundColor: barColor }}
          />
        </div>
      </div>
    )
  }

  // Variant styling
  const variantStyles = {
    default: 'border border-slate-200/90 bg-white hover:border-slate-300 hover:shadow-md',
    flat: 'border border-slate-200/70 bg-slate-50/70 hover:bg-white hover:shadow-sm',
    gradient:
      'border border-orange-200/80 bg-gradient-to-br from-white via-orange-50/30 to-amber-50/20 hover:shadow-md',
    highlight: 'border-2 border-[#FF6B00] bg-white shadow-xs hover:shadow-md',
  }[variant]

  const interactiveClasses = onClick
    ? 'cursor-pointer select-none active:scale-[0.99] focus:outline-hidden focus:ring-2 focus:ring-[#FF6B00]/40'
    : ''

  return (
    <div
      aria-labelledby={titleId}
      onClick={onClick}
      role={onClick ? 'button' : undefined}
      tabIndex={onClick ? 0 : undefined}
      className={cn(
        'flex min-w-0 max-w-full flex-col justify-between overflow-hidden rounded-2xl p-3 shadow-xs transition-all duration-200 sm:p-5 hover:-translate-y-0.5',
        variantStyles,
        interactiveClasses,
        className,
      )}
    >
      <div>
        {/* Top Header: Title, Badge, Icon */}
        <div className="flex min-w-0 items-start justify-between gap-2 sm:gap-3">
          <div className="min-w-0 flex-1">
            <div className="flex min-w-0 flex-wrap items-center gap-1.5 sm:gap-2">
              <p
                id={titleId}
                className="min-w-0 truncate text-[10px] font-bold uppercase tracking-wider text-slate-400 sm:text-xs"
              >
                {title}
              </p>
              {renderBadge()}
            </div>

            {/* Value & Sparkline Row */}
            <div className="flex min-w-0 flex-wrap items-baseline justify-between gap-1.5 mt-1">
              <p className="min-w-0 break-words text-xl font-semibold text-slate-900 tracking-tight sm:text-3xl sm:font-semibold">
                {value}
              </p>
              {renderSparkline()}
            </div>
          </div>

          {/* Icon */}
          {icon && (
            <div
              aria-hidden="true"
              className={`flex h-9 w-9 shrink-0 items-center justify-center rounded-xl transition-transform duration-200 group-hover:scale-105 sm:h-11 sm:w-11 sm:rounded-2xl ${iconBg}`}
            >
              {icon}
            </div>
          )}
        </div>

        {/* Subtitle & Trend Change Indicator */}
        {(subtitle || change) && (
          <div className="flex min-w-0 flex-wrap items-center gap-1.5 pt-1.5">
            {change && (
              <span className={`rounded-md px-1.5 py-0.5 text-[11px] font-bold ${changeColors}`}>
                {change}
              </span>
            )}
            {subtitle && <span className="min-w-0 break-words text-[11px] text-slate-500 font-medium sm:text-xs">{subtitle}</span>}
          </div>
        )}

        {/* Embedded Chart slot */}
        {chart && <div className="mt-3 pt-2">{chart}</div>}

        {/* Mini Progress Bar */}
        {renderProgress()}

        {/* Metadata items */}
        {renderMetadata()}
      </div>

      {/* Footer slot */}
      {footer && <div className="mt-3 pt-2.5 border-t border-slate-100">{footer}</div>}
    </div>
  )
}
