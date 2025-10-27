import 'package:flutter/material.dart';

class CategoryTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color colorLeft;
  
  const CategoryTile({
    super.key, 
    required this.icon, 
    required this.title, 
    required this.colorLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 68,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorLeft.withOpacity(0.95), 
                  colorLeft.withOpacity(0.55),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14), 
                bottomLeft: Radius.circular(14),
              ),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Text(
            title, 
            style: const TextStyle(
              color: Colors.white70, 
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}