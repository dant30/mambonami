import React, { useState } from 'react'

export interface LineChartDataPoint {
  label: string
  value: number
  secondaryValue?: number
}

export interface LineChartProps {
  data: LineChartDataPoint[]
  title?: string
  subtitle?: string
  height?: number
  lineColor?: string
  secondaryLineColor?: string
  valuePrefix?: string
  valueSuffix?: string
  showArea?: boolean
  showDots?: boolean
  className?: string
}

export const LineChart: React.FC<LineChartProps> = ({
  data,
  title,
  subtitle,
  height = 240,
  lineColor = '#FF6B00',
  secondaryLineColor = '#0A2540',
  valuePrefix = '',
  valueSuffix = '',
  showArea = true,
  showDots = true,
  className = '',
}) => {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null)

  if (!data || data.length === 0) {
    return (
      <div className={`rounded-2xl border border-slate-200 bg-white p-5 shadow-sm text-center text-sm text-slate-400 ${className}`}>
        No data available for chart.
      </div>
    )
  }

  const allValues = [
    ...data.map((d) => d.value),
    ...data.map((d) => d.secondaryValue).filter((v): v is number => typeof v === 'number'),
  ]
  const maxValue = Math.max(...allValues, 1)
  const minValue = Math.min(0, ...allValues)
  const valueRange = maxValue - minValue || 1

  const width = 600
  const chartHeight = height
  const paddingX = 30
  const paddingY = 25
  const graphWidth = width - paddingX * 2
  const graphHeight = chartHeight - paddingY * 2

  const getCoordinates = (val: number, index: number) => {
    const x = paddingX + (index / (data.length - 1 || 1)) * graphWidth
    const normalizedY = (val - minValue) / valueRange
    const y = chartHeight - paddingY - normalizedY * graphHeight
    return { x, y }
  }

  const primaryPoints = data.map((d, i) => getCoordinates(d.value, i))
  const primaryPath = primaryPoints.reduce(
    (acc, curr, i) => (i === 0 ? `M ${curr.x} ${curr.y}` : `${acc} L ${curr.x} ${curr.y}`),
    '',
  )

  const hasSecondary = data.some((d) => typeof d.secondaryValue === 'number')
  const secondaryPoints = hasSecondary
    ? data.map((d, i) => getCoordinates(d.secondaryValue ?? 0, i))
    : []
  const secondaryPath = secondaryPoints.reduce(
    (acc, curr, i) => (i === 0 ? `M ${curr.x} ${curr.y}` : `${acc} L ${curr.x} ${curr.y}`),
    '',
  )

  // Area path closing
  const areaPath = `${primaryPath} L ${primaryPoints[primaryPoints.length - 1].x} ${chartHeight - paddingY} L ${primaryPoints[0].x} ${chartHeight - paddingY} Z`

  return (
    <div className={`rounded-2xl border border-slate-200 bg-white p-5 shadow-sm ${className}`}>
      {(title || subtitle) && (
        <div className="mb-4 flex items-start justify-between">
          <div>
            {title && <h3 className="text-sm font-bold text-slate-900">{title}</h3>}
            {subtitle && <p className="text-xs text-slate-500">{subtitle}</p>}
          </div>

          {hoveredIndex !== null && (
            <div className="rounded-lg bg-[#0A2540] px-2.5 py-1 text-xs font-bold text-white shadow-sm">
              {data[hoveredIndex].label}: {valuePrefix}
              {data[hoveredIndex].value.toLocaleString()}
              {valueSuffix}
              {typeof data[hoveredIndex].secondaryValue === 'number' && (
                <span className="text-slate-300 ml-2">
                  (Prev: {valuePrefix}
                  {data[hoveredIndex].secondaryValue?.toLocaleString()}
                  {valueSuffix})
                </span>
              )}
            </div>
          )}
        </div>
      )}

      <div className="relative w-full">
        <svg
          viewBox={`0 0 ${width} ${chartHeight}`}
          className="w-full overflow-visible"
          style={{ height: 'auto', maxHeight: chartHeight }}
        >
          <defs>
            <linearGradient id="lineAreaGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor={lineColor} stopOpacity="0.25" />
              <stop offset="100%" stopColor={lineColor} stopOpacity="0.0" />
            </linearGradient>
          </defs>

          {/* Grid lines */}
          <line
            x1={paddingX}
            y1={paddingY}
            x2={width - paddingX}
            y2={paddingY}
            stroke="#F1F5F9"
            strokeDasharray="4 4"
          />
          <line
            x1={paddingX}
            y1={chartHeight / 2}
            x2={width - paddingX}
            y2={chartHeight / 2}
            stroke="#F1F5F9"
            strokeDasharray="4 4"
          />
          <line
            x1={paddingX}
            y1={chartHeight - paddingY}
            x2={width - paddingX}
            y2={chartHeight - paddingY}
            stroke="#E2E8F0"
          />

          {/* Area Fill */}
          {showArea && <path d={areaPath} fill="url(#lineAreaGrad)" />}

          {/* Secondary Line (if present) */}
          {hasSecondary && (
            <path
              d={secondaryPath}
              fill="none"
              stroke={secondaryLineColor}
              strokeWidth="2"
              strokeDasharray="4 4"
              className="opacity-60"
            />
          )}

          {/* Primary Line */}
          <path
            d={primaryPath}
            fill="none"
            stroke={lineColor}
            strokeWidth="3"
            strokeLinecap="round"
            strokeLinejoin="round"
          />

          {/* Data Points */}
          {data.map((d, i) => {
            const pt = primaryPoints[i]
            const isHovered = hoveredIndex === i

            return (
              <g
                key={i}
                className="cursor-pointer"
                onMouseEnter={() => setHoveredIndex(i)}
                onMouseLeave={() => setHoveredIndex(null)}
              >
                {/* Vertical hover indicator bar */}
                {isHovered && (
                  <line
                    x1={pt.x}
                    y1={paddingY}
                    x2={pt.x}
                    y2={chartHeight - paddingY}
                    stroke="#CBD5E1"
                    strokeDasharray="2 2"
                  />
                )}

                {showDots && (
                  <circle
                    cx={pt.x}
                    cy={pt.y}
                    r={isHovered ? 6 : 4}
                    fill={isHovered ? '#FFFFFF' : lineColor}
                    stroke={lineColor}
                    strokeWidth={isHovered ? 3 : 2}
                    className="transition-all duration-200"
                  />
                )}

                {/* X Axis Label */}
                <text
                  x={pt.x}
                  y={chartHeight - 6}
                  textAnchor="middle"
                  fontSize="10"
                  fill="#94A3B8"
                  fontWeight={isHovered ? 'bold' : 'normal'}
                >
                  {d.label}
                </text>
              </g>
            )
          })}
        </svg>
      </div>
    </div>
  )
}
