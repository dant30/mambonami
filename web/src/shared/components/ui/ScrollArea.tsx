import React from 'react';

interface ScrollAreaProps extends React.HTMLAttributes<HTMLDivElement> {}

export default function ScrollArea({ className = '', children, ...props }: ScrollAreaProps) {
  return (
    <div className={`overflow-auto rounded-2xl border border-slate-200 bg-white p-4 ${className}`} {...props}>
      {children}
    </div>
  );
}
