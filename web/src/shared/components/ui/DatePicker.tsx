import React from 'react';

interface DatePickerProps extends React.InputHTMLAttributes<HTMLInputElement> {}

export default function DatePicker({ className = '', ...props }: DatePickerProps) {
  return (
    <input
      type="date"
      className={`w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm transition focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 ${className}`}
      {...props}
    />
  );
}

