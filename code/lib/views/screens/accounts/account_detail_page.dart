import 'package:flutter/material.dart';
import '../../widgets/accounts/account_balance_card.dart';
import '../../widgets/accounts/edit_account_modal.dart';
import '../../widgets/accounts/transaction_action_button.dart';
import '../../../controllers/accounts_controllers.dart/account_controller.dart';
import '../../../models/account_model.dart';

class AccountDetailPage extends StatefulWidget {
  final int contaId;
  final Color color;

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

  @override
  void initState() {
    super.initState();
    _loadConta();
  }

  Future<void> _loadConta() async {
    final c = await AccountsController.instance.getContaById(widget.contaId);
    setState(() {
      conta = c;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(conta?.nome ?? 'Detalhe da Conta'),
        backgroundColor: widget.color,
      ),
      body: conta == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 24),
                AccountBalanceCard(
                  accountName: conta!.nome,
                  bankName: conta!.tipo,
                  balance: 'R\$ ${conta!.saldoAtual.toStringAsFixed(2)}',
                  color: widget.color,
                  icon: Icons.account_balance_wallet,
                  showArrow: false,
                ),
                const SizedBox(height: 24),
                // Botões de editar e excluir
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
                            await _deleteAccount(context);
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
                // Botão Nova Receita
                TransactionActionButton(
                  label: 'Nova Receita',
                  color: Colors.green.shade700,
                  icon: Icons.trending_up,
                  onPressed: () {
                    // Ação para nova receita
                  },
                ),
                const SizedBox(height: 12),
                // Botão Nova Despesa
                TransactionActionButton(
                  label: 'Nova Despesa',
                  color: Colors.red.shade700,
                  icon: Icons.trending_down,
                  onPressed: () {
                    // Ação para nova despesa
                  },
                ),
                const SizedBox(height: 12),
              ],
            ),
    );
  }

  void _showEditAccountModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => EditAccountModal(
        conta: conta!,
        onSave: (contaEditada) async {
          await AccountsController.instance.updateConta(
            idConta: contaEditada.idConta!,
            nome: contaEditada.nome,
            tipo: contaEditada.tipo,
          );
          setState(() {
            conta = contaEditada;
          });
          Navigator.of(context).pop(true);
        },
      ),
    ).then((edited) {
      if (edited == true) {
        Navigator.of(context).pop(true);
      }
    });
  }

  Future<void> _deleteAccount(BuildContext context) async {
    await AccountsController.instance.deleteConta(conta!.idConta!);
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conta excluída com sucesso!')),
    );
  }
}