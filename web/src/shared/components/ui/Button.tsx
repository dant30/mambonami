import React from 'react';
import { cn } from '../../../lib/utils';

interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'default' | 'primary' | 'secondary' | 'destructive' | 'ghost' | 'outline';
  size?: 'sm' | 'md' | 'lg' | 'icon';
}

const variantStyles = {
  default: 'bg-primary text-primary-foreground hover:bg-primary/95',
  primary: 'bg-blue-600 text-white hover:bg-blue-700',
  secondary: 'bg-secondary text-secondary-foreground hover:bg-secondary/90',
  destructive: 'bg-destructive text-destructive-foreground hover:bg-destructive/90',
  ghost: 'bg-transparent text-foreground hover:bg-muted/80',
  outline: 'border border-slate-300 bg-white text-slate-900 hover:border-slate-400 hover:bg-slate-50',
};

const sizeStyles = {
  sm: 'px-3 py-2 text-sm',
  md: 'px-4 py-2.5 text-sm',
  lg: 'px-5 py-3 text-base',
  icon: 'h-10 w-10 min-w-[2.5rem] rounded-full p-0 text-sm',
};

const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ variant = 'default', size = 'md', className = '', ...props }, ref) => (
    <button
      ref={ref}
      className={cn(
        'inline-flex items-center justify-center rounded-2xl font-semibold transition duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-60 shadow-soft',
        variantStyles[variant],
        sizeStyles[size],
        className,
      )}
      {...props}
    />
  ),
);

Button.displayName = 'Button';

export default Button;

