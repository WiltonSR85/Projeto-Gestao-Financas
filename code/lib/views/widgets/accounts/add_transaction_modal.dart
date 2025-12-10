import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/transaction_model.dart';

// Modal para adicionar uma nova transação (receita ou despesa)
class AddTransactionModal extends StatefulWidget {
  final bool isIncome;  // Indica se é receita (true) ou despesa (false)
  final int contaId;  // ID da conta à qual a transação será vinculada
  // Callback chamado ao salvar, recebendo o TransactionModel pronto
  final void Function(TransactionModel tx) onSave;

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
  // Controladores para os campos de texto do formulário
  final _titleCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  // Contexto do widget pai, usado para abrir o seletor de data
  late BuildContext parentContext;

  @override
  void initState() {
    super.initState();
    // Inicializa o campo de data com a data atual
    _dateCtrl.text = DateFormat('dd/MM/yyyy').format(DateTime.now());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Salva o contexto para usar no seletor de data
    parentContext = context;
  }

  @override
  void dispose() {
    // Libera os controladores ao destruir o widget
    _titleCtrl.dispose();
    _valueCtrl.dispose();
    _dateCtrl.dispose();
    _categoryCtrl.dispose();
    super.dispose();
  }

  // Abre o seletor de data e atualiza o campo de data
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

  // Cria o TransactionModel com os dados preenchidos e chama o callback
  void _saveTransaction() {
    final tx = TransactionModel(
      tipo: widget.isIncome ? 'receita' : 'despesa', // Define tipo
      valor: double.tryParse(_valueCtrl.text.replaceAll(',', '.')) ?? 0.0, // Converte valor para double
      data: _dateCtrl.text, // Data da transação
      descricao: _titleCtrl.text, // Título da transação
      recorrente: false, // Sempre falso neste modal
      idConta: widget.contaId, // ID da conta vinculada
      idCategoria: 0, // Categoria fixa (pode ser ajustado)
    );
    widget.onSave(tx); // Chama o callback passando o objeto pronto
    Navigator.of(context).pop(); // Fecha o modal
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // Título do modal depende se é receita ou despesa
      title: Text(widget.isIncome ? 'Nova Receita' : 'Nova Despesa'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Campo para o título da transação
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 18),
            // Campo para o valor da transação
            TextField(
              controller: _valueCtrl,
              decoration: const InputDecoration(labelText: 'Valor'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 18),
            // Campo para a data da transação (abre seletor ao clicar)
            TextField(
              controller: _dateCtrl,
              decoration: const InputDecoration(labelText: 'Data'),
              readOnly: true,
              onTap: _selectDate,
            ),
            const SizedBox(height: 18),
            // Campo para a categoria da transação
            TextField(
              controller: _categoryCtrl,
              decoration: const InputDecoration(labelText: 'Categoria'),
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
        // Botão para salvar a transação
        ElevatedButton(
          onPressed: _saveTransaction,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}