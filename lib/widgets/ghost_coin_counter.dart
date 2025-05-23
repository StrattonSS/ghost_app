import 'package:flutter/material.dart';
import '../services/tool_unlock_service.dart';

class GhostCoinCounter extends StatelessWidget {
  const GhostCoinCounter({super.key});

  @override
  Widget build(BuildContext context) {
    final coinCount = ToolUnlockService.instance.ghostCoins;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
              Icons.monetization_on, color: Colors.amberAccent, size: 20),
          const SizedBox(width: 4),
          Text(
            '$coinCount',
            style: const TextStyle(
              color: Colors.amberAccent,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}