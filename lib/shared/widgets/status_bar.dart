import 'package:flutter/material.dart';

class CustomStatusBar extends StatelessWidget {
  const CustomStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time
          const Text(
            '9:41',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          // Status icons
          Row(
            children: [
              const Icon(
                Icons.signal_wifi_4_bar,
                size: 16,
                color: Color(0xFF2C3E50),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.signal_cellular_4_bar,
                size: 16,
                color: Color(0xFF2C3E50),
              ),
              const SizedBox(width: 4),
              Container(
                width: 24,
                height: 12,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF2C3E50), width: 1),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
