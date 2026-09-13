import React from 'react'
import { Loader2 } from 'lucide-react'

export interface FormActionsProps {
  submitLabel?: string
  cancelLabel?: string
  loading?: boolean
  disabled?: boolean
  onCancel?: () => void
  align?: 'left' | 'center' | 'right' | 'between'
  className?: string
  extraActions?: React.ReactNode
  fullWidth?: boolean
  formId?: string
}

export const FormActions: React.FC<FormActionsProps> = ({
  submitLabel = 'Save changes',
  cancelLabel = 'Cancel',
  loading = false,
  disabled = false,
  onCancel,
  align = 'right',
  className = '',
  extraActions,
  fullWidth = false,
  formId,
}) => {
  const alignmentClasses = {
    left: 'justify-start',
    center: 'justify-center',
    right: 'justify-end',
    between: 'justify-between',
  }

  return (
    <div
      className={`flex flex-wrap items-center gap-3 border-t border-border pt-5 ${alignmentClasses[align]} ${className}`}
    >
      {extraActions && <div className="mr-auto">{extraActions}</div>}

      {onCancel && (
        <button
          type="button"
          onClick={onCancel}
          disabled={loading || disabled}
          className="rounded-xl border border-border bg-card px-4 py-2.5 text-xs font-bold text-foreground transition-colors hover:bg-muted disabled:opacity-50"
        >
          {cancelLabel}
        </button>
      )}

      <button
        type="submit"
        form={formId}
        disabled={loading || disabled}
        className={`inline-flex items-center justify-center gap-2 rounded-xl bg-primary px-5 py-2.5 text-xs font-bold text-primary-foreground shadow-sm transition-colors hover:bg-primary-dark disabled:opacity-50 ${fullWidth ? 'w-full' : ''}`}
      >
        {loading && <Loader2 className="h-3.5 w-3.5 animate-spin" />}
        {submitLabel}
      </button>
    </div>
  )
}
