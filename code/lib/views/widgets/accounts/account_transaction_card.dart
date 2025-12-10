import 'package:flutter/material.dart';

// Widget para exibir uma transação individual vinculada a uma conta
class AccountTransactionCard extends StatelessWidget {
  final String title;  // Título da transação (ex: "Salário", "Supermercado")
  final String date;   // Data da transação (ex: "04/12/2025")
  final String category;  // Categoria da transação (ex: "Trabalho", "Alimentação")
  final String value; // Valor da transação (ex: "5000.00")
  final bool isIncome; // Indica se é receita (true) ou despesa (false)

  const AccountTransactionCard({
    required this.title,
    required this.date,
    required this.category,
    required this.value,
    required this.isIncome,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Define o ícone e a cor de acordo com o tipo de transação
    final IconData icon = isIncome ? Icons.attach_money : Icons.money_off;
    final Color iconColor = isIncome ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 14), // Espaço abaixo do card
      padding: const EdgeInsets.all(18), // Espaçamento interno
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.18), // Cor de fundo translúcida
        borderRadius: BorderRadius.circular(18), // Bordas arredondadas
      ),
      child: Row(
        children: [
          // Ícone da transação (dinheiro para receita, carrinho para despesa)
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15), // Fundo do ícone levemente colorido
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 14), // Espaço entre ícone e texto
          // Área de texto expandida
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título da transação
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                // Linha com data e categoria
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  children: [
                    Text(
                      date,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      category,
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Área do valor da transação
          Container(
            constraints: const BoxConstraints(minWidth: 80, maxWidth: 120),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Prefixo de valor (+ R$ para receita, - R$ para despesa)
                Text(
                  isIncome ? '+ R\$' : '- R\$',
                  style: TextStyle(
                    color: isIncome ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 4),
                // Valor propriamente dito, com cor e tamanho destacados
                Flexible(
                  child: Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}