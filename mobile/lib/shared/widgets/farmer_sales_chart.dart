import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../themes/app_colors.dart';

class FarmerSalesChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final Color color;

  const FarmerSalesChart({
    super.key,
    this.values = const [4, 6, 5.5, 8, 7.5, 9.5, 11],
    this.labels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final safeValues = values.isEmpty ? [4.0, 6.0, 5.5, 8.0, 7.5, 9.5, 11.0] : values;
    final maxValue = safeValues.reduce((a, b) => a > b ? a : b) * 1.2;

    final spots = safeValues.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value);
    }).toList();

    return SizedBox(
      height: 110,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxValue,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 18,
                getTitlesWidget: (value, _) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    labels[index],
                    style: const TextStyle(fontSize: 9, color: AppColors.muted),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: color,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withValues(alpha: 0.14),
              ),
            ),
          ],
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }
}
