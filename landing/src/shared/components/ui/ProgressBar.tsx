import React from 'react';

interface ProgressBarProps {
  value: number; // 0 to 100
  label?: React.ReactNode;
  showPercentage?: boolean;
  rightLabel?: React.ReactNode;
  color?: 'navy' | 'orange' | 'emerald' | 'rose' | 'amber';
  className?: string;
  barHeightClassName?: string;
}

export const ProgressBar: React.FC<ProgressBarProps> = ({
  value,
  label,
  showPercentage = true,
  rightLabel,
  color = 'navy',
  className = '',
  barHeightClassName = 'h-2',
}) => {
  const clampedValue = Math.min(100, Math.max(0, value));

  const colorStyles = {
    navy: 'bg-[#0A2540]',
    orange: 'bg-[#FF6B00]',
    emerald: 'bg-emerald-600',
    rose: 'bg-rose-500',
    amber: 'bg-amber-500',
  }[color];

  return (
    <div className={`w-full space-y-1.5 ${className}`}>
      {(label || showPercentage || rightLabel) && (
        <div className="flex justify-between items-center text-xs font-medium text-slate-600">
          {label && <div>{label}</div>}
          {rightLabel ? <div>{rightLabel}</div> : showPercentage && <span>{clampedValue}%</span>}
        </div>
      )}
      <div className={`w-full ${barHeightClassName} bg-slate-100 rounded-full overflow-hidden`}>
        <div
          className={`h-full ${colorStyles} transition-all duration-500 rounded-full`}
          style={{ width: `${clampedValue}%` }}
        />
      </div>
    </div>
  );
};
