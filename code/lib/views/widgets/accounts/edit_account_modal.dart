import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/account_model.dart';

// Modal para editar uma conta existente
class EditAccountModal extends StatefulWidget {
  final ContaModel conta;  // Conta que será editada (os dados atuais são exibidos no formulário)
  // Callback chamado ao salvar, recebendo o objeto editado
  final void Function(ContaModel contaEditada) onSave;

  const EditAccountModal({
    required this.conta,
    required this.onSave,
    super.key,
  });

  @override
  State<EditAccountModal> createState() => _EditAccountModalState();
}

class _EditAccountModalState extends State<EditAccountModal> {
  // Controlador para o campo de nome da conta
  late TextEditingController _nomeCtrl;
  // Valor selecionado do tipo de conta (Corrente ou Poupança)
  String _selectedTipo = 'Conta Corrente';

  @override
  void initState() {
    super.initState();
    // Inicializa o campo de nome com o nome atual da conta
    _nomeCtrl = TextEditingController(text: widget.conta.nome);

    // Inicializa o tipo de conta com base no valor atual da conta
    final tipo = widget.conta.tipo.toLowerCase();
    if (tipo == 'conta corrente' || tipo == 'corrente') {
      _selectedTipo = 'Conta Corrente';
    } else if (tipo == 'conta poupança' || tipo == 'poupança' || tipo == 'poupanca') {
      _selectedTipo = 'Conta Poupança';
    } else {
      _selectedTipo = 'Conta Corrente';
    }
  }

  @override
  void dispose() {
    // Libera o controlador ao destruir o widget
    _nomeCtrl.dispose();
    super.dispose();
  }

  // Função chamada ao clicar em "Salvar"
  void _saveEditAccount() {
    final nome = _nomeCtrl.text.trim();
    // Validação do nome (apenas letras e espaços)
    if (nome.isEmpty || !RegExp(r'^[A-Za-zÀ-ÿ\s]+$').hasMatch(nome)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O nome só pode conter letras e espaços.')),
      );
      return;
    }
    // Cria o objeto ContaModel editado com os novos dados
    final contaEditada = ContaModel(
      idConta: widget.conta.idConta,
      nome: nome,
      tipo: _selectedTipo,
      saldoInicial: widget.conta.saldoInicial,
      saldoAtual: widget.conta.saldoAtual,
      idUsuario: widget.conta.idUsuario,
    );
    // Chama o callback passando o objeto editado
    widget.onSave(contaEditada);
    // Fecha o modal
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Conta'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Campo para editar o nome da conta
            TextField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome da conta'),
              inputFormatters: [
                // Permite apenas letras e espaços
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÀ-ÿ\s]')),
              ],
            ),
            const SizedBox(height: 16),
            // Dropdown para editar o tipo de conta
            DropdownButtonFormField<String>(
              value: _selectedTipo,
              decoration: const InputDecoration(labelText: 'Tipo de conta'),
              items: const [
                DropdownMenuItem(
                  value: 'Conta Corrente',
                  child: Text('Conta Corrente'),
                ),
                DropdownMenuItem(
                  value: 'Conta Poupança',
                  child: Text('Conta Poupança'),
                ),
              ],
              onChanged: (value) {
                // Atualiza o tipo selecionado ao mudar
                if (value != null) setState(() => _selectedTipo = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        // Botão para cancelar e fechar o modal
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        // Botão para salvar as alterações
        ElevatedButton(
          onPressed: _saveEditAccount,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}