import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpensePieChart extends StatelessWidget {
  final Map<String, double> categories;
  final double radius;

  const ExpensePieChart({
    super.key,
    required this.categories,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: radius * 2,
      child: PieChart(
        PieChartData(
          sections:
              categories.entries.map((entry) {
                return PieChartSectionData(
                  value: entry.value,
                  title: entry.key,
                  radius: radius,
                  color: _getRandomColor(),
                );
              }).toList(),
          centerSpaceRadius: 40,
        ),
      ),
    );
  }

  Color _getRandomColor() {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    return colors[categories.keys.toList().indexOf(categories.keys.first) %
        colors.length];
  }
}
