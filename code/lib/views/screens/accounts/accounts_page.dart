import 'package:flutter/material.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/accounts/account_balance_card.dart';
import '../../widgets/accounts/total_balance_card.dart';
import '../../widgets/accounts/transaction_history_card.dart';
import '../../widgets/accounts/add_account_modal.dart';
import '/controllers/accounts_controllers.dart/account_controller.dart';
import '../../../controllers/auth_controller.dart';
import './account_detail_page.dart'; // Importar a página de detalhes da conta
import '../../../models/account_model.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  Future<List<ContaModel>>? _contasFuture;
  int usuarioAtualId = 0;

  @override
  void initState() {
    super.initState();
    _getUsuarioAtualId();
  }

  Future<void> _getUsuarioAtualId() async {
    final id = await AuthController.instance.getUsuarioLogadoId();
    setState(() {
      usuarioAtualId = id;
      _loadContas();
    });
  }

  void _loadContas() {
    setState(() {
      _contasFuture = AccountsController.instance.getContasByUsuario(usuarioAtualId);
    });
  }

  void _showAddAccountModal() {
    showDialog(
      context: context,
      builder: (_) => AddAccountModal(
        onSave: (conta) async {
          try {
            final novaConta = ContaModel(
              nome: conta.nome,
              tipo: conta.tipo,
              saldoInicial: conta.saldoInicial,
              saldoAtual: conta.saldoAtual,
              idUsuario: usuarioAtualId,
            );
            await AccountsController.instance.addConta(novaConta);
            _loadContas();
          } catch (e) {
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
    final List<Color> cardColors = [
      const Color(0xFFF97316),
      const Color(0xFFB721FF),
      const Color(0xFF22C55E),
      const Color(0xFF2563EB),
      const Color(0xFFEF4444),
      const Color(0xFF14B8A6),
    ];

    // Exemplo de lista de transações (substitua por dados reais)
    final transactions = [
      TransactionHistoryCard(
        icon: Icons.attach_money,
        iconColor: Colors.green,
        title: 'Salário',
        date: '04/12/2025',
        account: 'Conta Corrente',
        category: 'Trabalho',
        value: '5000,00',
        isIncome: true,
      ),
      TransactionHistoryCard(
        icon: Icons.shopping_cart,
        iconColor: Colors.orange,
        title: 'Supermercado Extra',
        date: '03/12/2025',
        account: 'Conta Corrente',
        category: 'Alimentação',
        value: '320,50',
        isIncome: false,
      ),
      TransactionHistoryCard(
        icon: Icons.local_cafe,
        iconColor: Colors.orange,
        title: 'Café Starbucks',
        date: '02/12/2025',
        account: 'Cartão de Crédito',
        category: 'Alimentação',
        value: '28,90',
        isIncome: false,
      ),
      TransactionHistoryCard(
        icon: Icons.trending_up,
        iconColor: Colors.green,
        title: 'Rendimento',
        date: '30/11/2025',
        account: 'Poupança',
        category: 'Investimentos',
        value: '340,00',
        isIncome: true,
      ),
      TransactionHistoryCard(
        icon: Icons.local_gas_station,
        iconColor: Colors.red,
        title: 'Combustível',
        date: '29/11/2025',
        account: 'Conta Corrente',
        category: 'Transporte',
        value: '250,00',
        isIncome: false,
      ),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeader(),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Contas',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _showAddAccountModal,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Nova conta'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            // Saldo total dinâmico
            FutureBuilder<List<ContaModel>>(
              future: _contasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return TotalBalanceCard(
                    totalBalance: 'R\$ 0,00',
                    accountsCount: 0,
                  );
                }
                final contas = snapshot.data!;
                final total = contas.fold<num>(
                  0,
                  (sum, conta) => sum + (conta.saldoAtual as num? ?? 0),
                );
                return TotalBalanceCard(
                  totalBalance: 'R\$ ${total.toStringAsFixed(2)}',
                  accountsCount: contas.length,
                );
              },
            ),
            const SizedBox(height: 18),
            // Lista de contas cadastradas
            FutureBuilder<List<ContaModel>>(
              future: _contasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('Nenhuma conta cadastrada', style: TextStyle(color: Colors.white70));
                }
                final contas = snapshot.data!;
                return Column(
                  children: contas.asMap().entries.map((entry) {
                    final i = entry.key;
                    final conta = entry.value;
                    final color = cardColors[i % cardColors.length];
                    return AccountBalanceCard(
                      accountName: conta.nome,
                      bankName: conta.tipo,
                      balance: 'R\$ ${conta.saldoAtual.toStringAsFixed(2)}',
                      color: color,
                      icon: Icons.account_balance_wallet,
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AccountDetailPage(
                              contaId: conta.idConta!,
                              color: color,
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadContas();
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 18),
            // Histórico de transações (mantém como está)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Histórico',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${transactions.length} transações',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...transactions,
          ],
        ),
      ),
    );
  }
}