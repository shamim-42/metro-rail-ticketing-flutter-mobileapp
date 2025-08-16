import 'package:flutter/material.dart';
import '../services/navigation_service.dart';

class NavigationDebug extends StatelessWidget {
  const NavigationDebug({super.key});

  @override
  Widget build(BuildContext context) {
    final navigationService = NavigationService();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Navigation Debug',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Current Route: ${navigationService.currentRoute}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            'Previous Route: ${navigationService.previousRoute ?? 'None'}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            'Can Go Back: ${navigationService.canGoBack()}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          const Text(
            'History:',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          ...navigationService.history.map((route) => Text(
                '  → $route',
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              )),
        ],
      ),
    );
  }
}
