import 'package:flutter/material.dart';
import '../services/navigation_service.dart';

class AppBottomNavBar extends StatelessWidget {
  final String currentRoute;

  const AppBottomNavBar({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('🎯 AppBottomNavBar: Building for route: $currentRoute');
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _NavItem(
              icon: Icons.home,
              isActive: currentRoute == '/home',
              onPressed: () => NavigationService().navigateTo(context, '/home'),
            ),
            _NavItem(
              icon: Icons.compare_arrows,
              isActive: currentRoute == '/history',
              onPressed: () =>
                  NavigationService().navigateTo(context, '/history'),
            ),
            _NavItem(
              icon: Icons.add,
              isActive: currentRoute == '/new_trip',
              onPressed: () =>
                  NavigationService().navigateTo(context, '/new_trip'),
              isCenter: true,
            ),
            _NavItem(
              icon: Icons.menu,
              isActive: currentRoute == '/profile',
              onPressed: () =>
                  NavigationService().navigateTo(context, '/profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onPressed;
  final bool isCenter;

  const _NavItem({
    required this.icon,
    required this.isActive,
    required this.onPressed,
    this.isCenter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isCenter
          ? BoxDecoration(
              color: isActive ? const Color(0xFF007399) : Colors.white,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: Colors.black12),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: const Color(0xFF007399).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            )
          : null,
      child: IconButton(
        icon: Icon(
          icon,
          size: 28,
          color: isCenter
              ? (isActive ? Colors.white : Colors.black87)
              : (isActive ? const Color(0xFF007399) : Colors.black54),
        ),
        onPressed: onPressed,
        splashRadius: 24,
      ),
    );
  }
}
