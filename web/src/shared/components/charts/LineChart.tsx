// web/src/shared/components/charts/LineChart.tsx
import {
  ResponsiveContainer,
  LineChart as RechartsLineChart,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  Line,
  TooltipProps,
} from 'recharts';
import { useTheme } from '@/core/context/ThemeContext';
import Chart from './Chart';

interface LineChartProps<T extends object = Record<string, string | number>> {
  data: T[];
  xKey: Extract<keyof T, string | number>;
  lines: Array<{
    key: Extract<keyof T, string | number>;
    color?: string;
    name?: string;
    strokeWidth?: number;
    dot?: boolean;
  }>;
  title?: string;
  description?: string;
  className?: string;
  showGrid?: boolean;
  height?: number | string;
}

const defaultColors = ['#2563eb', '#14b8a6', '#f97316', '#e11d48', '#8b5cf6'];

export default function LineChart<T extends object>({
  data,
  xKey,
  lines,
  title,
  description,
  className,
  showGrid = true,
  height = 300,
}: LineChartProps<T>) {
  const { theme } = useTheme();
  const isDark = theme === 'dark';

  const textColor = isDark ? '#94a3b8' : '#475569';
  const gridColor = isDark ? '#334155' : '#e2e8f0';

  const CustomTooltip = ({ active, payload, label }: TooltipProps<number, string>) => {
    if (!active || !payload || !payload.length) return null;
    return (
      <div className="rounded-lg border border-border bg-card p-3 shadow-lg">
        <p className="mb-1 text-sm font-medium text-foreground">{label}</p>
        {payload.map((entry, index) => (
          <p key={index} className="text-sm" style={{ color: entry.color }}>
            {entry.name}: {entry.value}
          </p>
        ))}
      </div>
    );
  };

  return (
    <Chart title={title} description={description} className={className}>
      <ResponsiveContainer width="100%" height={height}>
        <RechartsLineChart
          data={data}
          margin={{ top: 10, right: 12, left: 0, bottom: 0 }}
        >
          {showGrid && <CartesianGrid strokeDasharray="3 3" stroke={gridColor} />}
          <XAxis
            dataKey={xKey}
            tick={{ fill: textColor, fontSize: 12 }}
            axisLine={{ stroke: gridColor }}
            tickLine={{ stroke: gridColor }}
            interval="preserveStartEnd"
          />
          <YAxis
            tick={{ fill: textColor, fontSize: 12 }}
            axisLine={{ stroke: gridColor }}
            tickLine={{ stroke: gridColor }}
          />
          <Tooltip content={<CustomTooltip />} />
          <Legend
            wrapperStyle={{ color: textColor, fontSize: 12 }}
            iconType="circle"
          />
          {lines.map((line, index) => (
            <Line
              key={line.key as string}
              type="monotone"
              dataKey={line.key}
              name={line.name ?? String(line.key)}
              stroke={line.color ?? defaultColors[index % defaultColors.length]}
              strokeWidth={line.strokeWidth ?? 2.5}
              dot={line.dot ?? { r: 3 }}
              activeDot={{ r: 5 }}
            />
          ))}
        </RechartsLineChart>
      </ResponsiveContainer>
    </Chart>
  );
}