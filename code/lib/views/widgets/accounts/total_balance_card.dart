import 'package:flutter/material.dart';

// Widget para exibir o saldo total de todas as contas e a quantidade de contas
class TotalBalanceCard extends StatelessWidget {
  final String totalBalance;  // Valor total do saldo (ex: "R$ 5.000,00")
  // Quantidade de contas cadastradas
  final int accountsCount;

  const TotalBalanceCard({
    required this.totalBalance,
    required this.accountsCount,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Ocupa toda a largura disponível
      padding: const EdgeInsets.all(24), // Espaçamento interno
      margin: const EdgeInsets.only(bottom: 18), // Espaço abaixo do card
      decoration: BoxDecoration(
        // Gradiente de cor laranja para o fundo do card
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFFFA552)],
        ),
        borderRadius: BorderRadius.circular(22), // Bordas arredondadas
        boxShadow: [
          // Sombra para dar efeito de elevação
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinha textos à esquerda
        children: [
          // Título do card
          const Text(
            'Saldo Total',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8), // Espaço entre título e saldo
          // Valor do saldo total, destacado
          Text(
            totalBalance,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          const SizedBox(height: 8), // Espaço entre saldo e quantidade de contas
          // Quantidade de contas cadastradas
          Text(
            '$accountsCount contas',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}