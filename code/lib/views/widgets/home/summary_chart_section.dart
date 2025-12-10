import 'package:flutter/material.dart';
import '/models/transaction_model.dart';
import '/models/account_model.dart';
import '../toggle_buttons_widget.dart';
import '../line_chart_widget.dart';
import '../legend_dot.dart';

class SummaryChartSection extends StatelessWidget {
  final List<TransactionModel> transacoes;
  final List<ContaModel> contas;

  const SummaryChartSection({
    super.key,
    required this.transacoes,
    required this.contas,
  });

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
              const ToggleButtonsWidget(),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: LineChartWidget(
              transacoes: transacoes,
              contas: contas,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              LegendDot(
                color: Color(0xFF00C853),
                label: 'Entradas',
              ),
              SizedBox(width: 8),
              LegendDot(
                color: Color(0xFFFF5252),
                label: 'Saídas',
              ),
            ],
          ),
        ],
      ),
    );
  }
}