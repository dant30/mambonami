import React, { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react'
import { AlertCircle, AlertTriangle, ArrowRight, CheckCircle2, Info, ShoppingCart, X } from 'lucide-react'

export type SnackBarType = 'success' | 'error' | 'warning' | 'info' | 'cart'

export interface SnackBarOptions {
	type?: SnackBarType
	duration?: number
	actionLabel?: string
	onAction?: () => void
}

interface SnackBarItem extends SnackBarOptions {
	id: string
	message: string
}

interface SnackBarContextValue {
	show(message: string, options?: SnackBarOptions): string
	success(message: string, options?: Omit<SnackBarOptions, 'type'>): string
	error(message: string, options?: Omit<SnackBarOptions, 'type'>): string
	warning(message: string, options?: Omit<SnackBarOptions, 'type'>): string
	info(message: string, options?: Omit<SnackBarOptions, 'type'>): string
	cart(message: string, options?: Omit<SnackBarOptions, 'type'>): string
	dismiss(id: string): void
	dismissAll(): void
}

const SnackBarContext = createContext<SnackBarContextValue | null>(null)
const DEFAULT_DURATION = 4000

function generateId() {
	return `${Date.now()}-${Math.random().toString(36).slice(2, 9)}`
}

function getSnackbarConfig(type: SnackBarType) {
	switch (type) {
		case 'success': return { icon: CheckCircle2, iconClass: 'bg-emerald-100 text-emerald-700 dark:bg-emerald-950 dark:text-emerald-400', progressClass: 'bg-emerald-500' }
		case 'error': return { icon: AlertCircle, iconClass: 'bg-red-100 text-red-700 dark:bg-red-950 dark:text-red-400', progressClass: 'bg-red-500' }
		case 'warning': return { icon: AlertTriangle, iconClass: 'bg-amber-100 text-amber-700 dark:bg-amber-950 dark:text-amber-400', progressClass: 'bg-amber-500' }
		case 'cart': return { icon: ShoppingCart, iconClass: 'bg-lime-100 text-lime-700 dark:bg-lime-950 dark:text-lime-400', progressClass: 'bg-lime-500' }
		default: return { icon: Info, iconClass: 'bg-blue-100 text-blue-700 dark:bg-blue-950 dark:text-blue-400', progressClass: 'bg-blue-500' }
	}
}

function SnackBar({ item, onDismiss }: { item: SnackBarItem; onDismiss: (id: string) => void }) {
	const config = getSnackbarConfig(item.type ?? 'info')
	const Icon = config.icon
	const duration = item.duration ?? DEFAULT_DURATION

	useEffect(() => {
		if (duration <= 0) return
		const timeout = window.setTimeout(() => onDismiss(item.id), duration)
		return () => window.clearTimeout(timeout)
	}, [duration, item.id, onDismiss])

	return <div role={item.type === 'error' ? 'alert' : 'status'} aria-live="polite" className="pointer-events-auto relative w-full max-w-md overflow-hidden rounded-2xl border border-slate-200/80 bg-white shadow-2xl shadow-slate-950/10 backdrop-blur-xl dark:border-slate-800 dark:bg-slate-950 animate-in slide-in-from-right-5 fade-in duration-300">
		<div className="flex items-start gap-3 p-4">
			<div className={`flex h-10 w-10 shrink-0 items-center justify-center rounded-xl ${config.iconClass}`}><Icon size={19} strokeWidth={2.2} /></div>
			<div className="min-w-0 flex-1 pt-0.5"><p className="text-sm font-semibold leading-5 text-slate-900 dark:text-white">{item.message}</p>{item.actionLabel && <button type="button" onClick={() => { item.onAction?.(); onDismiss(item.id) }} className="mt-2 inline-flex items-center gap-1.5 text-xs font-bold text-emerald-700 transition hover:text-emerald-800 dark:text-lime-400 dark:hover:text-lime-300">{item.actionLabel}<ArrowRight size={13} /></button>}</div>
			<button type="button" aria-label="Dismiss notification" onClick={() => onDismiss(item.id)} className="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg text-slate-400 transition hover:bg-slate-100 hover:text-slate-700 dark:hover:bg-slate-800 dark:hover:text-white"><X size={16} /></button>
		</div>
		{duration > 0 && <div className="absolute bottom-0 left-0 h-0.5 w-full bg-slate-100 dark:bg-slate-900"><div className={`h-full ${config.progressClass}`} style={{ animation: `snackbar-progress ${duration}ms linear forwards` }} /></div>}
	</div>
}

export function SnackBarProvider({ children }: { children: React.ReactNode }) {
	const [items, setItems] = useState<SnackBarItem[]>([])
	const dismiss = useCallback((id: string) => setItems((current) => current.filter((item) => item.id !== id)), [])
	const dismissAll = useCallback(() => setItems([]), [])
	const show = useCallback((message: string, options: SnackBarOptions = {}) => {
		const item: SnackBarItem = { id: generateId(), message, type: options.type ?? 'info', duration: options.duration ?? DEFAULT_DURATION, actionLabel: options.actionLabel, onAction: options.onAction }
		setItems((current) => [...current.slice(-3), item])
		return item.id
	}, [])
	const success = useCallback((message: string, options: Omit<SnackBarOptions, 'type'> = {}) => show(message, { ...options, type: 'success' }), [show])
	const error = useCallback((message: string, options: Omit<SnackBarOptions, 'type'> = {}) => show(message, { ...options, type: 'error' }), [show])
	const warning = useCallback((message: string, options: Omit<SnackBarOptions, 'type'> = {}) => show(message, { ...options, type: 'warning' }), [show])
	const info = useCallback((message: string, options: Omit<SnackBarOptions, 'type'> = {}) => show(message, { ...options, type: 'info' }), [show])
	const cart = useCallback((message: string, options: Omit<SnackBarOptions, 'type'> = {}) => show(message, { ...options, type: 'cart' }), [show])
	const value = useMemo<SnackBarContextValue>(() => ({ show, success, error, warning, info, cart, dismiss, dismissAll }), [show, success, error, warning, info, cart, dismiss, dismissAll])

	return <SnackBarContext.Provider value={value}>
		{children}
		<div className="pointer-events-none fixed inset-x-4 bottom-4 z-[100] flex flex-col items-end gap-3 sm:left-auto sm:right-6 sm:max-w-md">{items.map((item) => <SnackBar key={item.id} item={item} onDismiss={dismiss} />)}</div>
		<style>{'@keyframes snackbar-progress { from { width: 100%; } to { width: 0%; } }'}</style>
	</SnackBarContext.Provider>
}

export function useSnackbar() {
	const context = useContext(SnackBarContext)
	if (!context) throw new Error('useSnackbar must be used inside SnackBarProvider')
	return context
}

export default SnackBar
