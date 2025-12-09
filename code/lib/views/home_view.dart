import 'package:flutter/material.dart';
import '../controllers/accounts_controllers.dart/transaction_controller.dart';

class HomeView extends StatelessWidget {
  final TransactionController controller;

  const HomeView({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestão Financeira - Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bem-vindo à HomeView'),
            const SizedBox(height: 8),
            Text('Transações: ${controller.transactions.length}'),
            Text('Total: R\$ ${controller.totalAmount.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}