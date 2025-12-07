import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.account_balance, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cash',
                style: TextStyle(
                  color: scheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                'Gerencie seus gastos',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ]),
        IconButton(
          onPressed: () => Navigator.of(context).pushNamed('/profile'),
          icon: Icon(Icons.person_outline, color: Colors.white70),
        ),
      ],
    );
  }
}