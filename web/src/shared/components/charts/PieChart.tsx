// web/src/shared/components/charts/PieChart.tsx
import {
  ResponsiveContainer,
  PieChart as RechartsPieChart,
  Pie,
  Cell,
  Tooltip,
  Legend,
  TooltipProps,
} from 'recharts';
import { useTheme } from '@/core/context/ThemeContext';
import Chart from './Chart';

interface PieChartProps<T extends object = { name: string; value: number }> {
  data: T[];
  title?: string;
  description?: string;
  className?: string;
  colors?: string[];
  innerRadius?: number;
  outerRadius?: number;
  label?: boolean;
  height?: number | string;
}

const defaultColors = ['#2563eb', '#14b8a6', '#f97316', '#e11d48', '#8b5cf6', '#a855f7', '#f59e0b'];

export default function PieChart<T extends object>({
  data,
  title,
  description,
  className,
  colors = defaultColors,
  innerRadius = 0,
  outerRadius = 90,
  label = true,
  height = 300,
}: PieChartProps<T>) {
  const { theme } = useTheme();
  const isDark = theme === 'dark';

  const textColor = isDark ? '#94a3b8' : '#475569';

  const CustomTooltip = ({ active, payload }: TooltipProps<number, string>) => {
    if (!active || !payload || !payload.length) return null;
    const item = payload[0];
    return (
      <div className="rounded-lg border border-border bg-card p-3 shadow-lg">
        <p className="text-sm font-medium text-foreground">{item.name}</p>
        <p className="text-sm" style={{ color: item.color }}>
          {item.value} ({item.payload.percent}%)
        </p>
      </div>
    );
  };

  const renderLabel = label
    ? ({ name, percent }: { name: string; percent: number }) =>
        `${name}: ${(percent * 100).toFixed(0)}%`
    : undefined;

  return (
    <Chart title={title} description={description} className={className}>
      <ResponsiveContainer width="100%" height={height}>
        <RechartsPieChart>
          <Pie
            data={data}
            dataKey="value"
            nameKey="name"
            cx="50%"
            cy="50%"
            innerRadius={innerRadius}
            outerRadius={outerRadius}
            fill="#2563eb"
            label={renderLabel}
            labelLine={label}
          >
            {data.map((_, index) => (
              <Cell
                key={`cell-${index}`}
                fill={colors[index % colors.length]}
                stroke={isDark ? '#1e293b' : '#fff'}
                strokeWidth={1}
              />
            ))}
          </Pie>
          <Tooltip content={<CustomTooltip />} />
          <Legend
            wrapperStyle={{ color: textColor, fontSize: 12 }}
            iconType="circle"
            layout="horizontal"
            verticalAlign="bottom"
            align="center"
          />
        </RechartsPieChart>
      </ResponsiveContainer>
    </Chart>
  );
}