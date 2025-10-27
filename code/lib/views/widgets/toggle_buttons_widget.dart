import 'package:flutter/material.dart';

class ToggleButtonsWidget extends StatefulWidget {
  const ToggleButtonsWidget({super.key});

  @override
  State<ToggleButtonsWidget> createState() => _ToggleButtonsWidgetState();
}

class _ToggleButtonsWidgetState extends State<ToggleButtonsWidget> {
  int selected = 2; // Ambos

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _chip('Entradas', 0),
      const SizedBox(width: 6),
      _chip('Saídas', 1),
      const SizedBox(width: 6),
      _chip('Ambos', 2),
    ]);
  }

  Widget _chip(String label, int idx) {
    final bool active = selected == idx;
    return GestureDetector(
      onTap: () => setState(() => selected = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? Colors.orangeAccent.withOpacity(0.95)
              : Colors.black.withOpacity(0.16),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(color: active ? Colors.black : Colors.white70),
        ),
      ),
    );
  }
}