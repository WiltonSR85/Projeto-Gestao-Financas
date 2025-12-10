import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

// Widget para exibir o gráfico de evolução do saldo da conta
class AccountBalanceChart extends StatelessWidget {
  final List<DateTime> dias; // Lista de dias (datas) para o eixo X
  final List<double> saldos; // Lista de saldos acumulados para cada dia

  const AccountBalanceChart({
    required this.dias,
    required this.saldos,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título do gráfico
          const Text(
            'Evolução do Saldo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          // Área do gráfico propriamente dito
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                // Configuração das linhas de grade do gráfico
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 500),
                // Configuração dos títulos dos eixos
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      // Mostra o valor do saldo no eixo Y
                      getTitlesWidget: (value, meta) {
                        return Text('R\$ ${value.toInt()}', style: const TextStyle(color: Colors.white70, fontSize: 12));
                      },
                      interval: 500,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      // Mostra o dia/mês no eixo X
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= dias.length) return const SizedBox();
                        final d = dias[idx];
                        return Text('${d.day}/${d.month}', style: const TextStyle(color: Colors.white70, fontSize: 12));
                      },
                    ),
                  ),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                // Remove borda do gráfico
                borderData: FlBorderData(show: false),
                // Dados da linha do gráfico
                lineBarsData: [
                  LineChartBarData(
                    // Gera os pontos do gráfico a partir dos saldos
                    spots: List.generate(saldos.length, (i) => FlSpot(i.toDouble(), saldos[i])),
                    isCurved: true, // Linha curva
                    color: Colors.orange,
                    barWidth: 3,
                    dotData: FlDotData(show: true), // Mostra pontos nos dados
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.orange.withOpacity(0.18), // Área abaixo da linha
                    ),
                  ),
                ],
                // Configuração de interação/touch no gráfico
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    // Tooltip ao tocar nos pontos do gráfico
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final d = dias[idx];
                        return LineTooltipItem(
                          '${d.day}/${d.month}\nSaldo: R\$ ${spot.y.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}