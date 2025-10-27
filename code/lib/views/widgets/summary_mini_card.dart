import 'package:flutter/material.dart';

class SummaryMiniCard extends StatelessWidget {
  final String title;
  final String amount;
  final double progress;
  final Color color;

  const SummaryMiniCard({
    super.key,
    required this.title,
    required this.amount,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.trending_up, color: color),
            ),
            const SizedBox(width: 10),
            Text(title, style: TextStyle(color: Colors.white.withOpacity(0.9))),
          ]),
          const SizedBox(height: 12),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          )
        ],
      ),
    );
  }
}