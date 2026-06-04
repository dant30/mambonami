import React from 'react';

interface FormInputProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
  error?: string;
}

export default function FormInput({ label, error, className = '', ...props }: FormInputProps) {
  return (
    <div className="space-y-2">
      {label ? <label className="form-label" htmlFor={props.id}>{label}</label> : null}
      <input className={`form-input ${className}`} {...props} />
      {error ? <p className="text-sm text-destructive mt-1">{error}</p> : null}
    </div>
  );
}
