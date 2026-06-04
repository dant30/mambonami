import React from 'react';
import { cn } from '../../../lib/utils';

interface RadioProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
}

const Radio = React.forwardRef<HTMLInputElement, RadioProps>(({ label, className = '', ...props }, ref) => (
  <label className={cn('inline-flex items-center gap-3 text-sm text-foreground', className)}>
    <input
      ref={ref}
      type="radio"
      className="h-5 w-5 rounded-full border border-border bg-input text-primary shadow-sm transition duration-200 focus:ring-2 focus:ring-ring focus:outline-none"
      {...props}
    />
    {label ? <span>{label}</span> : null}
  </label>
));

Radio.displayName = 'Radio';

export default Radio;

