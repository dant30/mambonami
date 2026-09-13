import { createContext, useCallback, useContext, useEffect, useState, type ReactNode } from 'react'

export type ToastType = 'success' | 'error' | 'warning' | 'info'

export interface ToastMessage {
	id: string
	type: ToastType
	title: string
	message?: string
}

interface ToastContextValue {
	toasts: ToastMessage[]
	showToast(type: ToastType, title: string, message?: string): string
	success(title: string, message?: string): string
	error(title: string, message?: string): string
	warning(title: string, message?: string): string
	info(title: string, message?: string): string
	dismissToast(id: string): void
	clearToasts(): void
}

const ToastContext = createContext<ToastContextValue | undefined>(undefined)

export function ToastProvider({ children, duration = 4000 }: { children: ReactNode; duration?: number }) {
	const [toasts, setToasts] = useState<ToastMessage[]>([])

	const dismissToast = useCallback((id: string) => setToasts((current) => current.filter((toast) => toast.id !== id)), [])
	const showToast = useCallback((type: ToastType, title: string, message?: string) => {
		const id = `toast-${Date.now()}-${Math.random().toString(36).slice(2, 8)}`
		setToasts((current) => [...current, { id, type, title, message }])
		return id
	}, [])

	useEffect(() => {
		if (duration <= 0 || toasts.length === 0) return
		const timers = toasts.map((toast) => window.setTimeout(() => dismissToast(toast.id), duration))
		return () => timers.forEach(window.clearTimeout)
	}, [dismissToast, duration, toasts])

	const value = { toasts, showToast, success: (title: string, message?: string) => showToast('success', title, message), error: (title: string, message?: string) => showToast('error', title, message), warning: (title: string, message?: string) => showToast('warning', title, message), info: (title: string, message?: string) => showToast('info', title, message), dismissToast, clearToasts: () => setToasts([]) }

	return <ToastContext.Provider value={value}>{children}</ToastContext.Provider>
}

export function useToast() {
	const context = useContext(ToastContext)
	if (!context) throw new Error('useToast must be used inside ToastProvider')
	return context
}
