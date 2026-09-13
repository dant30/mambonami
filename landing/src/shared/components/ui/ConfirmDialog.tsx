import React from 'react'
import { AlertTriangle, Info, Loader2, X } from 'lucide-react'

export interface ConfirmDialogProps {
  isOpen: boolean
  title: string
  message: React.ReactNode
  confirmLabel?: string
  cancelLabel?: string
  variant?: 'danger' | 'warning' | 'primary'
  loading?: boolean
  onConfirm: () => void
  onCancel: () => void
}

export const ConfirmDialog: React.FC<ConfirmDialogProps> = ({
  isOpen,
  title,
  message,
  confirmLabel = 'Confirm',
  cancelLabel = 'Cancel',
  variant = 'primary',
  loading = false,
  onConfirm,
  onCancel,
}) => {
  if (!isOpen) return null

  const variantStyles = {
    danger: {
      icon: <AlertTriangle className="h-6 w-6 text-rose-600" />,
      iconBg: 'bg-rose-50',
      btn: 'bg-rose-600 hover:bg-rose-700 text-white',
    },
    warning: {
      icon: <AlertTriangle className="h-6 w-6 text-amber-600" />,
      iconBg: 'bg-amber-50',
      btn: 'bg-amber-600 hover:bg-amber-700 text-white',
    },
    primary: {
      icon: <Info className="h-6 w-6 text-[#FF6B00]" />,
      iconBg: 'bg-orange-50',
      btn: 'bg-[#FF6B00] hover:bg-[#E55F00] text-white',
    },
  }

  const currentVariant = variantStyles[variant]

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-xs animate-fade-in"
      role="dialog"
      aria-modal="true"
    >
      <div className="w-full max-w-md rounded-2xl border border-slate-200 bg-white p-6 shadow-2xl transition-all">
        <div className="flex items-start gap-4">
          <div className={`rounded-xl p-3 shrink-0 ${currentVariant.iconBg}`}>
            {currentVariant.icon}
          </div>

          <div className="flex-1">
            <h3 className="text-base font-black text-slate-900">{title}</h3>
            <div className="mt-2 text-xs text-slate-600 leading-relaxed">
              {message}
            </div>
          </div>

          <button
            type="button"
            onClick={onCancel}
            disabled={loading}
            className="text-slate-400 hover:text-slate-600 p-1 rounded-lg transition-colors"
          >
            <X className="h-4 w-4" />
          </button>
        </div>

        <div className="mt-6 flex items-center justify-end gap-3 pt-4 border-t border-slate-100">
          <button
            type="button"
            onClick={onCancel}
            disabled={loading}
            className="rounded-xl border border-slate-200 bg-white px-4 py-2 text-xs font-bold text-slate-700 hover:bg-slate-50 transition-colors disabled:opacity-50"
          >
            {cancelLabel}
          </button>

          <button
            type="button"
            onClick={onConfirm}
            disabled={loading}
            className={`inline-flex items-center gap-2 rounded-xl px-4 py-2 text-xs font-bold shadow-sm transition-colors disabled:opacity-50 ${currentVariant.btn}`}
          >
            {loading && <Loader2 className="h-3.5 w-3.5 animate-spin" />}
            {confirmLabel}
          </button>
        </div>
      </div>
    </div>
  )
}
