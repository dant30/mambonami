// web/src/shared/components/cards/MetricsCard.tsx
interface MetricsCardProps {
  title: string;
  value: string;
  metric?: string;
  description?: string;
  trend?: 'up' | 'down';
  change?: string;
}

export default function MetricsCard({ title, value, metric, description, trend, change }: MetricsCardProps) {
  return (
    <div className="rounded-3xl border border-slate-200 bg-white p-5 shadow-soft">
      <div className="flex items-start justify-between gap-4">
        <div>
          <p className="text-sm font-semibold uppercase tracking-[0.24em] text-slate-500">{title}</p>
          <p className="mt-3 text-3xl font-semibold text-slate-950">{value}</p>
          {metric ? <p className="mt-1 text-sm text-slate-500">{metric}</p> : null}
        </div>
        {change ? (
          <div className={`rounded-2xl px-3 py-2 text-sm font-semibold ${trend === 'down' ? 'bg-red-100 text-red-700' : 'bg-emerald-100 text-emerald-700'}`}>
            {trend === 'down' ? '▼' : '▲'} {change}
          </div>
        ) : null}
      </div>
      {description ? <p className="mt-4 text-sm leading-6 text-slate-500">{description}</p> : null}
    </div>
  );
}
