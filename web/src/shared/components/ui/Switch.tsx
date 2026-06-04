import React from 'react';

interface SwitchProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
}

export default function Switch({ label, className = '', ...props }: SwitchProps) {
  return (
    <label className={`inline-flex cursor-pointer items-center gap-3 ${className}`}>
      <span className="relative inline-flex h-6 w-11 items-center rounded-full bg-slate-300 transition-colors duration-200 focus-within:ring-2 focus-within:ring-blue-500">
        <input type="checkbox" className="sr-only" {...props} />
        <span className="pointer-events-none absolute left-1 inline-block h-4 w-4 translate-x-0 rounded-full bg-white shadow transition-transform duration-200" />
      </span>
      {label ? <span className="text-sm text-slate-700">{label}</span> : null}
    </label>
  );
}

