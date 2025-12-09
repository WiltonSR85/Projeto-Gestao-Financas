import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/transaction_model.dart';

class AddTransactionModal extends StatefulWidget {
  final bool isIncome;
  final int contaId;
  final void Function({
    required String title,
    required String value,
    required String date,
    required int contaId,
    required String category,
  }) onSave;

  const AddTransactionModal({
    required this.isIncome,
    required this.contaId,
    required this.onSave,
    super.key,
  });

  @override
  State<AddTransactionModal> createState() => _AddTransactionModalState();
}

class _AddTransactionModalState extends State<AddTransactionModal> {
  final _titleCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  late BuildContext parentContext;

  @override
  void initState() {
    super.initState();
    _dateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    parentContext = context;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _valueCtrl.dispose();
    _dateCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final initialDate = DateFormat('dd/MM/yyyy').parse(_dateCtrl.text);

    final picked = await showDatePicker(
      context: parentContext,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('pt', 'BR'),
    );

    if (picked != null) {
      setState(() {
        _dateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _saveTransaction() {
    widget.onSave(
      title: _titleCtrl.text,
      value: _valueCtrl.text,
      date: _dateCtrl.text,
      contaId: widget.contaId,
      category: _categoryCtrl.text,
    );
    Navigator.of(context).pop();
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
            const SizedBox(height: 18),
            TextField(
              controller: _valueCtrl,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _dateCtrl,
              decoration: const InputDecoration(labelText: 'Data'),
              readOnly: true,
              onTap: _selectDate,
            ),
            const SizedBox(height: 18),
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
          onPressed: _saveTransaction,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}