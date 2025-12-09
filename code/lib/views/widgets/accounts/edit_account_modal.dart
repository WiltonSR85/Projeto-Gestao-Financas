import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/account_model.dart';

class EditAccountModal extends StatefulWidget {
  final ContaModel conta;
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
  late TextEditingController _nomeCtrl;
  String _selectedTipo = 'Conta Corrente';

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: widget.conta.nome);
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
    _nomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar Conta'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome da conta'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÀ-ÿ\s]')),
              ],
            ),
            const SizedBox(height: 16),
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
                if (value != null) setState(() => _selectedTipo = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            final nome = _nomeCtrl.text.trim();
            if (nome.isEmpty || !RegExp(r'^[A-Za-zÀ-ÿ\s]+$').hasMatch(nome)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('O nome só pode conter letras e espaços.')),
              );
              return;
            }
            final contaEditada = ContaModel(
              idConta: widget.conta.idConta,
              nome: nome,
              tipo: _selectedTipo,
              saldoInicial: widget.conta.saldoInicial,
              saldoAtual: widget.conta.saldoAtual,
              idUsuario: widget.conta.idUsuario,
            );
            widget.onSave(contaEditada);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}