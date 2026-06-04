import React from 'react';

interface RadioProps extends React.InputHTMLAttributes<HTMLInputElement> {
  label?: string;
}

const Radio = React.forwardRef<HTMLInputElement, RadioProps>(({ label, className = '', ...props }, ref) => (
  <label className="inline-flex items-center gap-2">
    <input
      ref={ref}
      type="radio"
      className={`h-4 w-4 border-slate-300 text-blue-600 focus:ring-blue-500 ${className}`}
      {...props}
    />
    {label ? <span className="text-sm text-slate-700">{label}</span> : null}
  </label>
));

Radio.displayName = 'Radio';

export default Radio;

