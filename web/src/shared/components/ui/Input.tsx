import React from 'react';
import { cn } from '../../../lib/utils';

interface InputProps extends React.InputHTMLAttributes<HTMLInputElement> {}

const Input = React.forwardRef<HTMLInputElement, InputProps>(({ className = '', ...props }, ref) => (
  <input
    ref={ref}
    className={cn(
      'w-full min-h-[44px] rounded-2xl border border-border bg-input px-4 py-3 text-sm text-foreground placeholder:text-muted-foreground shadow-soft transition duration-200 focus:border-primary focus:outline-none focus:ring-2 focus:ring-ring',
      className,
    )}
    {...props}
  />
));

Input.displayName = 'Input';

export default Input;

