// web/src/shared/components/charts/BarChart.tsx
import {
  ResponsiveContainer,
  BarChart as RechartsBarChart,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  Legend,
  Bar,
  TooltipProps,
} from 'recharts';
import { useTheme } from '@/core/context/ThemeContext';
import { cn } from '@/lib/utils';
import Chart from './Chart';

interface BarChartProps<T extends object = Record<string, string | number>> {
  data: T[];
  xKey: Extract<keyof T, string | number>;
  bars: Array<{
    key: Extract<keyof T, string | number>;
    color?: string;
    name?: string;
    stackId?: string;
  }>;
  title?: string;
  description?: string;
  className?: string;
  layout?: 'vertical' | 'horizontal';
  showGrid?: boolean;
  height?: number | string;
}

const defaultColors = ['#2563eb', '#14b8a6', '#f97316', '#e11d48', '#8b5cf6'];

export default function BarChart<T extends object>({
  data,
  xKey,
  bars,
  title,
  description,
  className,
  layout = 'horizontal',
  showGrid = true,
  height = 300,
}: BarChartProps<T>) {
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
        <RechartsBarChart
          data={data}
          layout={layout}
          margin={{ top: 10, right: 12, left: 0, bottom: 0 }}
          barGap={4}
          barCategoryGap="10%"
        >
          {showGrid && <CartesianGrid strokeDasharray="3 3" stroke={gridColor} />}
          <XAxis
            dataKey={xKey}
            tick={{ fill: textColor, fontSize: 12 }}
            axisLine={{ stroke: gridColor }}
            tickLine={{ stroke: gridColor }}
            interval={0}
            angle={-30}
            textAnchor="end"
            height={60}
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
          {bars.map((bar, index) => (
            <Bar
              key={bar.key as string}
              dataKey={bar.key}
              name={bar.name ?? String(bar.key)}
              fill={bar.color ?? defaultColors[index % defaultColors.length]}
              stackId={bar.stackId}
              radius={[4, 4, 0, 0]}
              maxBarSize={50}
            />
          ))}
        </RechartsBarChart>
      </ResponsiveContainer>
    </Chart>
  );
}