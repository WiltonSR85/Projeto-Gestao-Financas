import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/account_model.dart';

// Modal para adicionar uma nova conta
class AddAccountModal extends StatefulWidget {
  // Callback chamado ao salvar a conta preenchida
  final void Function(ContaModel conta) onSave;

  const AddAccountModal({required this.onSave, super.key});

  @override
  State<AddAccountModal> createState() => _AddAccountModalState();
}

class _AddAccountModalState extends State<AddAccountModal> {
  // Controladores para os campos de texto
  final _nomeCtrl = TextEditingController();
  final _saldoCtrl = TextEditingController();
  // Valor selecionado do tipo de conta
  String _selectedTipo = 'Conta Corrente';
  // Mensagem de erro (se houver)
  String? _errorMsg;

  @override
  void dispose() {
    // Libera os controladores ao destruir o widget
    _nomeCtrl.dispose();
    _saldoCtrl.dispose();
    super.dispose();
  }

  void _saveAccount() {
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
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nova Conta'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Campo para nome da conta
            TextField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome da conta'),
              inputFormatters: [
                // Permite apenas letras e espaços
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÀ-ÿ\s]')),
              ],
            ),
            const SizedBox(height: 16),
            // Dropdown para selecionar tipo de conta
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
            // Campo para saldo inicial
            TextField(
              controller: _saldoCtrl,
              decoration: const InputDecoration(labelText: 'Saldo inicial'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                // Permite apenas números e até duas casas decimais
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
            // Exibe mensagem de erro, se houver
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
        // Botão para cancelar e fechar o modal
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        // Botão para salvar a conta
        ElevatedButton(
          onPressed: _saveAccount,
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}