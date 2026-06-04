import React from 'react';

interface LabelProps extends React.LabelHTMLAttributes<HTMLLabelElement> {}

export default function Label({ className = '', children, ...props }: LabelProps) {
  return (
    <label className={`block text-sm font-medium text-slate-700 ${className}`} {...props}>
      {children}
    </label>
  );
}
