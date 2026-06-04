import {
  ResponsiveContainer,
  BarChart as RechartsBarChart,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  Bar,
} from 'recharts';

interface BarChartProps {
  data: Array<Record<string, string | number>>;
  dataKey: string;
  labelKey: string;
  title?: string;
  color?: string;
}

export default function BarChart({ data, dataKey, labelKey, title, color = '#2563eb' }: BarChartProps) {
  return (
    <div className="rounded-3xl border border-slate-200 bg-white p-5 shadow-soft">
      {title ? <h3 className="mb-4 text-lg font-semibold text-slate-900">{title}</h3> : null}
      <div className="w-full h-72">
        <ResponsiveContainer width="100%" height="100%">
          <RechartsBarChart data={data} margin={{ top: 10, right: 12, left: -12, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
            <XAxis dataKey={labelKey} tick={{ fill: '#475569' }} />
            <YAxis tick={{ fill: '#475569' }} />
            <Tooltip />
            <Legend />
            <Bar dataKey={dataKey} fill={color} radius={[8, 8, 0, 0]} />
          </RechartsBarChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
