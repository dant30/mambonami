import React, { useState } from 'react'

export interface PieChartSegment {
  label: string
  value: number
  color: string
}

export interface PieChartProps {
  data: PieChartSegment[]
  title?: string
  subtitle?: string
  donut?: boolean
  size?: number
  showLegend?: boolean
  valuePrefix?: string
  valueSuffix?: string
  className?: string
}

export const PieChart: React.FC<PieChartProps> = ({
  data,
  title,
  subtitle,
  donut = true,
  size = 200,
  showLegend = true,
  valuePrefix = '',
  valueSuffix = '',
  className = '',
}) => {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null)

  const total = data.reduce((acc, curr) => acc + curr.value, 0) || 1
  const radius = size / 2
  const strokeWidth = donut ? size * 0.22 : radius
  const innerRadius = radius - strokeWidth / 2
  const circumference = 2 * Math.PI * innerRadius

  let accumulatedPercent = 0

  return (
    <div className={`rounded-2xl border border-slate-200 bg-white p-5 shadow-sm ${className}`}>
      {(title || subtitle) && (
        <div className="mb-4">
          {title && <h3 className="text-sm font-bold text-slate-900">{title}</h3>}
          {subtitle && <p className="text-xs text-slate-500">{subtitle}</p>}
        </div>
      )}

      <div className="flex flex-col sm:flex-row items-center justify-around gap-6">
        {/* SVG Circle chart */}
        <div className="relative" style={{ width: size, height: size }}>
          <svg
            width={size}
            height={size}
            viewBox={`0 0 ${size} ${size}`}
            className="rotate-[-90deg] overflow-visible"
          >
            {data.map((item, index) => {
              const percent = item.value / total
              const strokeDasharray = `${percent * circumference} ${circumference}`
              const strokeDashoffset = -accumulatedPercent * circumference
              accumulatedPercent += percent

              const isHovered = hoveredIndex === index

              return (
                <circle
                  key={index}
                  cx={radius}
                  cy={radius}
                  r={innerRadius}
                  fill="transparent"
                  stroke={item.color}
                  strokeWidth={isHovered ? strokeWidth + 4 : strokeWidth}
                  strokeDasharray={strokeDasharray}
                  strokeDashoffset={strokeDashoffset}
                  className="transition-all duration-300 cursor-pointer"
                  style={{
                    opacity: hoveredIndex !== null && !isHovered ? 0.5 : 1,
                  }}
                  onMouseEnter={() => setHoveredIndex(index)}
                  onMouseLeave={() => setHoveredIndex(null)}
                />
              )
            })}
          </svg>

          {donut && (
            <div className="absolute inset-0 flex flex-col items-center justify-center pointer-events-none">
              <span className="text-xs font-medium text-slate-400">Total</span>
              <span className="text-lg font-black text-slate-900">
                {valuePrefix}{total.toLocaleString()}{valueSuffix}
              </span>
            </div>
          )}
        </div>

        {/* Legend */}
        {showLegend && (
          <div className="flex-1 space-y-2.5 min-w-[140px]">
            {data.map((item, index) => {
              const percent = Math.round((item.value / total) * 100)
              const isHovered = hoveredIndex === index

              return (
                <div
                  key={index}
                  className={`flex items-center justify-between gap-3 p-1.5 rounded-lg transition-colors cursor-pointer ${
                    isHovered ? 'bg-slate-50' : ''
                  }`}
                  onMouseEnter={() => setHoveredIndex(index)}
                  onMouseLeave={() => setHoveredIndex(null)}
                >
                  <div className="flex items-center gap-2">
                    <span
                      className="h-3 w-3 rounded-full shrink-0"
                      style={{ backgroundColor: item.color }}
                    />
                    <span className="text-xs font-semibold text-slate-700">{item.label}</span>
                  </div>
                  <div className="text-right">
                    <span className="text-xs font-bold text-slate-900">
                      {valuePrefix}{item.value.toLocaleString()}{valueSuffix}
                    </span>
                    <span className="text-[10px] text-slate-400 ml-1">({percent}%)</span>
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </div>
    </div>
  )
}
