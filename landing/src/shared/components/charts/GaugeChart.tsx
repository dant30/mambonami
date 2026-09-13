import React from 'react'

export interface GaugeChartProps {
  value: number // 0 to 100 or min to max
  min?: number
  max?: number
  title?: string
  subtitle?: string
  label?: string
  size?: number
  thickness?: number
  color?: string
  trackColor?: string
  showMinMax?: boolean
  className?: string
}

export const GaugeChart: React.FC<GaugeChartProps> = ({
  value,
  min = 0,
  max = 100,
  title,
  subtitle,
  label,
  size = 180,
  thickness = 16,
  color = '#FF6B00',
  trackColor = '#E2E8F0',
  showMinMax = true,
  className = '',
}) => {
  const clampedValue = Math.min(Math.max(value, min), max)
  const percentage = (clampedValue - min) / (max - min)

  const radius = (size - thickness) / 2
  const cx = size / 2
  const cy = size / 2

  // Half circle arc: from 180deg to 0deg (left to right)
  const arcLength = Math.PI * radius
  const strokeDashoffset = arcLength * (1 - percentage)

  return (
    <div className={`rounded-2xl border border-slate-200 bg-white p-5 shadow-sm text-center ${className}`}>
      {(title || subtitle) && (
        <div className="mb-2 text-left">
          {title && <h3 className="text-sm font-bold text-slate-900">{title}</h3>}
          {subtitle && <p className="text-xs text-slate-500">{subtitle}</p>}
        </div>
      )}

      <div className="relative inline-flex flex-col items-center justify-center">
        <svg
          width={size}
          height={size / 2 + 20}
          viewBox={`0 0 ${size} ${size / 2 + 20}`}
          className="h-auto max-w-full overflow-visible"
        >
          {/* Background Track */}
          <path
            d={`M ${thickness / 2} ${cy} A ${radius} ${radius} 0 0 1 ${size - thickness / 2} ${cy}`}
            fill="none"
            stroke={trackColor}
            strokeWidth={thickness}
            strokeLinecap="round"
          />

          {/* Value Arc */}
          <path
            d={`M ${thickness / 2} ${cy} A ${radius} ${radius} 0 0 1 ${size - thickness / 2} ${cy}`}
            fill="none"
            stroke={color}
            strokeWidth={thickness}
            strokeLinecap="round"
            strokeDasharray={arcLength}
            strokeDashoffset={strokeDashoffset}
            className="transition-all duration-700 ease-out"
          />
        </svg>

        {/* Center Text Indicator */}
        <div className="absolute bottom-2 flex flex-col items-center">
          <span className="text-2xl font-black text-slate-900 tracking-tight">
            {clampedValue}%
          </span>
          {label && <span className="text-xs font-semibold text-slate-500">{label}</span>}
        </div>
      </div>

      {showMinMax && (
        <div className="flex justify-between text-[11px] font-bold text-slate-400 px-4 mt-1">
          <span>{min}%</span>
          <span>{max}%</span>
        </div>
      )}
    </div>
  )
}
