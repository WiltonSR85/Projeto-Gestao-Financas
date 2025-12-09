import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/account_model.dart';

class AddAccountModal extends StatefulWidget {
  final void Function(ContaModel conta) onSave;

  const AddAccountModal({required this.onSave, super.key});

  @override
  State<AddAccountModal> createState() => _AddAccountModalState();
}

class _AddAccountModalState extends State<AddAccountModal> {
  final _nomeCtrl = TextEditingController();
  final _saldoCtrl = TextEditingController();
  String _selectedTipo = 'Conta Corrente';
  String? _errorMsg;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _saldoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Conta'),
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
            const SizedBox(height: 16),
            TextField(
              controller: _saldoCtrl,
              decoration: const InputDecoration(labelText: 'Saldo inicial'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
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
            final tipo = _selectedTipo;
            final saldoStr = _saldoCtrl.text.replaceAll(',', '.');
            final saldo = double.tryParse(saldoStr) ?? -1;

            if (nome.isEmpty || saldoStr.isEmpty) {
              setState(() => _errorMsg = 'Preencha todos os campos.');
              return;
            }

            final conta = ContaModel(
              nome: nome,
              tipo: tipo,
              saldoInicial: saldo,
              saldoAtual: saldo,
              idUsuario: 0, 
            );
            widget.onSave(conta);
            Navigator.of(context).pop();
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}