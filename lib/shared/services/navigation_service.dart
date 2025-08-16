import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  // Navigation history stack
  final List<String> _navigationHistory = [];

  // Routes that should not be added to history (entry points)
  final Set<String> _excludedRoutes = {
    '/',
    '/login',
    '/register',
  };

  // Initialize with splash screen
  void initialize() {
    _navigationHistory.clear();
    _navigationHistory.add('/');
  }

  // Navigate to a new route
  void navigateTo(BuildContext context, String route) {
    if (!_excludedRoutes.contains(route)) {
      _navigationHistory.add(route);
    }
    context.go(route);
  }

  // Go back to previous route
  void goBack(BuildContext context) {
    if (_navigationHistory.length > 1) {
      _navigationHistory.removeLast(); // Remove current route
      String previousRoute = _navigationHistory.last;
      context.go(previousRoute);
    } else {
      // If no history, go to home
      context.go('/home');
    }
  }

  // Check if can go back
  bool canGoBack() {
    return _navigationHistory.length > 1;
  }

  // Get current route
  String get currentRoute {
    return _navigationHistory.isNotEmpty ? _navigationHistory.last : '/';
  }

  // Get previous route
  String? get previousRoute {
    if (_navigationHistory.length > 1) {
      return _navigationHistory[_navigationHistory.length - 2];
    }
    return null;
  }

  // Clear history (useful for logout)
  void clearHistory() {
    _navigationHistory.clear();
    _navigationHistory.add('/');
  }

  // Add route to history without navigating
  void addToHistory(String route) {
    if (!_excludedRoutes.contains(route) &&
        !_navigationHistory.contains(route)) {
      _navigationHistory.add(route);
    }
  }

  // Get navigation history for debugging
  List<String> get history => List.from(_navigationHistory);
}
