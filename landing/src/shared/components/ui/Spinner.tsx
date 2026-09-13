import React from 'react'

export interface SpinnerProps {
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl'
  color?: 'orange' | 'navy' | 'white' | 'slate'
  label?: string
  className?: string
}

export const Spinner: React.FC<SpinnerProps> = ({
  size = 'md',
  color = 'orange',
  label,
  className = '',
}) => {
  const sizeMap = {
    xs: 'h-3.5 w-3.5 border-2',
    sm: 'h-4 w-4 border-2',
    md: 'h-6 w-6 border-2',
    lg: 'h-8 w-8 border-3',
    xl: 'h-12 w-12 border-4',
  }

  const colorMap = {
    orange: 'border-orange-200 border-t-[#FF6B00]',
    navy: 'border-slate-200 border-t-[#0A2540]',
    white: 'border-white/30 border-t-white',
    slate: 'border-slate-200 border-t-slate-600',
  }

  return (
    <div className={`inline-flex items-center gap-2.5 ${className}`}>
      <div
        className={`animate-spin rounded-full ${sizeMap[size]} ${colorMap[color]}`}
        role="status"
        aria-label={label || 'Loading...'}
      />
      {label && <span className="text-xs font-semibold text-slate-600">{label}</span>}
    </div>
  )
}
