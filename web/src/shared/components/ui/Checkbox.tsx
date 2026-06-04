import React from 'react';

interface CheckboxProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
}

const Checkbox = React.forwardRef<HTMLInputElement, CheckboxProps>(({ label, className = '', ...props }, ref) => (
  <label className="inline-flex items-center gap-2">
    <input
      ref={ref}
      type="checkbox"
      className={`h-4 w-4 rounded border-slate-300 text-blue-600 focus:ring-blue-500 ${className}`}
      {...props}
    />
    {label ? <span className="text-sm text-slate-700">{label}</span> : null}
  </label>
));

Checkbox.displayName = 'Checkbox';

export default Checkbox;

