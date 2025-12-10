import 'package:flutter/material.dart';
import '../../widgets/home/home_header.dart';
import '../../widgets/category/category_card.dart';
import '../../widgets/category/add_category_modal.dart';
import '/controllers/category_controller.dart';
import '../../../controllers/auth_controller.dart';
import './category_detail_page.dart';
import '../../../models/category_model.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  Future<List<CategoriaModel>>? _categoriasFuture;
  Future<Map<String, int>>? _countFuture;
  int usuarioAtualId = 0;
  String _filtroSelecionado = 'Todas';

  @override
  void initState() {
    super.initState();
    _getUsuarioAtualId();
  }

  Future<void> _getUsuarioAtualId() async {
    final id = await AuthController.instance.getUsuarioLogadoId();
    setState(() {
      usuarioAtualId = id;
      _loadCategorias();
    });
  }

  void _loadCategorias() {
    setState(() {
      if (_filtroSelecionado == 'Todas') {
        _categoriasFuture = CategoriaController.instance.getCategoriasByUsuario(usuarioAtualId);
      } else {
        _categoriasFuture = CategoriaController.instance.getCategoriasByTipo(
          usuarioAtualId,
          _filtroSelecionado == 'Despesas' ? 'Despesa' : 'Receita',
        );
      }
      _countFuture = CategoriaController.instance.getCountByTipo(usuarioAtualId);
    });
  }

  void _showAddCategoryModal() {
    showDialog(
      context: context,
      builder: (_) => AddCategoryModal(
        onSave: (categoria) async {
          try {
            final novaCategoria = CategoriaModel(
              nome: categoria.nome,
              tipo: categoria.tipo,
              idUsuario: usuarioAtualId,
              icone: categoria.icone,
              cor: categoria.cor,
            );
            await CategoriaController.instance.addCategoria(novaCategoria);
            _loadCategorias();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Categoria criada com sucesso!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString().replaceAll('Exception: ', '')),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HomeHeader(),
            const SizedBox(height: 18),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade700, Colors.orange.shade500],
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
                  const Text(
                    'Categorias',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Organize suas transações por categorias',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 18),
            
            FutureBuilder<Map<String, int>>(
              future: _countFuture,
              builder: (context, snapshot) {
                final counts = snapshot.data ?? {'todas': 0, 'despesas': 0, 'receitas': 0};
                
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('Todas', counts['todas']!),
                                const SizedBox(width: 8),
                                _buildFilterChip('Despesas', counts['despesas']!),
                                const SizedBox(width: 8),
                                _buildFilterChip('Receitas', counts['receitas']!),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _showAddCategoryModal,
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Nova Categoria'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 18),
            
            FutureBuilder<List<CategoriaModel>>(
              future: _categoriasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(color: Colors.orange),
                    ),
                  );
                }
                
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 64,
                            color: Colors.white.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma categoria cadastrada',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                final categorias = snapshot.data!;
                return Column(
                  children: categorias.map((categoria) {
                    return CategoryCard(
                      categoryName: categoria.nome,
                      categoryType: categoria.tipo,
                      icon: _getIconData(categoria.icone),
                      color: _getColor(categoria.cor, categoria.tipo),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CategoryDetailPage(
                              categoriaId: categoria.idCategoria!,
                              color: _getColor(categoria.cor, categoria.tipo),
                            ),
                          ),
                        );
                        if (result == true) {
                          _loadCategorias();
                        }
                      },
                      onEdit: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddCategoryModal(
                            categoria: categoria,
                            onSave: (categoriaAtualizada) async {
                              try {
                                final updated = CategoriaModel(
                                  idCategoria: categoria.idCategoria,
                                  nome: categoriaAtualizada.nome,
                                  tipo: categoriaAtualizada.tipo,
                                  idUsuario: usuarioAtualId,
                                  icone: categoriaAtualizada.icone,
                                  cor: categoriaAtualizada.cor,
                                );
                                await CategoriaController.instance.updateCategoria(updated);
                                _loadCategorias();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Categoria atualizada!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString().replaceAll('Exception: ', '')),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                      onDelete: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Excluir categoria'),
                            content: Text(
                              'Tem certeza que deseja excluir a categoria "${categoria.nome}"?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          try {
                            await CategoriaController.instance.deleteCategoria(categoria.idCategoria!);
                            _loadCategorias();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Categoria excluída com sucesso!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erro ao excluir: ${e.toString()}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      },
                    );
                  }).toList(),
                );
              },
            ),
            
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count) {
    final isSelected = _filtroSelecionado == label;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _filtroSelecionado = label;
          _loadCategorias();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.shade700 : Colors.black.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange.shade700 : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
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

  Color _getColor(String? colorStr, String tipo) {
    final colorMap = {
      'orange': const Color(0xFFF97316),
      'purple': const Color(0xFFB721FF),
      'green': const Color(0xFF22C55E),
      'blue': const Color(0xFF2563EB),
      'red': const Color(0xFFEF4444),
      'teal': const Color(0xFF14B8A6),
      'pink': const Color(0xFFEC4899),
      'yellow': const Color(0xFFFBBF24),
    };
    
    if (colorStr != null && colorMap.containsKey(colorStr)) {
      return colorMap[colorStr]!;
    }
    
    return tipo == 'Despesa' ? const Color(0xFFEF4444) : const Color(0xFF22C55E);
  }
}