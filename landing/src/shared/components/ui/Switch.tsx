import React from 'react'

export interface SwitchProps {
  checked: boolean
  onChange: (checked: boolean) => void
  label?: string
  description?: string
  disabled?: boolean
  size?: 'sm' | 'md' | 'lg'
  className?: string
  id?: string
}

export const Switch: React.FC<SwitchProps> = ({
  checked,
  onChange,
  label,
  description,
  disabled = false,
  size = 'md',
  className = '',
  id,
}) => {
  const switchId = id || `switch-${Math.random().toString(36).slice(2, 7)}`

  const sizeTrackClasses = {
    sm: 'w-8 h-4',
    md: 'w-11 h-6',
    lg: 'w-14 h-7',
  }

  const sizeThumbClasses = {
    sm: 'h-3 w-3 translate-x-0.5',
    md: 'h-5 w-5 translate-x-0.5',
    lg: 'h-6 w-6 translate-x-0.5',
  }

  const sizeThumbCheckedClasses = {
    sm: 'translate-x-4',
    md: 'translate-x-5.5',
    lg: 'translate-x-7.5',
  }

  return (
    <div className={`flex items-start justify-between gap-3 ${className}`}>
      {(label || description) && (
        <div className="flex-1 text-left">
          {label && (
            <label
              htmlFor={switchId}
              className={`text-xs font-bold text-slate-900 cursor-pointer ${
                disabled ? 'opacity-50' : ''
              }`}
            >
              {label}
            </label>
          )}
          {description && (
            <p className={`text-[11px] text-slate-500 mt-0.5 ${disabled ? 'opacity-50' : ''}`}>
              {description}
            </p>
          )}
        </div>
      )}

      <button
        type="button"
        id={switchId}
        role="switch"
        aria-checked={checked}
        disabled={disabled}
        onClick={() => !disabled && onChange(!checked)}
        className={`relative inline-flex shrink-0 cursor-pointer rounded-full transition-colors duration-200 ease-in-out focus:outline-none focus:ring-2 focus:ring-[#FF6B00]/40 disabled:cursor-not-allowed disabled:opacity-50 ${
          sizeTrackClasses[size]
        } ${checked ? 'bg-[#FF6B00]' : 'bg-slate-200'}`}
      >
        <span
          className={`pointer-events-none inline-block rounded-full bg-white shadow-md transform ring-0 transition duration-200 ease-in-out my-auto ${
            sizeThumbClasses[size]
          } ${checked ? sizeThumbCheckedClasses[size] : ''}`}
        />
      </button>
    </div>
  )
}
