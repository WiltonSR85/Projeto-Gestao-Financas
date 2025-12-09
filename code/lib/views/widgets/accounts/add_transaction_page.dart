import 'package:flutter/material.dart';

class AddTransactionModal extends StatefulWidget {
  final bool isIncome;
  final void Function({
    required String title,
    required String value,
    required String date,
    required String account,
    required String category,
  }) onSave;

  const AddTransactionModal({
    required this.isIncome,
    required this.onSave,
    super.key,
  });

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _titleCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _valueCtrl.dispose();
    _dateCtrl.dispose();
    _accountCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.isIncome ? 'Nova Receita' : 'Nova Despesa'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            TextField(
              controller: _valueCtrl,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _dateCtrl,
              decoration: const InputDecoration(labelText: 'Data (dd/mm/yyyy)'),
            ),
            TextField(
              controller: _accountCtrl,
              decoration: const InputDecoration(labelText: 'Conta'),
            ),
            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Categoria'),
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
            widget.onSave(
              title: _titleCtrl.text,
              value: _valueCtrl.text,
              date: _dateCtrl.text,
              account: _accountCtrl.text,
              category: _categoryCtrl.text,
            );
            Navigator.of(context).pop();
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}