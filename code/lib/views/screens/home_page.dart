import 'package:flutter/material.dart';
import '/models/category_data.dart';
import '../widgets/home/home_header.dart';
import '../widgets/home/balance_card.dart';
import '../widgets/home/summary_chart_section.dart';
import '../widgets/home/categories_section.dart';
import '../widgets/summary_mini_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Lista de categorias padrão
  static const List<CategoryData> _defaultCategories = [
    CategoryData(
      icon: Icons.shopping_cart_outlined,
      title: 'Mercado',
      color: Color(0xFFB28700),
    ),
    CategoryData(
      icon: Icons.directions_bus,
      title: 'Transporte',
      color: Color(0xFF0EA5E9),
    ),
    CategoryData(
      icon: Icons.school_outlined,
      title: 'Educação',
      color: Color(0xFFB28700),
    ),
    CategoryData(
      icon: Icons.favorite_border,
      title: 'Saúde',
      color: Color(0xFFD43F4D),
    ),
  ];

  void _onAddCategory() {
    print('Adicionar nova categoria');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const HomeHeader(),
            const SizedBox(height: 18),

            // Saldo Total
            const BalanceCard(
              balance: '\$ 4.000,00',
              percentageChange: '+15% este mês',
            ),
            const SizedBox(height: 14),

            // Entradas / Saídas
            Row(
              children: const [
                Expanded(
                  child: SummaryMiniCard(
                    title: 'Entradas',
                    amount: '\$ 2.000,00',
                    progress: 0.6,
                    color: Colors.green,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SummaryMiniCard(
                    title: 'Saídas',
                    amount: '\$ 700,00',
                    progress: 0.25,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Resumo com gráfico
            const SummaryChartSection(),
            const SizedBox(height: 18),

            // Categorias
            CategoriesSection(
              categories: _defaultCategories,
              onAddCategory: _onAddCategory,
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}