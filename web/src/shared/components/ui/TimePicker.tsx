import React from 'react';

interface TimePickerProps extends React.InputHTMLAttributes<HTMLInputElement> {}

export default function TimePicker({ className = '', ...props }: TimePickerProps) {
  return (
    <input
      type="time"
      className={`w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900 shadow-sm transition focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500 ${className}`}
      {...props}
    />
  );
}

