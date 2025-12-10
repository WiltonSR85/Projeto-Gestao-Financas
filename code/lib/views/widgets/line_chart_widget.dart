import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '/models/transaction_model.dart';
import '/models/account_model.dart';

class LineChartWidget extends StatelessWidget {
  final List<TransactionModel> transacoes;
  final List<ContaModel> contas;

  const LineChartWidget({
    super.key,
    required this.transacoes,
    required this.contas,
  });

  @override
  Widget build(BuildContext context) {
    if (transacoes.isEmpty) {
      return Center(
        child: Text(
          'Nenhuma transação registrada',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
      );
    }

    // obter dados tipados para evitar List<dynamic> -> List<FlSpot> mismatch
    final raw = _gerarDadosGrafico();
    final List<double> receitasList = List<double>.from(raw['receitas'] as List);
    final List<double> despesasList = List<double>.from(raw['despesas'] as List);
    final List<String> labels = List<String>.from(raw['labels'] as List);
    final double maxY = (raw['maxY'] as num).toDouble();

    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.white.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= labels.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[value.toInt()],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    'R\$${(value / 1000).toStringAsFixed(0)}k',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: (receitasList.length - 1).toDouble(),
          minY: 0,
          maxY: maxY * 1.2,
          lineBarsData: [
            // Linha verde (Receitas)
            LineChartBarData(
              spots: receitasList
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: const Color(0xFF00C853),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: const Color(0xFF00C853),
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF00C853).withOpacity(0.1),
              ),
            ),
            // Linha vermelha (Despesas)
            LineChartBarData(
              spots: despesasList
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: const Color(0xFFFF5252),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: const Color(0xFFFF5252),
                    strokeWidth: 0,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFFFF5252).withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _gerarDadosGrafico() {
    // Agrupa transações por dia
    final Map<String, double> receitasPorDia = {};
    final Map<String, double> despesasPorDia = {};

    for (var tx in transacoes) {
      final data = tx.data; // formato dd/MM/yyyy
      
      if (tx.tipo == 'receita') {
        receitasPorDia[data] = (receitasPorDia[data] ?? 0) + tx.valor;
      } else {
        despesasPorDia[data] = (despesasPorDia[data] ?? 0) + tx.valor;
      }
    }

    // Pega todas as datas únicas e ordena
    final todasDatas = {...receitasPorDia.keys, ...despesasPorDia.keys}.toList();
    todasDatas.sort((a, b) {
      final dateA = DateTime.parse(a.split('/').reversed.join('-'));
      final dateB = DateTime.parse(b.split('/').reversed.join('-'));
      return dateA.compareTo(dateB);
    });

    // Limita a 7 dias mais recentes
    final datasRecentes = todasDatas.length > 7 
        ? todasDatas.sublist(todasDatas.length - 7) 
        : todasDatas;

    // Gera listas acumuladas
    double receitaAcumulada = 0;
    double despesaAcumulada = 0;
    
    final List<double> receitasSpots = [];
    final List<double> despesasSpots = [];
    final List<String> labels = [];

    for (var data in datasRecentes) {
      receitaAcumulada += receitasPorDia[data] ?? 0;
      despesaAcumulada += despesasPorDia[data] ?? 0;
      
      receitasSpots.add(receitaAcumulada);
      despesasSpots.add(despesaAcumulada);
      
      // Label simplificado (dia/mês)
      final parts = data.split('/');
      labels.add('${parts[0]}/${parts[1]}');
    }

    // Se não houver dados, cria pontos padrão
    if (receitasSpots.isEmpty) {
      receitasSpots.add(0);
      despesasSpots.add(0);
      labels.add('Hoje');
    }

    final maxValue = [
      receitasSpots.reduce((a, b) => a > b ? a : b),
      despesasSpots.reduce((a, b) => a > b ? a : b),
    ].reduce((a, b) => a > b ? a : b);

    return {
      'receitas': receitasSpots,
      'despesas': despesasSpots,
      'labels': labels,
      'maxY': maxValue > 0 ? maxValue : 1000,
    };
  }
}