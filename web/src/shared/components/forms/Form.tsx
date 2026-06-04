import React from 'react';

interface FormProps extends React.FormHTMLAttributes<HTMLFormElement> {
  title?: string;
  description?: string;
}

export default function Form({ title, description, className = '', children, ...props }: FormProps) {
  return (
    <form className={`space-y-6 rounded-3xl border border-slate-200 bg-white p-6 shadow-soft ${className}`} {...props}>
      {title ? <div className="space-y-2"><h2 className="text-2xl font-semibold text-slate-950">{title}</h2>{description ? <p className="text-sm text-slate-500">{description}</p> : null}</div> : null}
      {children}
    </form>
  );
}
