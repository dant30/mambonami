// web/src/shared/components/cards/Card.tsx
import { forwardRef, type ComponentPropsWithoutRef, type ReactNode } from 'react';
import { cn } from '@/lib/utils';

// ─── Types ───────────────────────────────────────────────

type CardVariant = 'default' | 'elevated' | 'outlined' | 'filled' | 'glass' | 'glass-dark';
type CardPadding = 'none' | 'sm' | 'md' | 'lg' | 'xl';

interface CardProps extends ComponentPropsWithoutRef<'div'> {
  children: ReactNode;
  variant?: CardVariant;
  padding?: CardPadding;
  hover?: boolean;
  as?: 'div' | 'section' | 'article';
  className?: string;
}

// ─── Variant & Padding Maps ─────────────────────────────

const variantMap: Record<CardVariant, string> = {
  default: 'bg-card border border-border',
  elevated: 'bg-card shadow-soft',
  outlined: 'bg-card border border-border',
  filled: 'bg-muted/30 border border-border/50',
  glass: 'bg-white/60 backdrop-blur-md border border-white/20 shadow-soft dark:bg-slate-950/60 dark:border-slate-700/30',
  'glass-dark': 'bg-slate-950/70 backdrop-blur-md border border-slate-700/30 shadow-soft',
};

const paddingMap: Record<CardPadding, string> = {
  none: '',
  sm: 'p-3',
  md: 'p-4',
  lg: 'p-6',
  xl: 'p-8',
};

// ─── Main Card ───────────────────────────────────────────

export const Card = forwardRef<HTMLDivElement, CardProps>(
  ({ children, className, variant = 'default', padding = 'md', hover = false, as: Component = 'div', ...props }, ref) => {
    return (
      <Component
        ref={ref}
        className={cn(
          'rounded-xl transition-all duration-200',
          variantMap[variant],
          paddingMap[padding],
          hover && 'hover:shadow-glow hover:-translate-y-1',
          className,
        )}
        {...props}
      >
        {children}
      </Component>
    );
  },
);
Card.displayName = 'Card';

// ─── Card Subcomponents ──────────────────────────────────

type CardSectionProps = {
  children: ReactNode;
  className?: string;
  as?: 'div' | 'header' | 'footer' | 'section';
};

export const CardHeader = forwardRef<HTMLDivElement, CardSectionProps>(
  ({ children, className, as: Component = 'div', ...props }, ref) => (
    <Component
      ref={ref}
      className={cn('flex flex-col gap-1 border-b border-border/60 pb-3 mb-3', className)}
      {...props}
    >
      {children}
    </Component>
  ),
);
CardHeader.displayName = 'CardHeader';

export const CardTitle = forwardRef<HTMLHeadingElement, { children: ReactNode; className?: string }>(
  ({ children, className, ...props }, ref) => (
    <h3 ref={ref} className={cn('text-lg font-semibold tracking-tight', className)} {...props}>
      {children}
    </h3>
  ),
);
CardTitle.displayName = 'CardTitle';

export const CardDescription = forwardRef<HTMLParagraphElement, { children: ReactNode; className?: string }>(
  ({ children, className, ...props }, ref) => (
    <p ref={ref} className={cn('text-sm text-muted-foreground', className)} {...props}>
      {children}
    </p>
  ),
);
CardDescription.displayName = 'CardDescription';

export const CardContent = forwardRef<HTMLDivElement, CardSectionProps>(
  ({ children, className, ...props }, ref) => (
    <div ref={ref} className={cn('flex-1', className)} {...props}>
      {children}
    </div>
  ),
);
CardContent.displayName = 'CardContent';

export const CardFooter = forwardRef<HTMLDivElement, CardSectionProps>(
  ({ children, className, as: Component = 'div', ...props }, ref) => (
    <Component
      ref={ref}
      className={cn('border-t border-border/60 pt-3 mt-3 flex items-center gap-2', className)}
      {...props}
    >
      {children}
    </Component>
  ),
);
CardFooter.displayName = 'CardFooter';

// ─── Specialised Cards ──────────────────────────────────

type KpiCardProps = {
  title: string;
  value: string | number;
  change?: number;
  icon?: ReactNode;
  iconColor?: string;
  trend?: 'up' | 'down' | 'neutral';
  className?: string;
};

export function KpiCard({ title, value, change, icon, iconColor = 'text-primary', trend, className }: KpiCardProps) {
  const isPositive = change !== undefined && change >= 0;
  const trendIcon = trend === 'up' ? '↑' : trend === 'down' ? '↓' : isPositive ? '↑' : '↓';
  const trendColor = isPositive ? 'text-green-600' : 'text-red-600';

  return (
    <Card variant="elevated" className={cn('overflow-hidden', className)}>
      <CardContent className="flex items-start justify-between p-4">
        <div className="space-y-1">
          <p className="text-xs font-medium uppercase tracking-wider text-muted-foreground">{title}</p>
          <p className="text-2xl font-bold">{value}</p>
          {change !== undefined && (
            <div className="flex items-center gap-1 text-xs">
              <span className={cn('font-medium', trendColor)}>
                {trendIcon} {Math.abs(change)}%
              </span>
              <span className="text-muted-foreground">vs last period</span>
            </div>
          )}
        </div>
        {icon && <div className={cn('rounded-full bg-primary/10 p-2.5', iconColor)}>{icon}</div>}
      </CardContent>
    </Card>
  );
}

type MetricCardProps = {
  label: string;
  value: string | number;
  subtitle?: string;
  progress?: number; // 0–100
  className?: string;
};

export function MetricCard({ label, value, subtitle, progress, className }: MetricCardProps) {
  return (
    <Card variant="default" className={cn('overflow-hidden', className)}>
      <CardContent className="p-4">
        <p className="text-xs font-medium uppercase tracking-wider text-muted-foreground">{label}</p>
        <p className="mt-1 text-xl font-bold">{value}</p>
        {subtitle && <p className="text-xs text-muted-foreground">{subtitle}</p>}
        {progress !== undefined && (
          <div className="mt-3 h-1.5 w-full rounded-full bg-muted">
            <div className="h-1.5 rounded-full bg-primary transition-all" style={{ width: `${Math.min(100, Math.max(0, progress))}%` }} />
          </div>
        )}
      </CardContent>
    </Card>
  );
}

type StatCardProps = {
  label: string;
  value: string | number;
  icon?: ReactNode;
  color?: string;
  className?: string;
};

export function StatCard({ label, value, icon, color = 'text-primary', className }: StatCardProps) {
  return (
    <Card variant="filled" className={cn('overflow-hidden', className)}>
      <CardContent className="flex items-center gap-3 p-3">
        {icon && <div className={cn('rounded-full bg-primary/10 p-2', color)}>{icon}</div>}
        <div className="flex-1 min-w-0">
          <p className="text-xs font-medium text-muted-foreground truncate">{label}</p>
          <p className="text-lg font-semibold">{value}</p>
        </div>
      </CardContent>
    </Card>
  );
}

export default Card;