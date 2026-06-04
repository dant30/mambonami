import React from 'react';

interface FormSelectProps extends React.SelectHTMLAttributes<HTMLSelectElement> {
  label?: string;
  error?: string;
}

export default function FormSelect({ label, error, className = '', children, ...props }: FormSelectProps) {
  return (
    <div className="space-y-2">
      {label ? <label className="form-label" htmlFor={props.id}>{label}</label> : null}
      <select className={`form-select ${className}`} {...props}>
        {children}
      </select>
      {error ? <p className="text-sm text-destructive mt-1">{error}</p> : null}
    </div>
  );
}
