
interface ProgressBarProps {
  value: number;
  max?: number;
  label?: string;
}

export default function ProgressBar({ value, max = 100, label }: ProgressBarProps) {
  const percentage = Math.min(100, Math.max(0, (value / max) * 100));

  return (
    <div className="space-y-2">
      {label ? <div className="text-sm font-medium text-slate-700">{label}</div> : null}
      <div className="h-3 rounded-full bg-slate-200">
        <div className="h-full rounded-full bg-blue-600" style={{ width: `${percentage}%` }} />
      </div>
    </div>
  );
}

