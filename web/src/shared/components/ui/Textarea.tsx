import React from 'react';
import { cn } from '../../../lib/utils';

interface TextareaProps extends React.TextareaHTMLAttributes<HTMLTextAreaElement> {}

export default function Textarea({ className = '', ...props }: TextareaProps) {
  return (
    <textarea
      className={cn(
        'min-h-[120px] w-full rounded-2xl border border-border bg-input px-4 py-3 text-sm text-foreground placeholder:text-muted-foreground shadow-soft transition duration-200 focus:border-primary focus:outline-none focus:ring-2 focus:ring-ring resize-vertical',
        className,
      )}
      {...props}
    />
  );
}

