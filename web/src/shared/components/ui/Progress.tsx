
interface ProgressProps {
  value: number;
  max?: number;
  label?: string;
}

export default function Progress({ value, max = 100, label }: ProgressProps) {
  const percentage = Math.min(100, Math.max(0, (value / max) * 100));

  return (
    <div className="space-y-2">
      {label ? <div className="text-sm text-slate-700">{label}</div> : null}
      <div className="h-3 overflow-hidden rounded-full bg-slate-200">
        <div className="h-full rounded-full bg-blue-600" style={{ width: `${percentage}%` }} />
      </div>
    </div>
  );
}
