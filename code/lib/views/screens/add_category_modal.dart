import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../models/category_model.dart';

class AddCategoryModal extends StatefulWidget {
  final void Function(CategoriaModel categoria) onSave;
  final CategoriaModel? categoria;

  const AddCategoryModal({
    required this.onSave,
    this.categoria,
    super.key,
  });

  @override
  State<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends State<AddCategoryModal> {
  final _nomeCtrl = TextEditingController();
  String _selectedTipo = 'Despesa';
  String _selectedIcon = 'shopping_cart';
  String _selectedColor = 'orange';
  String? _errorMsg;

  final List<Map<String, dynamic>> _icons = [
    {'name': 'shopping_cart', 'icon': Icons.shopping_cart, 'label': 'Compras'},
    {'name': 'restaurant', 'icon': Icons.restaurant, 'label': 'Alimentação'},
    {'name': 'directions_bus', 'icon': Icons.directions_bus, 'label': 'Transporte'},
    {'name': 'local_hospital', 'icon': Icons.local_hospital, 'label': 'Saúde'},
    {'name': 'school', 'icon': Icons.school, 'label': 'Educação'},
    {'name': 'home', 'icon': Icons.home, 'label': 'Casa'},
    {'name': 'bolt', 'icon': Icons.bolt, 'label': 'Energia'},
    {'name': 'phone_android', 'icon': Icons.phone_android, 'label': 'Telefone'},
    {'name': 'attach_money', 'icon': Icons.attach_money, 'label': 'Salário'},
    {'name': 'card_giftcard', 'icon': Icons.card_giftcard, 'label': 'Presente'},
  ];

  final List<Map<String, dynamic>> _colors = [
    {'name': 'orange', 'color': const Color(0xFFF97316)},
    {'name': 'purple', 'color': const Color(0xFFB721FF)},
    {'name': 'green', 'color': const Color(0xFF22C55E)},
    {'name': 'blue', 'color': const Color(0xFF2563EB)},
    {'name': 'red', 'color': const Color(0xFFEF4444)},
    {'name': 'teal', 'color': const Color(0xFF14B8A6)},
    {'name': 'pink', 'color': const Color(0xFFEC4899)},
    {'name': 'yellow', 'color': const Color(0xFFFBBF24)},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.categoria != null) {
      _nomeCtrl.text = widget.categoria!.nome;
      _selectedTipo = widget.categoria!.tipo;
      _selectedIcon = widget.categoria!.icone ?? 'shopping_cart';
      _selectedColor = widget.categoria!.cor ?? 'orange';
    }
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoria != null;
    
    return AlertDialog(
      title: Text(isEditing ? 'Editar Categoria' : 'Nova Categoria'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nomeCtrl,
              decoration: const InputDecoration(labelText: 'Nome da categoria'),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-zÀ-ÿ\s]')),
              ],
            ),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<String>(
              value: _selectedTipo,
              decoration: const InputDecoration(labelText: 'Tipo'),
              items: const [
                DropdownMenuItem(value: 'Despesa', child: Text('Despesa')),
                DropdownMenuItem(value: 'Receita', child: Text('Receita')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedTipo = value);
              },
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Escolha um ícone:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _icons.map((iconData) {
                final isSelected = _selectedIcon == iconData['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = iconData['name']),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? Colors.orange.shade700 
                        : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.orange.shade900 : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      iconData['icon'],
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      size: 28,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            
            const Text(
              'Escolha uma cor:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colors.map((colorData) {
                final isSelected = _selectedColor == colorData['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = colorData['name']),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorData['color'],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: colorData['color'].withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                      ],
                    ),
                    child: isSelected
                      ? const Icon(Icons.check, color: Colors.white, size: 24)
                      : null,
                  ),
                );
              }).toList(),
            ),
            
            if (_errorMsg != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _errorMsg!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
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

            if (nome.isEmpty) {
              setState(() => _errorMsg = 'Preencha o nome da categoria.');
              return;
            }

            final categoria = CategoriaModel(
              idCategoria: widget.categoria?.idCategoria,
              nome: nome,
              tipo: _selectedTipo,
              idUsuario: 0,
              icone: _selectedIcon,
              cor: _selectedColor,
            );
            
            widget.onSave(categoria);
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
          ),
          child: Text(isEditing ? 'Atualizar' : 'Salvar'),
        ),
      ],
    );
  }
}