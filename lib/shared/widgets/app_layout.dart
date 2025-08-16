import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_bottom_nav_bar.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final bool showBottomNav;

  const AppLayout({
    Key? key,
    required this.child,
    this.showBottomNav = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).uri.path;
    print('🎯 AppLayout: Building layout for route: $currentRoute');

    // If the child is already a Scaffold, we need to extract its body
    if (child is Scaffold) {
      print('🎯 AppLayout: Child is Scaffold, extracting properties');
      final scaffold = child as Scaffold;
      return Scaffold(
        appBar: scaffold.appBar,
        body: scaffold.body,
        backgroundColor: scaffold.backgroundColor,
        bottomNavigationBar: showBottomNav
            ? AppBottomNavBar(currentRoute: currentRoute)
            : scaffold.bottomNavigationBar,
        floatingActionButton: scaffold.floatingActionButton,
        drawer: scaffold.drawer,
        endDrawer: scaffold.endDrawer,
      );
    }

    // If no bottom nav needed, return child as is
    if (!showBottomNav) {
      return child;
    }

    // Wrap non-scaffold widgets
    return Scaffold(
      body: child,
      bottomNavigationBar: AppBottomNavBar(currentRoute: currentRoute),
    );
  }
}

/// Routes that should have the bottom navigation bar
const Set<String> _routesWithBottomNav = {
  '/home',
  '/history',
  '/profile',
  '/new_trip',
  '/topup',
};

/// Check if the current route should show bottom navigation
bool shouldShowBottomNav(String route) {
  return _routesWithBottomNav.contains(route);
}
