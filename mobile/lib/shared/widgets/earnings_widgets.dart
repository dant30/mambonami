import 'package:flutter/material.dart';
import '../themes/app_gradients.dart';
import 'role_dashboard_widgets.dart';

class EarningsHero extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final List<DashboardStat> stats;

  const EarningsHero({
    super.key,
    required this.label,
    required this.amount,
    required this.icon,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppGradients.field,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 25),
              ),
              const Spacer(),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            amount,
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              for (int index = 0; index < stats.length; index++) ...[
                Expanded(child: _HeroStat(stat: stats[index])),
                if (index != stats.length - 1)
                  Container(
                    width: 1,
                    height: 44,
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class EarningsBreakdownCard extends StatelessWidget {
  final String title;
  final List<EarningsBreakdownRow> rows;

  const EarningsBreakdownCard({
    super.key,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          for (int index = 0; index < rows.length; index++) ...[
            _BreakdownRow(row: rows[index]),
            if (index != rows.length - 1)
              Divider(color: theme.colorScheme.outline),
          ],
        ],
      ),
    );
  }
}

class EarningsBreakdownRow {
  final String label;
  final String count;
  final String amount;
  final IconData icon;

  const EarningsBreakdownRow({
    required this.label,
    required this.count,
    required this.amount,
    required this.icon,
  });
}

class _HeroStat extends StatelessWidget {
  final DashboardStat stat;

  const _HeroStat({required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(stat.icon, color: Colors.white.withValues(alpha: 0.78), size: 18),
        const SizedBox(height: 8),
        Text(
          stat.value,
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          stat.label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w700,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final EarningsBreakdownRow row;

  const _BreakdownRow({required this.row});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(row.icon, color: theme.colorScheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  row.count,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Text(
            row.amount,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
