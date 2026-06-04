import React from 'react';

interface CalendarProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
}

export default function Calendar({ label = 'Select date', className = '', ...props }: CalendarProps) {
  return (
    <label className="block text-sm text-slate-700">
      <span className="mb-1 block text-xs uppercase tracking-wide text-slate-500">{label}</span>
      <input
        type="date"
        className={`w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 ${className}`}
        {...props}
      />
    </label>
  );
}
