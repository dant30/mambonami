import React, { useEffect, useId, useRef, useState } from 'react'
import { Check, ChevronDown } from 'lucide-react'
import { cn } from '../../../core/utils/cn'

export interface SelectOption {
  value: string
  label: string
  sublabel?: string
  disabled?: boolean
}

export interface SelectProps extends Omit<React.SelectHTMLAttributes<HTMLSelectElement>, 'onChange' | 'value' | 'children'> {
  label?: string
  options: (SelectOption | string)[]
  value: string
  onChange: (value: string) => void
  error?: string
  helperText?: string
  required?: boolean
  className?: string
  searchable?: boolean
}

function normalizeOption(option: SelectOption | string): SelectOption {
  return typeof option === 'string' ? { value: option, label: option } : option
}

export const Select: React.FC<SelectProps> = ({ label, options, value, onChange, error, helperText, required, className, disabled, searchable = false, id: providedId, name, ...props }) => {
  const generatedId = useId()
  const id = providedId || generatedId
  const listboxId = `${id}-options`
  const containerRef = useRef<HTMLDivElement>(null)
  const optionRefs = useRef<Array<HTMLButtonElement | null>>([])
  const [open, setOpen] = useState(false)
  const [searchTerm, setSearchTerm] = useState('')
  const normalizedOptions = options.map(normalizeOption)
  const filteredOptions = normalizedOptions.filter((option) => !searchTerm.trim() || option.label.toLowerCase().includes(searchTerm.trim().toLowerCase()) || option.value.toLowerCase().includes(searchTerm.trim().toLowerCase()))
  const selectedOption = normalizedOptions.find((option) => option.value === value)
  const selectedIndex = filteredOptions.findIndex((option) => option.value === value)
  const [highlightedIndex, setHighlightedIndex] = useState(Math.max(0, selectedIndex))

  useEffect(() => {
    if (!open) return
    const closeOnOutsideClick = (event: MouseEvent) => {
      if (!containerRef.current?.contains(event.target as Node)) setOpen(false)
    }
    document.addEventListener('mousedown', closeOnOutsideClick)
    return () => document.removeEventListener('mousedown', closeOnOutsideClick)
  }, [open])

  useEffect(() => {
    if (selectedIndex >= 0) setHighlightedIndex(selectedIndex)
  }, [selectedIndex])

  useEffect(() => {
    if (open) optionRefs.current[highlightedIndex]?.scrollIntoView({ block: 'nearest' })
  }, [highlightedIndex, open])

  const availableIndex = (optionsToSearch: SelectOption[], start: number, direction: 1 | -1) => {
    let index = start
    while (index >= 0 && index < optionsToSearch.length) {
      if (!optionsToSearch[index].disabled) return index
      index += direction
    }
    return -1
  }

  const choose = (option: SelectOption) => {
    if (option.disabled) return
    onChange(option.value)
    setOpen(false)
    setSearchTerm('')
  }

  const handleKeyDown = (event: React.KeyboardEvent<HTMLButtonElement>) => {
    if (disabled) return
    if (event.key === 'Escape') {
      setOpen(false)
      return
    }
    if (event.key === 'Enter' || event.key === ' ') {
      event.preventDefault()
      if (open) {
        const option = filteredOptions[highlightedIndex]
        if (option) choose(option)
      } else setOpen(true)
      return
    }
    if (event.key === 'ArrowDown' || event.key === 'ArrowUp') {
      event.preventDefault()
      const direction = event.key === 'ArrowDown' ? 1 : -1
      const nextIndex = availableIndex(filteredOptions, (open ? highlightedIndex : selectedIndex) + direction, direction)
      if (nextIndex >= 0) {
        setHighlightedIndex(nextIndex)
        setOpen(true)
      }
      return
    }
    if (event.key === 'Home' || event.key === 'End') {
      event.preventDefault()
      const direction = event.key === 'Home' ? 1 : -1
      const start = event.key === 'Home' ? 0 : filteredOptions.length - 1
      const nextIndex = availableIndex(filteredOptions, start, direction)
      if (nextIndex >= 0) {
        setHighlightedIndex(nextIndex)
        setOpen(true)
      }
    }
  }

  return (
    <div ref={containerRef} className={cn('relative space-y-1 text-left', className)}>
      {label && <label htmlFor={id} className="block text-xs font-bold uppercase tracking-wider text-slate-700">{label} {required && <span className="text-[#FF6B00]">*</span>}</label>}
      <button id={id} type="button" disabled={disabled} onClick={() => setOpen((current) => !current)} onKeyDown={handleKeyDown} role="combobox" aria-expanded={open} aria-controls={listboxId} aria-haspopup="listbox" aria-invalid={Boolean(error)} aria-required={required} aria-label={props['aria-label']} title={props.title} className={cn('flex w-full items-center justify-between gap-3 rounded-xl border bg-slate-50 px-3.5 py-2.5 text-left text-sm font-medium text-slate-900 shadow-sm transition', 'focus:bg-white focus:outline-none focus:ring-2 focus:ring-[#0A2540]/20', error ? 'border-rose-500 focus:border-rose-500' : open ? 'border-[#0A2540] bg-white' : 'border-slate-300', disabled ? 'cursor-not-allowed opacity-50' : 'cursor-pointer hover:border-slate-400')}>
        <span className={cn('min-w-0 truncate', !selectedOption && 'text-slate-400')}>{selectedOption?.label || 'Select an option'}</span>
        <ChevronDown className={cn('h-4 w-4 shrink-0 text-slate-400 transition-transform', open && 'rotate-180 text-[#0A2540]')} />
      </button>
      {name && <input type="hidden" name={name} value={value} required={required} disabled={disabled} />}
      {open && !disabled && (
        <div id={listboxId} role="listbox" aria-label={label || 'Options'} className="absolute left-0 right-0 z-50 mt-2 max-h-64 overflow-y-auto rounded-xl border border-slate-200 bg-white p-1.5 shadow-xl shadow-slate-900/10">
          {searchable && <input autoFocus type="search" value={searchTerm} onChange={(event) => { setSearchTerm(event.target.value); setHighlightedIndex(0) }} placeholder="Search options..." aria-label={`Search ${label || 'options'}`} className="mb-1.5 w-full rounded-lg border border-slate-200 px-3 py-2 text-sm outline-none focus:border-[#0A2540]" />}
          {filteredOptions.length ? filteredOptions.map((option, index) => (
            <button ref={(element) => { optionRefs.current[index] = element }} key={`${option.value}-${index}`} type="button" role="option" aria-selected={option.value === value} aria-disabled={option.disabled} disabled={option.disabled} onMouseEnter={() => !option.disabled && setHighlightedIndex(index)} onClick={() => choose(option)} className={cn('flex w-full items-center justify-between gap-3 rounded-lg px-3 py-2.5 text-left text-sm transition', option.disabled ? 'cursor-not-allowed text-slate-300' : 'cursor-pointer text-slate-700 hover:bg-orange-50 hover:text-slate-900', highlightedIndex === index && !option.disabled && 'bg-slate-100', option.value === value && 'font-semibold text-[#0A2540]')}>
              <span className="min-w-0"><span className="block truncate">{option.label}</span>{option.sublabel && <span className="block truncate text-xs font-normal text-slate-400">{option.sublabel}</span>}</span>
              {option.value === value && <Check className="h-4 w-4 shrink-0 text-[#FF6B00]" />}
            </button>
          )) : <p className="px-3 py-2 text-sm text-slate-400">No options available</p>}
        </div>
      )}
      {error && <p className="text-[11px] font-medium text-rose-600">{error}</p>}
      {helperText && !error && <p className="text-[11px] text-slate-500">{helperText}</p>}
    </div>
  )
}
