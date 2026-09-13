import React, { useState, useEffect, useRef } from 'react'
import type { FC } from 'react'
import { CheckCircle2, AlertCircle, Info, AlertTriangle, X } from 'lucide-react'

export interface Toast {
  id: string | number
  type: 'success' | 'error' | 'warning' | 'info'
  title: string
  message: string
}

interface ToastContainerProps {
  toasts?: Toast[]
  removeToast?: (id: Toast['id']) => void
}

type ToastListener = (toast: Toast) => void
const listeners = new Set<ToastListener>()

export const toast = {
  show: (type: Toast['type'], title: string, message: string) => {
    const newToast: Toast = {
      id: `toast-${Date.now()}-${Math.random().toString(36).slice(2, 7)}`,
      type,
      title,
      message,
    }
    listeners.forEach((listener) => listener(newToast))
  },
  success: (title: string, message = '') => toast.show('success', title, message),
  error: (title: string, message = '') => toast.show('error', title, message),
  warning: (title: string, message = '') => toast.show('warning', title, message),
  info: (title: string, message = '') => toast.show('info', title, message),
}

export const ToastContainer: FC<ToastContainerProps> = ({ toasts: propToasts, removeToast: propRemoveToast }) => {
  const [internalToasts, setInternalToasts] = useState<Toast[]>([])
  const timers = useRef(new Map<Toast['id'], ReturnType<typeof setTimeout>>())

  const removeInternalToast = (id: Toast['id']) => {
    const timer = timers.current.get(id)
    if (timer) {
      clearTimeout(timer)
      timers.current.delete(id)
    }
    setInternalToasts((prev) => prev.filter((toast) => toast.id !== id))
  }

  useEffect(() => {
    const handleNewToast: ToastListener = (newToast) => {
      setInternalToasts((prev) => [...prev, newToast])
      const timer = setTimeout(() => removeInternalToast(newToast.id), 4000)
      timers.current.set(newToast.id, timer)
    }

    listeners.add(handleNewToast)
    return () => {
      listeners.delete(handleNewToast)
      timers.current.forEach((timer) => clearTimeout(timer))
      timers.current.clear()
    }
  }, [])

  const rawToasts = propToasts !== undefined ? propToasts : internalToasts
  const activeToasts = Array.isArray(rawToasts) ? rawToasts : []
  const handleRemove = propRemoveToast ?? removeInternalToast

  if (!activeToasts || activeToasts.length === 0) return null

  return (
    <div className="pointer-events-none fixed bottom-4 right-4 z-50 flex w-full max-w-sm flex-col gap-2" aria-live="polite" aria-atomic="false">
      {activeToasts.map((t) => (
        <div
          key={t.id}
          role={t.type === 'error' ? 'alert' : 'status'}
          className={`pointer-events-auto flex items-start gap-3 rounded-2xl border p-4 shadow-xl backdrop-blur-md transition-all duration-300 animate-slide-up ${
            t.type === 'success'
              ? 'border-primary/30 bg-primary-dark text-primary-foreground'
              : t.type === 'error'
              ? 'border-destructive/40 bg-destructive text-destructive-foreground'
              : t.type === 'warning'
              ? 'border-secondary/40 bg-secondary text-secondary-foreground'
              : 'border-border bg-card text-card-foreground'
          }`}
        >
          <div className="mt-0.5 shrink-0">
            {t.type === 'success' && <CheckCircle2 className="h-5 w-5 text-primary" />}
            {t.type === 'error' && <AlertCircle className="h-5 w-5 text-destructive-foreground" />}
            {t.type === 'warning' && <AlertTriangle className="h-5 w-5 text-secondary-foreground" />}
            {t.type === 'info' && <Info className="h-5 w-5 text-primary" />}
          </div>
          <div className="flex-1 text-left">
            <h5 className="text-xs font-bold">{t.title}</h5>
            {t.message && <p className="mt-0.5 text-xs leading-relaxed opacity-80">{t.message}</p>}
          </div>
          <button
            type="button"
            onClick={() => handleRemove(t.id)}
            aria-label={`Dismiss ${t.title}`}
            className="p-1 opacity-75 transition-opacity hover:opacity-100"
          >
            <X className="h-4 w-4" />
          </button>
        </div>
      ))}
    </div>
  )
}
