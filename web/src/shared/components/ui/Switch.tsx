import React from 'react';
import { cn } from '../../../lib/utils';

interface SwitchProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
}

export default function Switch({ label, className = '', ...props }: SwitchProps) {
  return (
    <label className={cn('inline-flex items-center gap-3 text-sm text-foreground', className)}>
      <input type="checkbox" className="peer sr-only" {...props} />
      <span className="relative inline-flex h-7 w-14 flex-shrink-0 items-center rounded-full border border-border bg-muted transition-colors duration-200 peer-checked:bg-primary">
        <span className="absolute left-1 top-1 h-5 w-5 rounded-full bg-white shadow transition-transform duration-200 peer-checked:translate-x-7" />
      </span>
      {label ? <span>{label}</span> : null}
    </label>
  );
}

