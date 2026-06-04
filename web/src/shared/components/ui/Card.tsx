import React from 'react';

interface CardProps extends React.HTMLAttributes<HTMLDivElement> {}

export default function Card({ className = '', children, ...props }: CardProps) {
  return (
    <div className={`rounded-2xl border border-slate-200 bg-white p-4 shadow-sm ${className}`} {...props}>
      {children}
    </div>
  );
}

