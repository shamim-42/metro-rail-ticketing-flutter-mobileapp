import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../shared/services/navigation_service.dart';
import '../../shared/services/token_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for 3 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Test SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final testValue = prefs.getString('test_key');
      print('🔍 Debug - SharedPreferences test: $testValue');

      // Set a test value
      await prefs.setString('test_key', 'test_value');
      final testValue2 = prefs.getString('test_key');
      print('🔍 Debug - SharedPreferences test after set: $testValue2');
    } catch (e) {
      print('❌ Error with SharedPreferences: $e');
    }

    // Check if user is already logged in
    final token = await TokenService.getToken();
    final isLoggedIn = await TokenService.isLoggedIn();

    print('🔍 Debug - Token: $token');
    print('🔍 Debug - IsLoggedIn: $isLoggedIn');

    if (isLoggedIn) {
      print('🔑 User is already logged in, navigating to home');
      NavigationService().navigateTo(context, '/home');
    } else {
      print('🔑 User is not logged in, navigating to login');
      NavigationService().navigateTo(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F4F8), // Light blue background
      body: SafeArea(
        child: Column(
          children: [
            // Top section with plants
            Expanded(
              flex: 3,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F4F8), // Light blue background
                ),
                child: Stack(
                  children: [
                    // White surface for plants
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                      ),
                    ),
                    // Plants
                    Positioned(
                      bottom: 20,
                      left: 60,
                      child: Row(
                        children: [
                          // Left plant (succulent in teal pot)
                          Container(
                            width: 60,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFF20B2AA), // Teal pot
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.eco,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Right plant (snake plant in white pot)
                          Container(
                            width: 50,
                            height: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE0E0E0),
                                width: 1,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.eco,
                                color: Color(0xFF4CAF50),
                                size: 25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom section with logo and buttons
            Expanded(
              flex: 4,
              child: Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFF20B2AA),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Center(
                              child: Text(
                                'D',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Digital',
                            style: TextStyle(
                              color: Color(0xFF20B2AA),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            ' Pass',
                            style: TextStyle(
                              color: Color(0xFF7F8C8D),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 60),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            NavigationService().navigateTo(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF34495E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            NavigationService()
                                .navigateTo(context, '/register');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF34495E),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Register',
                            style: TextStyle(
                              color: Color(0xFF34495E),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
