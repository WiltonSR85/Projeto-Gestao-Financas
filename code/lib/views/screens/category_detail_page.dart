import 'package:flutter/material.dart';
import '../../widgets/accounts/transaction_history_card.dart';
import '/controllers/category_controller.dart';
import '../../../models/category_model.dart';

class CategoryDetailPage extends StatefulWidget {
  final int categoriaId;
  final Color color;

  const CategoryDetailPage({
    required this.categoriaId,
    required this.color,
    super.key,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  CategoriaModel? _categoria;
  bool _isLoading = true;
  
  final List<Map<String, dynamic>> _transacoesExemplo = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final categoria = await CategoriaController.instance.getCategoriaById(widget.categoriaId);
      
      setState(() {
        _categoria = categoria;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao carregar dados: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detalhes da Categoria',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          )
        : _categoria == null
          ? const Center(
              child: Text(
                'Categoria não encontrada',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [widget.color, widget.color.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 18,
                          color: Colors.black.withOpacity(0.3),
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                _getIconData(_categoria!.icone),
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _categoria!.nome,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _categoria!.tipo,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Transações',
                              '${_transacoesExemplo.length}',
                              Icons.receipt_long,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.white24,
                            ),
                            _buildStatItem(
                              'Total',
                              'R\$ 0,00',
                              Icons.attach_money,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Histórico de Transações',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_transacoesExemplo.length} itens',
                          style: TextStyle(
                            color: widget.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Lista de transações
                  _transacoesExemplo.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_outlined,
                                size: 64,
                                color: Colors.white.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Nenhuma transação encontrada',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'As transações desta categoria aparecerão aqui',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Column(
                        children: _transacoesExemplo.map((transacao) {
                          return TransactionHistoryCard(
                            icon: Icons.shopping_cart,
                            iconColor: widget.color,
                            title: transacao['titulo'],
                            date: transacao['data'],
                            account: transacao['conta'],
                            category: _categoria!.nome,
                            value: transacao['valor'],
                            isIncome: transacao['tipo'] == 'Receita',
                          );
                        }).toList(),
                      ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.8), size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  IconData _getIconData(String? iconName) {
    final iconMap = {
      'shopping_cart': Icons.shopping_cart,
      'restaurant': Icons.restaurant,
      'directions_bus': Icons.directions_bus,
      'local_hospital': Icons.local_hospital,
      'school': Icons.school,
      'home': Icons.home,
      'bolt': Icons.bolt,
      'phone_android': Icons.phone_android,
      'attach_money': Icons.attach_money,
      'card_giftcard': Icons.card_giftcard,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}