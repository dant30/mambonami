// frontend/src/shared/components/ui/tabs.tsx
import React, { useId, useRef } from 'react'

export type TabVariant = 'pills' | 'underline' | 'segmented' | 'cards'
export type TabSize = 'sm' | 'md' | 'lg'
export type TabBadgeVariant = 'default' | 'primary' | 'success' | 'warning' | 'neutral' | 'orange'

export interface TabItem<T extends string = string> {
  id: T
  label: React.ReactNode
  icon?: React.ComponentType<{ className?: string }> | React.ReactNode
  badge?: string | number | React.ReactNode
  badgeVariant?: TabBadgeVariant
  disabled?: boolean
  content?: React.ReactNode
  description?: string
}

export interface TabsProps<T extends string = string> {
  tabs: TabItem<T>[]
  activeTab: T
  onChange: (tabId: T) => void
  variant?: TabVariant
  size?: TabSize
  fullWidth?: boolean
  className?: string
  tabListClassName?: string
  panelClassName?: string
  children?: React.ReactNode
  ariaLabel?: string
  align?: 'left' | 'center' | 'right' | 'between'
}

export function Tabs<T extends string = string>({
  tabs,
  activeTab,
  onChange,
  variant = 'pills',
  size = 'md',
  fullWidth = false,
  className = '',
  tabListClassName = '',
  panelClassName = '',
  children,
  ariaLabel = 'Navigation Tabs',
  align = 'left',
}: TabsProps<T>) {
  const baseId = useId()
  const tabRefs = useRef<Map<T, HTMLButtonElement>>(new Map())

  // Keyboard navigation for accessible tablist
  const handleKeyDown = (e: React.KeyboardEvent, index: number) => {
    const enabledTabs = tabs.filter((t) => !t.disabled)
    const currentEnabledIndex = enabledTabs.findIndex((t) => t.id === tabs[index].id)

    if (e.key === 'ArrowRight' || e.key === 'ArrowDown') {
      e.preventDefault()
      const nextTab = enabledTabs[(currentEnabledIndex + 1) % enabledTabs.length]
      if (nextTab) {
        onChange(nextTab.id)
        tabRefs.current.get(nextTab.id)?.focus()
      }
    } else if (e.key === 'ArrowLeft' || e.key === 'ArrowUp') {
      e.preventDefault()
      const prevTab =
        enabledTabs[(currentEnabledIndex - 1 + enabledTabs.length) % enabledTabs.length]
      if (prevTab) {
        onChange(prevTab.id)
        tabRefs.current.get(prevTab.id)?.focus()
      }
    } else if (e.key === 'Home') {
      e.preventDefault()
      const firstTab = enabledTabs[0]
      if (firstTab) {
        onChange(firstTab.id)
        tabRefs.current.get(firstTab.id)?.focus()
      }
    } else if (e.key === 'End') {
      e.preventDefault()
      const lastTab = enabledTabs[enabledTabs.length - 1]
      if (lastTab) {
        onChange(lastTab.id)
        tabRefs.current.get(lastTab.id)?.focus()
      }
    }
  }

  // Size specific classes
  const sizeStyles = {
    sm: {
      tab: 'text-xs py-1.5 px-3 min-h-[36px] gap-1.5',
      icon: 'h-3.5 w-3.5',
      badge: 'text-[10px] px-1.5 py-0.2',
    },
    md: {
      tab: 'text-xs sm:text-sm py-2 px-3.5 min-h-[42px] gap-2',
      icon: 'h-4 w-4',
      badge: 'text-[11px] px-2 py-0.5',
    },
    lg: {
      tab: 'text-sm sm:text-base py-2.5 px-4.5 min-h-[48px] gap-2.5',
      icon: 'h-5 w-5',
      badge: 'text-xs px-2.5 py-0.5',
    },
  }[size]

  // Badge variant styling
  const getBadgeStyle = (bVariant: TabBadgeVariant = 'default', isActive: boolean) => {
    switch (bVariant) {
      case 'orange':
      case 'primary':
        return isActive
          ? 'bg-white text-[#FF6B00] font-black'
          : 'bg-orange-100 text-[#FF6B00] font-bold'
      case 'success':
        return isActive
          ? 'bg-emerald-100 text-emerald-800 font-black'
          : 'bg-emerald-50 text-emerald-700 font-bold'
      case 'warning':
        return isActive
          ? 'bg-amber-100 text-amber-900 font-black'
          : 'bg-amber-50 text-amber-700 font-bold'
      case 'neutral':
        return isActive
          ? 'bg-slate-700 text-slate-100 font-bold'
          : 'bg-slate-100 text-slate-600 font-semibold'
      case 'default':
      default:
        return isActive
          ? 'bg-white/20 text-white font-black'
          : 'bg-slate-200 text-slate-700 font-bold'
    }
  }

  // List alignment styling
  const alignStyles = {
    left: 'justify-start',
    center: 'justify-center',
    right: 'justify-end',
    between: 'justify-between',
  }[align]

  // Track container styling according to variant
  const getListContainerStyle = () => {
    switch (variant) {
      case 'segmented':
        return 'inline-flex items-center gap-1 rounded-2xl bg-slate-100/90 p-1.5 border border-slate-200/80 shadow-2xs'
      case 'underline':
        return 'flex items-center gap-1 sm:gap-2 border-b border-slate-200/90'
      case 'cards':
        return 'flex flex-wrap items-center gap-2'
      case 'pills':
      default:
        return 'flex items-center gap-1.5 sm:gap-2'
    }
  }

  // Individual Tab Button styling
  const getTabStyle = (tab: TabItem<T>, isActive: boolean) => {
    const disabledClass = tab.disabled
      ? 'opacity-40 cursor-not-allowed pointer-events-none'
      : 'cursor-pointer'

    if (variant === 'segmented') {
      return `relative flex items-center justify-center font-bold rounded-xl transition-all duration-150 ${sizeStyles.tab} ${
        isActive
          ? 'bg-white text-slate-900 shadow-xs ring-1 ring-slate-900/5'
          : 'text-slate-600 hover:text-slate-900 hover:bg-white/60'
      } ${disabledClass}`
    }

    if (variant === 'underline') {
      return `relative flex items-center justify-center font-bold transition-all duration-150 border-b-2 -mb-[2px] ${sizeStyles.tab} ${
        isActive
          ? 'border-[#FF6B00] text-[#0A2540]'
          : 'border-transparent text-slate-500 hover:text-slate-900 hover:border-slate-300'
      } ${disabledClass}`
    }

    if (variant === 'cards') {
      return `relative flex items-center justify-center font-bold rounded-2xl border transition-all duration-150 ${sizeStyles.tab} ${
        isActive
          ? 'border-[#FF6B00] bg-orange-50/50 text-[#0A2540] shadow-xs'
          : 'border-slate-200 bg-white text-slate-600 hover:border-slate-300 hover:bg-slate-50'
      } ${disabledClass}`
    }

    // Default 'pills'
    return `relative flex items-center justify-center font-bold rounded-xl transition-all duration-150 ${sizeStyles.tab} ${
      isActive
        ? 'bg-[#0A2540] text-white shadow-xs'
        : 'bg-transparent text-slate-600 hover:bg-slate-100 hover:text-slate-900'
    } ${disabledClass}`
  }

  const activeTabItem = tabs.find((t) => t.id === activeTab)

  return (
    <div className={`w-full ${className}`}>
      {/* Tab Navigation List */}
      <div className="overflow-x-auto no-scrollbar scroll-smooth py-1 -my-1">
        <div
          role="tablist"
          aria-label={ariaLabel}
          className={`${getListContainerStyle()} ${alignStyles} ${fullWidth ? 'w-full' : ''} ${tabListClassName}`}
        >
          {tabs.map((tab, idx) => {
            const isActive = tab.id === activeTab
            const tabId = `${baseId}-tab-${tab.id}`
            const panelId = `${baseId}-panel-${tab.id}`

            const renderIcon = () => {
              if (!tab.icon) return null
              if (React.isValidElement(tab.icon)) {
                return <span className="shrink-0">{tab.icon}</span>
              }
              const IconComp = tab.icon as React.ComponentType<{ className?: string }>
              return <IconComp className={`shrink-0 ${sizeStyles.icon}`} />
            }

            return (
              <button
                key={tab.id}
                ref={(el) => {
                  if (el) tabRefs.current.set(tab.id, el)
                  else tabRefs.current.delete(tab.id)
                }}
                id={tabId}
                role="tab"
                type="button"
                aria-selected={isActive}
                aria-controls={panelId}
                tabIndex={isActive ? 0 : -1}
                disabled={tab.disabled}
                onClick={() => onChange(tab.id)}
                onKeyDown={(e) => handleKeyDown(e, idx)}
                className={`${getTabStyle(tab, isActive)} ${fullWidth ? 'flex-1' : ''} whitespace-nowrap`}
              >
                {renderIcon()}
                <span className="truncate">{tab.label}</span>
                {tab.badge !== undefined && tab.badge !== null && (
                  <span
                    className={`inline-flex items-center justify-center rounded-full leading-none transition-colors ${sizeStyles.badge} ${getBadgeStyle(
                      tab.badgeVariant,
                      isActive,
                    )}`}
                  >
                    {tab.badge}
                  </span>
                )}
              </button>
            )
          })}
        </div>
      </div>

      {/* Tab Content Panels (if defined on tabs or passed as children) */}
      {activeTabItem?.content && (
        <div
          id={`${baseId}-panel-${activeTabItem.id}`}
          role="tabpanel"
          aria-labelledby={`${baseId}-tab-${activeTabItem.id}`}
          tabIndex={0}
          className={`mt-4 focus:outline-hidden ${panelClassName}`}
        >
          {activeTabItem.content}
        </div>
      )}

      {children && (
        <div className={`mt-4 ${panelClassName}`}>
          {children}
        </div>
      )}
    </div>
  )
}

export default Tabs
