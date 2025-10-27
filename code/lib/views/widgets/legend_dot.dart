import 'package:flutter/material.dart';

class LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  
  const LegendDot({
    super.key, 
    required this.color, 
    required this.label,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12, 
          height: 12, 
          decoration: BoxDecoration(
            color: color, 
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label, 
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}