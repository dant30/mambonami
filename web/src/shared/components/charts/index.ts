// web/src/shared/components/charts/index.ts
/**
 * MAMBONAMI Chart Components
 *
 * A collection of Recharts-based chart components with dark mode support,
 * consistent styling, and customizable options.
 *
 * @example
 * ```tsx
 * import { BarChart, LineChart, PieChart } from '@/shared/components/charts';
 *
 * <BarChart
 *   data={data}
 *   xKey="month"
 *   bars={[{ key: 'sales', color: '#2563eb', name: 'Sales' }]}
 *   title="Monthly Sales"
 * />
 * ```
 */

// ============================================================================
// Components
// ============================================================================

export { default as Chart } from './Chart';
export { default as BarChart } from './BarChart';
export { default as LineChart } from './LineChart';
export { default as PieChart } from './PieChart';

// ============================================================================
// Types
// ============================================================================

export type { ChartProps } from './Chart';
export type { BarChartProps } from './BarChart';
export type { LineChartProps } from './LineChart';
export type { PieChartProps } from './PieChart';

// ============================================================================
// Default export for convenience
// ============================================================================

import Chart from './Chart';
import BarChart from './BarChart';
import LineChart from './LineChart';
import PieChart from './PieChart';

const Charts = {
  Chart,
  BarChart,
  LineChart,
  PieChart,
};

export default Charts;

// ============================================================================
// Re-export Recharts types (optional, for advanced use)
// ============================================================================

export type {
  TooltipProps,
  LegendProps,
  CartesianGridProps,
  XAxisProps,
  YAxisProps,
} from 'recharts';