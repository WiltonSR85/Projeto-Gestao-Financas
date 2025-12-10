import 'package:flutter/material.dart';
import '../../widgets/accounts/account_balance_card.dart';
import '../../widgets/accounts/account_balance_chart.dart';
import '../../widgets/accounts/edit_account_modal.dart';
import '../../widgets/accounts/transaction_action_button.dart';
import '../../widgets/accounts/add_transaction_modal.dart';
import '../../widgets/accounts/account_transaction_card.dart';
import '../../../controllers/accounts_controllers.dart/account_controller.dart';
import '../../../models/account_model.dart';
import '../../../controllers/accounts_controllers.dart/transaction_controller.dart';
import '../../../models/transaction_model.dart';

// Tela de detalhes da conta, mostrando saldo, receitas, despesas, gráfico e transações
class AccountDetailPage extends StatefulWidget {
  final int contaId; // ID da conta a ser exibida
  final Color color; // Cor principal da conta

  const AccountDetailPage({
    required this.contaId,
    required this.color,
    super.key,
  });

  @override
  State<AccountDetailPage> createState() => _AccountDetailPageState();
}

class _AccountDetailPageState extends State<AccountDetailPage> {
  ContaModel? conta;
  Future<List<TransactionModel>>? _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _loadConta();
    _loadTransactions();
  }

  // Busca os dados da conta pelo ID
  Future<void> _loadConta() async {
    final c = await AccountsController.instance.getContaById(widget.contaId);
    setState(() {
      conta = c;
    });
  }

  // Atualiza o futuro das transações da conta
  void _loadTransactions() {
    setState(() {
      _transactionsFuture = TransactionController().fetchTransactionsByConta(widget.contaId);
    });
  }

  // Abre o modal para adicionar uma nova transação (receita ou despesa)
  void _showAddTransactionModal({required bool isIncome}) {
    showDialog(
      context: context,
      builder: (_) => AddTransactionModal(
        isIncome: isIncome,
        contaId: conta!.idConta!,
        onSave: (tx) async {
          try {
            // Salva a transação e atualiza os dados da conta e transações
            await TransactionController().addTransactionAndUpdateAccount(tx);
            _loadConta();
            _loadTransactions();
          } catch (e) {
            // Mostra erro caso aconteça
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
            );
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(conta?.nome ?? 'Detalhe da Conta'), // Título da tela
        backgroundColor: widget.color,
      ),
      body: conta == null
          ? const Center(child: CircularProgressIndicator()) // Mostra loading se não carregou a conta
          : FutureBuilder<List<TransactionModel>>(
              future: _transactionsFuture,
              builder: (context, snapshot) {
                final transacoes = snapshot.data ?? [];

                // Gera os dados para o gráfico dos últimos 7 dias
                final now = DateTime.now();
                final ultimosDias = List<DateTime>.generate(7, (i) => now.subtract(Duration(days: 6 - i)));
                double saldo = conta!.saldoInicial;
                final saldos = <double>[];

                // Calcula o saldo acumulado para cada dia
                for (final dia in ultimosDias) {
                  final txsDoDia = transacoes.where((tx) {
                    final txDate = DateTime.parse(tx.data.split('/').reversed.join('-'));
                    return txDate.year == dia.year && txDate.month == dia.month && txDate.day == dia.day;
                  });
                  for (var tx in txsDoDia) {
                    saldo += tx.tipo == 'receita' ? tx.valor : -tx.valor;
                  }
                  saldos.add(saldo);
                }

                // Monta a tela de detalhes da conta
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Card com informações básicas da conta
                      AccountBalanceCard(
                        accountName: conta!.nome,
                        bankName: conta!.tipo,
                        balance: 'R\$ ${conta!.saldoAtual.toStringAsFixed(2)}',
                        color: widget.color,
                        icon: Icons.account_balance_wallet,
                        showArrow: false,
                      ),
                      const SizedBox(height: 24),
                      // Cards de receitas e despesas
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.trending_up, color: Colors.green, size: 24),
                                      SizedBox(width: 8),
                                      Text('Receitas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Soma das receitas
                                  Text(
                                    'R\$ ${transacoes.where((tx) => tx.tipo == 'receita').fold<double>(0, (sum, tx) => sum + tx.valor).toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 22),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.trending_down, color: Colors.red, size: 24),
                                      SizedBox(width: 8),
                                      Text('Despesas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Soma das despesas
                                  Text(
                                    'R\$ ${transacoes.where((tx) => tx.tipo == 'despesa').fold<double>(0, (sum, tx) => sum + tx.valor).toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 22),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Gráfico de evolução do saldo nos últimos 7 dias
                      AccountBalanceChart(dias: ultimosDias, saldos: saldos),
                      const SizedBox(height: 24),
                      // Botões de editar e excluir conta
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _showEditAccountModal(context);
                                },
                                icon: const Icon(Icons.edit, color: Colors.white),
                                label: const Text('Editar', style: TextStyle(color: Colors.white)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.brown.shade700, width: 2),
                                  backgroundColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: OutlinedButton.icon(
                                onPressed: () async {
                                  await _confirmDeleteAccount(context);
                                },
                                icon: const Icon(Icons.delete, color: Colors.white),
                                label: const Text('Excluir', style: TextStyle(color: Colors.white)),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.red.shade700, width: 2),
                                  backgroundColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Botão para adicionar nova receita
                      TransactionActionButton(
                        label: 'Nova Receita',
                        color: Colors.green.shade700,
                        icon: Icons.trending_up,
                        onPressed: () {
                          _showAddTransactionModal(isIncome: true);
                        },
                      ),
                      const SizedBox(height: 12),
                      // Botão para adicionar nova despesa
                      TransactionActionButton(
                        label: 'Nova Despesa',
                        color: Colors.red.shade700,
                        icon: Icons.trending_down,
                        onPressed: () {
                          _showAddTransactionModal(isIncome: false);
                        },
                      ),
                      const SizedBox(height: 12),
                      // Título da lista de transações
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Transações da Conta',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      // Lista das transações da conta
                      FutureBuilder<List<TransactionModel>>(
                        future: _transactionsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(18),
                              child: Text('Nenhuma transação para esta conta.', style: TextStyle(color: Colors.white70)),
                            );
                          }
                          final transacoes = snapshot.data!;
                          return Column(
                            children: transacoes.map((tx) {
                              return AccountTransactionCard(
                                title: tx.descricao,
                                date: tx.data,
                                category: 'Categoria', // ajustar conforme lógica de categoria
                                value: tx.valor.toStringAsFixed(2),
                                isIncome: tx.tipo == 'receita',
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // Abre o modal para editar a conta
  void _showEditAccountModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => EditAccountModal(
        conta: conta!,
        onSave: (contaEditada) async {
          // Atualiza os dados da conta no banco
          await AccountsController.instance.editarConta(contaEditada);
          setState(() {
            conta = contaEditada;
          });
          Navigator.of(context).pop(true); // Fecha o modal
        },
      ),
    ).then((edited) {
      // Se editou, fecha a tela de detalhe também
      if (edited == true) {
        Navigator.of(context).pop(true);
      }
    });
  }

  // Método que pede confirmação antes de excluir e já executa a exclusão
  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: const Text('Tem certeza que deseja excluir esta conta? Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      // Exclui a conta do banco e fecha a tela
      await AccountsController.instance.excluirConta(conta!.idConta!);
      Navigator.of(context).pop(true); // Fecha a tela de detalhe
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conta excluída com sucesso!')),
      );
    }
  }
}