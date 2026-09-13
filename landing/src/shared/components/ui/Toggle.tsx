import React from 'react';

interface ToggleProps {
  id?: string;
  checked: boolean;
  onChange: (checked: boolean) => void;
  label?: string;
  description?: string;
  disabled?: boolean;
  size?: 'sm' | 'md' | 'lg';
  activeColor?: string;
}

export const Toggle: React.FC<ToggleProps> = ({
  id,
  checked,
  onChange,
  label,
  description,
  disabled = false,
  size = 'md',
  activeColor = 'bg-[#FF6B00]',
}) => {
  const switchSizes = {
    sm: 'w-8 h-4 after:w-3 after:h-3 after:top-0.5 after:left-0.5',
    md: 'w-11 h-6 after:w-5 after:h-5 after:top-0.5 after:left-0.5',
    lg: 'w-14 h-7 after:w-6 after:h-6 after:top-0.5 after:left-0.5',
  }[size];

  const translateOffset = {
    sm: 'after:translate-x-4',
    md: 'after:translate-x-5',
    lg: 'after:translate-x-7',
  }[size];

  return (
    <label
      htmlFor={id}
      className={`flex items-start justify-between gap-3 cursor-pointer select-none ${
        disabled ? 'opacity-50 cursor-not-allowed' : ''
      }`}
    >
      {(label || description) && (
        <div className="flex flex-col text-left">
          {label && <span className="text-xs font-bold text-slate-900">{label}</span>}
          {description && <span className="text-[11px] text-slate-500">{description}</span>}
        </div>
      )}

      <div className="relative inline-flex items-center shrink-0">
        <input
          type="checkbox"
          id={id}
          checked={checked}
          disabled={disabled}
          onChange={(e) => onChange(e.target.checked)}
          className="sr-only peer"
        />
        <div
          className={`bg-slate-300 peer-focus:outline-hidden rounded-full peer peer-checked:${activeColor} ${switchSizes} after:content-[''] after:absolute after:bg-white after:rounded-full after:transition-all peer-checked:${translateOffset} transition-colors`}
        ></div>
      </div>
    </label>
  );
};
