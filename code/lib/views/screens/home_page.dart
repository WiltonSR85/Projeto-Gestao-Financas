import 'package:flutter/material.dart';
import '/controllers/accounts_controllers.dart/account_controller.dart';
import '/controllers/accounts_controllers.dart/transaction_controller.dart';
import '/models/account_model.dart';
import '/models/transaction_model.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/balance_card.dart';
import '../widgets/home/summary_chart_section.dart';
import '../widgets/summary_mini_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ContaModel> _contas = [];
  List<TransactionModel> _transacoes = [];
  bool _isLoading = true;
  double _saldoTotal = 0.0;
  double _receitasTotal = 0.0;
  double _despesasTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() => _isLoading = true);
    
    try {
      final int userId = /* obter id do usuário logado, ex: AuthService.instance.userId */ 1;
      final contas = await AccountsController.instance.getContasByUsuario(userId);
      
      List<TransactionModel> todasTransacoes = [];
      for (var conta in contas) {
        final txs = await TransactionController().fetchTransactionsByConta(conta.idConta!);
        todasTransacoes.addAll(txs);
      }

      double saldoTotal = contas.fold(0.0, (sum, conta) => sum + conta.saldoAtual);

      final resumo = TransactionController().calcularReceitasDespesas(todasTransacoes);

      setState(() {
        _contas = contas;
        _transacoes = todasTransacoes;
        _saldoTotal = saldoTotal;
        _receitasTotal = resumo['receitas'] ?? 0.0;
        _despesasTotal = resumo['despesas'] ?? 0.0;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados: $e');
      setState(() => _isLoading = false);
    }
  }

  String _calcularPercentualMes() {
    if (_saldoTotal == 0) return '0% este mês';
    final percentual = ((_receitasTotal - _despesasTotal) / _saldoTotal * 100);
    return '${percentual >= 0 ? '+' : ''}${percentual.toStringAsFixed(1)}% este mês';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _carregarDados,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeHeader(),
              const SizedBox(height: 18),

              BalanceCard(
                balance: 'R\$ ${_saldoTotal.toStringAsFixed(2)}',
                percentageChange: _calcularPercentualMes(),
              ),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: SummaryMiniCard(
                      title: 'Receitas',
                      amount: 'R\$ ${_receitasTotal.toStringAsFixed(2)}',
                      progress: (_receitasTotal + _despesasTotal) > 0 
                          ? (_receitasTotal / (_receitasTotal + _despesasTotal)).clamp(0.0, 1.0)
                          : 0.0,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryMiniCard(
                      title: 'Despesas',
                      amount: 'R\$ ${_despesasTotal.toStringAsFixed(2)}',
                      progress: (_receitasTotal + _despesasTotal) > 0
                          ? (_despesasTotal / (_receitasTotal + _despesasTotal)).clamp(0.0, 1.0)
                          : 0.0,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              SummaryChartSection(
                transacoes: _transacoes,
                contas: _contas,
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}