import {
  ResponsiveContainer,
  LineChart as RechartsLineChart,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  Line,
} from 'recharts';

interface LineChartProps<T extends object = Record<string, string | number>> {
  data: T[];
  dataKey: Extract<keyof T, string | number>;
  labelKey: Extract<keyof T, string | number>;
  title?: string;
  color?: string;
}

export default function LineChart<T extends object>({ data, dataKey, labelKey, title, color = '#2563eb' }: LineChartProps<T>) {
  return (
    <div className="rounded-3xl border border-slate-200 bg-white p-5 shadow-soft">
      {title ? <h3 className="mb-4 text-lg font-semibold text-slate-900">{title}</h3> : null}
      <div className="w-full h-72">
        <ResponsiveContainer width="100%" height="100%">
          <RechartsLineChart data={data} margin={{ top: 10, right: 12, left: -12, bottom: 0 }}>
            <CartesianGrid strokeDasharray="3 3" stroke="#e2e8f0" />
            <XAxis dataKey={labelKey} tick={{ fill: '#475569' }} />
            <YAxis tick={{ fill: '#475569' }} />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey={dataKey} stroke={color} strokeWidth={3} dot={{ r: 3 }} />
          </RechartsLineChart>
        </ResponsiveContainer>
      </div>
    </div>
  );
}
