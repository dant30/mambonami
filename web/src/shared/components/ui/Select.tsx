import * as React from 'react';
import { cn } from '../../../lib/utils';
import { CustomSelect } from './CustomSelect';

export interface SelectProps extends Omit<React.SelectHTMLAttributes<HTMLSelectElement>, 'size'> {
  options?: Array<{ value: string; label: string }>;
  error?: string;
  icon?: React.ReactNode;
  uiSize?: 'sm' | 'md';
  label?: string;
}

export const Select = React.forwardRef<HTMLSelectElement, SelectProps>(
  ({ className, options = [], error, value, onChange, icon, uiSize, label, ...props }, ref) => {
    if (options && options.length > 0) {
      return (
        <div className="w-full">
          {label && <span className="form-label mb-1.5 block">{label}</span>}
          <CustomSelect
            options={options.map((opt) => ({ id: opt.value, label: opt.label }))}
            value={(value as string | number) ?? ''}
            onChange={(val) => {
              if (onChange) {
                onChange({
                  target: { value: val },
                  currentTarget: { value: val },
                } as any);
              }
            }}
            error={error}
            icon={icon}
            size={uiSize}
          />
        </div>
      );
    }

    return (
      <div className="w-full">
        {label && <span className="form-label mb-1.5 block">{label}</span>}
        <select
          ref={ref}
          className={cn('form-select h-11 px-3.5 text-[15px]', error && 'border-danger focus:ring-danger/20', className)}
          value={value}
          onChange={onChange}
          {...props}
        >
          {options.map((opt) => (
            <option key={opt.value} value={opt.value}>
              {opt.label}
            </option>
          ))}
        </select>
        {error && <p className="form-error mt-1">{error}</p>}
      </div>
    );
  }
);
Select.displayName = 'Select';
export default Select;

