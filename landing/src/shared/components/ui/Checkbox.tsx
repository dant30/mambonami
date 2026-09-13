import React from 'react'
import { Check, Minus } from 'lucide-react'

export interface CheckboxProps {
  checked: boolean
  onChange: (checked: boolean) => void
  indeterminate?: boolean
  label?: React.ReactNode
  description?: string
  error?: string
  disabled?: boolean
  className?: string
  id?: string
}

export const Checkbox: React.FC<CheckboxProps> = ({
  checked,
  onChange,
  indeterminate = false,
  label,
  description,
  error,
  disabled = false,
  className = '',
  id,
}) => {
  const checkboxId = id || `checkbox-${Math.random().toString(36).slice(2, 7)}`

  return (
    <div className={`space-y-1 ${className}`}>
      <div className="flex items-start gap-2.5">
        <button
          type="button"
          id={checkboxId}
          role="checkbox"
          aria-checked={indeterminate ? 'mixed' : checked}
          disabled={disabled}
          onClick={() => !disabled && onChange(!checked)}
          className={`flex h-4 w-4 shrink-0 items-center justify-center rounded-md border transition-colors mt-0.5 focus:outline-none focus:ring-2 focus:ring-[#FF6B00]/40 disabled:cursor-not-allowed disabled:opacity-50 ${
            checked || indeterminate
              ? 'border-[#FF6B00] bg-[#FF6B00] text-white'
              : 'border-slate-300 bg-white hover:border-slate-400'
          }`}
        >
          {indeterminate ? (
            <Minus className="h-3 w-3 stroke-[3]" />
          ) : checked ? (
            <Check className="h-3 w-3 stroke-[3]" />
          ) : null}
        </button>

        {(label || description) && (
          <div className="text-left select-none">
            {label && (
              <label
                htmlFor={checkboxId}
                className={`text-xs font-semibold text-slate-800 cursor-pointer ${
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
      </div>

      {error && <p className="text-xs text-rose-600 font-medium pl-6.5">{error}</p>}
    </div>
  )
}
