import React from 'react';

interface ResizableProps {
  children: React.ReactNode;
  className?: string;
}

export default function Resizable({ children, className = '' }: ResizableProps) {
  return (
    <div className={`resize overflow-auto rounded-2xl border border-slate-200 bg-white p-4 ${className}`}>
      {children}
    </div>
  );
}
