import 'package:flutter/material.dart';

// Botão customizado para ações de transação (ex: adicionar receita ou despesa)
class TransactionActionButton extends StatelessWidget {
  final String label;  // Texto do botão (ex: "Adicionar Receita")
  final Color color;  // Cor de fundo do botão
  final IconData icon;  // Ícone exibido à esquerda do texto
  // Função chamada ao pressionar o botão
  final VoidCallback onPressed;

  const TransactionActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Faz o botão ocupar toda a largura disponível
      child: ElevatedButton.icon(
        onPressed: onPressed, // Função chamada ao clicar
        icon: Icon(icon, size: 22), // Ícone do botão
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold), // Texto em negrito
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color, // Cor de fundo do botão
          foregroundColor: Colors.white, // Cor do texto e ícone
          padding: const EdgeInsets.symmetric(vertical: 18), // Altura do botão
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14), // Bordas arredondadas
          ),
          textStyle: const TextStyle(fontSize: 16), // Tamanho do texto
        ),
      ),
    );
  }
}