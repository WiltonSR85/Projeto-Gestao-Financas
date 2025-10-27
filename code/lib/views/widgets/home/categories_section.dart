import 'package:flutter/material.dart';
import '/models/category_data.dart';
import '../category_tile.dart';

class CategoriesSection extends StatelessWidget {
  final List<CategoryData> categories;
  final VoidCallback onAddCategory;

  const CategoriesSection({
    required this.categories,
    required this.onAddCategory,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorias',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.95),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: onAddCategory,
              icon: const Icon(Icons.add),
              label: const Text('Criar categoria'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...categories.map((category) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CategoryTile(
                icon: category.icon,
                title: category.title,
                colorLeft: category.color,
              ),
            )),
      ],
    );
  }
}