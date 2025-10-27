import 'package:flutter/material.dart';
import '../toggle_buttons_widget.dart';
import '../line_chart_widget.dart';
import '../legend_dot.dart';

class SummaryChartSection extends StatelessWidget {
  const SummaryChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resumo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withOpacity(0.95),
                ),
              ),
              ToggleButtonsWidget(),
            ],
          ),
          const SizedBox(height: 12),
          const SizedBox(
            height: 160,
            child: LineChartWidget(),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              LegendDot(
                color: const Color(0xFF00C853),
                label: 'Entradas',
              ),
              const SizedBox(width: 8),
              LegendDot(
                color: const Color(0xFFFF5252),
                label: 'Saídas',
              ),
            ],
          ),
        ],
      ),
    );
  }
}