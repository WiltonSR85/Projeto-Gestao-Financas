import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LineChartWidget extends StatelessWidget {
  const LineChartWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final spots1 = [
      const FlSpot(0, 1200),
      const FlSpot(1, 1400),
      const FlSpot(2, 1600),
      const FlSpot(3, 2100),
      const FlSpot(4, 1900),
    ];
    
    final spots2 = [
      const FlSpot(0, 500),
      const FlSpot(1, 650),
      const FlSpot(2, 600),
      const FlSpot(3, 700),
      const FlSpot(4, 750),
    ];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, 
              getTitlesWidget: (v, _) {
                const labels = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai'];
                final idx = v.toInt();
                return Text(
                  idx >= 0 && idx < labels.length ? labels[idx] : '', 
                  style: const TextStyle(
                    color: Colors.white70, 
                    fontSize: 11,
                  ),
                );
              }, 
              reservedSize: 28,
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 4,
        minY: 400,
        maxY: 2300,
        lineBarsData: [
          LineChartBarData(
            spots: spots1,
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            color: const Color(0xFF00C853),
          ),
          LineChartBarData(
            spots: spots2,
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            color: const Color(0xFFFF5252),
          ),
        ],
      ),
    );
  }
}