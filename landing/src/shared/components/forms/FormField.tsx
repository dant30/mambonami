import React from 'react'

interface FormFieldProps {
  label: string
  htmlFor?: string
  required?: boolean
  error?: string
  helperText?: string
  children: React.ReactNode
  className?: string
}

export const FormField: React.FC<FormFieldProps> = ({
  label,
  htmlFor,
  required,
  error,
  helperText,
  children,
  className = '',
}) => {
  return (
    <div className={`space-y-1.5 text-left ${className}`}>
      <label htmlFor={htmlFor} className="block text-[11px] font-bold uppercase tracking-[0.12em] text-muted-foreground">
        {label} {required && <span className="text-primary">*</span>}
      </label>
      {children}
      {error && <p className="text-xs font-medium text-destructive">{error}</p>}
      {helperText && !error && <p className="text-xs text-muted-foreground">{helperText}</p>}
    </div>
  )
}
