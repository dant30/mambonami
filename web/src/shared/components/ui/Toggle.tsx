import React from 'react';

interface ToggleProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  active?: boolean;
}

export default function Toggle({ active = false, className = '', children, ...props }: ToggleProps) {
  return (
    <button
      type="button"
      className={`rounded-full px-4 py-2 text-sm transition ${active ? 'bg-blue-600 text-white' : 'bg-slate-100 text-slate-700 hover:bg-slate-200'} ${className}`}
      {...props}
    >
      {children}
    </button>
  );
}
