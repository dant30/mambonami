import React, { useState } from 'react'

export interface BarChartDataPoint {
  label: string
  value: number
  color?: string
  formattedValue?: string
}

export interface BarChartProps {
  data: BarChartDataPoint[]
  title?: string
  subtitle?: string
  height?: number
  horizontal?: boolean
  showValues?: boolean
  valuePrefix?: string
  valueSuffix?: string
  accentColor?: string
  className?: string
}

export const BarChart: React.FC<BarChartProps> = ({
  data,
  title,
  subtitle,
  height = 240,
  horizontal = false,
  showValues = true,
  valuePrefix = '',
  valueSuffix = '',
  accentColor = '#FF6B00',
  className = '',
}) => {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null)

  const maxValue = Math.max(...data.map((d) => d.value), 1)

  if (horizontal) {
    return (
      <div className={`rounded-2xl border border-slate-200 bg-white p-5 shadow-sm ${className}`}>
        {(title || subtitle) && (
          <div className="mb-4">
            {title && <h3 className="text-sm font-bold text-slate-900">{title}</h3>}
            {subtitle && <p className="text-xs text-slate-500">{subtitle}</p>}
          </div>
        )}

        <div className="space-y-3">
          {data.map((item, idx) => {
            const percentage = (item.value / maxValue) * 100
            const isHovered = hoveredIndex === idx
            const barColor = item.color || accentColor

            return (
              <div
                key={idx}
                className="group relative cursor-pointer"
                onMouseEnter={() => setHoveredIndex(idx)}
                onMouseLeave={() => setHoveredIndex(null)}
              >
                <div className="flex items-center justify-between text-xs mb-1">
                  <span className={`font-semibold transition-colors ${isHovered ? 'text-[#FF6B00]' : 'text-slate-700'}`}>
                    {item.label}
                  </span>
                  <span className="font-bold text-slate-900">
                    {item.formattedValue ?? `${valuePrefix}${item.value.toLocaleString()}${valueSuffix}`}
                  </span>
                </div>

                <div className="h-3 w-full overflow-hidden rounded-full bg-slate-100">
                  <div
                    className="h-full rounded-full transition-all duration-500 ease-out"
                    style={{
                      width: `${Math.max(percentage, 2)}%`,
                      backgroundColor: barColor,
                      opacity: hoveredIndex !== null && !isHovered ? 0.45 : 1,
                    }}
                  />
                </div>
              </div>
            )
          })}
        </div>
      </div>
    )
  }

  return (
    <div className={`rounded-2xl border border-slate-200 bg-white p-5 shadow-sm ${className}`}>
      {(title || subtitle) && (
        <div className="mb-6 flex items-start justify-between">
          <div>
            {title && <h3 className="text-sm font-bold text-slate-900">{title}</h3>}
            {subtitle && <p className="text-xs text-slate-500">{subtitle}</p>}
          </div>
          {hoveredIndex !== null && (
            <div className="rounded-lg bg-[#0A2540] px-2.5 py-1 text-xs font-bold text-white shadow-sm">
              {data[hoveredIndex].label}: {data[hoveredIndex].formattedValue ?? `${valuePrefix}${data[hoveredIndex].value.toLocaleString()}${valueSuffix}`}
            </div>
          )}
        </div>
      )}

      <div className="relative flex items-end justify-between gap-2 pt-6" style={{ height }}>
        {/* Horizontal grid lines */}
        <div className="absolute inset-0 flex flex-col justify-between pointer-events-none opacity-30">
          <div className="border-b border-dashed border-slate-300 w-full" />
          <div className="border-b border-dashed border-slate-300 w-full" />
          <div className="border-b border-dashed border-slate-300 w-full" />
        </div>

        {data.map((item, idx) => {
          const percentage = (item.value / maxValue) * 100
          const isHovered = hoveredIndex === idx
          const barColor = item.color || accentColor

          return (
            <div
              key={idx}
              className="group relative flex flex-1 flex-col items-center h-full justify-end"
              onMouseEnter={() => setHoveredIndex(idx)}
              onMouseLeave={() => setHoveredIndex(null)}
            >
              {/* Tooltip on bar hover */}
              {isHovered && (
                <div className="absolute -top-7 z-10 whitespace-nowrap rounded-md bg-slate-900 px-2 py-0.5 text-[10px] font-bold text-white shadow-md">
                  {item.formattedValue ?? `${valuePrefix}${item.value.toLocaleString()}${valueSuffix}`}
                </div>
              )}

              {/* The bar */}
              <div
                className="w-full max-w-[42px] rounded-t-xl transition-all duration-300"
                style={{
                  height: `${Math.max(percentage, 4)}%`,
                  backgroundColor: barColor,
                  opacity: hoveredIndex !== null && !isHovered ? 0.4 : 1,
                  transform: isHovered ? 'scaleY(1.03)' : 'scaleY(1)',
                  transformOrigin: 'bottom',
                }}
              />

              {/* Label */}
              <div className="mt-2 text-center">
                <p className="truncate text-[10px] font-semibold text-slate-500 max-w-[60px]">
                  {item.label}
                </p>
                {showValues && (
                  <p className="text-[10px] font-bold text-slate-800">
                    {item.formattedValue ?? `${valuePrefix}${item.value.toLocaleString()}${valueSuffix}`}
                  </p>
                )}
              </div>
            </div>
          )
        })}
      </div>
    </div>
  )
}
