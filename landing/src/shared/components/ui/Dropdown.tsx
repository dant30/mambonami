import React, { useState, useRef, useEffect } from 'react'

export interface DropdownItem {
  id: string
  label: string
  icon?: React.ReactNode
  onClick?: () => void
  variant?: 'default' | 'danger' | 'warning'
  disabled?: boolean
  divider?: boolean
}

export interface DropdownProps {
  trigger: React.ReactNode
  items: DropdownItem[]
  align?: 'left' | 'right'
  className?: string
}

export const Dropdown: React.FC<DropdownProps> = ({
  trigger,
  items,
  align = 'right',
  className = '',
}) => {
  const [isOpen, setIsOpen] = useState(false)
  const dropdownRef = useRef<HTMLDivElement>(null)

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false)
      }
    }

    if (isOpen) {
      document.addEventListener('mousedown', handleClickOutside)
    }
    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [isOpen])

  return (
    <div ref={dropdownRef} className={`relative inline-block text-left ${className}`}>
      <div onClick={() => setIsOpen((prev) => !prev)} className="cursor-pointer">
        {trigger}
      </div>

      {isOpen && (
        <div
          className={`absolute mt-2 w-52 rounded-2xl border border-slate-200 bg-white p-1.5 shadow-xl z-50 animate-fade-in ${
            align === 'right' ? 'right-0' : 'left-0'
          }`}
          role="menu"
        >
          {items.map((item, index) => (
            <React.Fragment key={item.id || index}>
              {item.divider && <div className="my-1 border-t border-slate-100" />}
              <button
                type="button"
                disabled={item.disabled}
                onClick={() => {
                  if (!item.disabled && item.onClick) {
                    item.onClick()
                    setIsOpen(false)
                  }
                }}
                className={`w-full flex items-center gap-2.5 px-3 py-2 text-xs font-semibold rounded-xl transition-colors text-left ${
                  item.disabled
                    ? 'opacity-40 cursor-not-allowed text-slate-400'
                    : item.variant === 'danger'
                    ? 'text-rose-600 hover:bg-rose-50'
                    : item.variant === 'warning'
                    ? 'text-amber-600 hover:bg-amber-50'
                    : 'text-slate-700 hover:bg-slate-50 hover:text-slate-900'
                }`}
                role="menuitem"
              >
                {item.icon && <span className="shrink-0">{item.icon}</span>}
                <span className="flex-1">{item.label}</span>
              </button>
            </React.Fragment>
          ))}
        </div>
      )}
    </div>
  )
}
