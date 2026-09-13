import React from 'react'

export interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'outline' | 'ghost' | 'navy' | 'danger'
  size?: 'sm' | 'md' | 'lg'
  isLoading?: boolean
  leftIcon?: React.ReactNode
  rightIcon?: React.ReactNode
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(({
  children,
  variant = 'primary',
  size = 'md',
  isLoading = false,
  leftIcon,
  rightIcon,
  className = '',
  disabled,
  ...props
}, ref) => {
  const baseStyles = 'inline-flex items-center justify-center font-medium transition-all duration-150 select-none disabled:opacity-50 disabled:cursor-not-allowed focus:outline-none focus:ring-2 focus:ring-offset-2'

  const sizeStyles = {
    sm: 'text-xs px-3 py-1.5 rounded-lg gap-1.5',
    md: 'text-sm px-4 py-2 rounded-xl gap-2',
    lg: 'text-base px-6 py-3 rounded-xl gap-2.5 font-semibold',
  }[size]

  const variantStyles = {
    primary: 'bg-primary hover:bg-primary-dark text-primary-foreground shadow-sm hover:shadow focus:ring-primary',
    navy: 'bg-primary-dark hover:bg-[#041f2c] text-primary-foreground shadow-sm focus:ring-primary-dark',
    secondary: 'bg-secondary hover:bg-secondary/90 text-secondary-foreground shadow-sm hover:shadow focus:ring-secondary',
    outline: 'border border-border bg-transparent text-foreground hover:bg-muted focus:ring-border',
    ghost: 'bg-transparent text-foreground hover:bg-muted hover:text-foreground focus:ring-muted',
    danger: 'bg-destructive hover:bg-destructive/90 text-destructive-foreground focus:ring-destructive',
  }[variant]

  return (
    <button
      ref={ref}
      className={`${baseStyles} ${sizeStyles} ${variantStyles} ${className}`}
      disabled={disabled || isLoading}
      {...props}
    >
      {isLoading ? (
        <span className="h-4 w-4 animate-spin rounded-full border-2 border-current border-t-transparent" />
      ) : (
        leftIcon
      )}
      {children}
      {!isLoading && rightIcon}
    </button>
  )
})

Button.displayName = 'Button'
