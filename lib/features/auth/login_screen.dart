import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';
import '../../shared/widgets/status_bar.dart';
import '../../shared/services/navigation_service.dart';
import '../../shared/services/token_service.dart';
import '../trip/bloc/trip_bloc.dart';
import '../trip/bloc/trip_event.dart';
import '../profile/bloc/user_bloc.dart';
import '../profile/bloc/user_event.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthSuccess) {
          print('🔑 Login successful, saving token: ${state.token}');
          // Save token and user data
          await TokenService.saveToken(state.token);
          await TokenService.saveUserId(state.user.id);

          // Verify token was saved
          final savedToken = await TokenService.getToken();
          print('🔑 Token saved successfully: $savedToken');

          // Preload app data BEFORE navigation
          print('🎯 Preloading stations before navigation...');
          context.read<TripBloc>().add(LoadAllStations());
          context.read<UserBloc>().add(LoadUserProfile());

          // Wait a moment for the loading to start
          await Future.delayed(const Duration(milliseconds: 500));

          // Navigate to home
          NavigationService().navigateTo(context, '/home');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Custom Status Bar
              const CustomStatusBar(),

              // Main Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // Welcome Title
                      const Text(
                        'Welcome back!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const Text(
                        'Glad to see you, Again!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Email Field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Enter your email',
                          hintStyle: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: const TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 16,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF7F8C8D),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Navigate to forgot password screen
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: Color(0xFF20B2AA),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Login Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      final email =
                                          _emailController.text.trim();
                                      final password =
                                          _passwordController.text.trim();

                                      if (email.isEmpty || password.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Please fill in all fields'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      context.read<AuthBloc>().add(
                                            AuthLoginRequested(email, password),
                                          );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF34495E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state is AuthLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),

                      const Spacer(),

                      // Footer
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Color(0xFF7F8C8D),
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                NavigationService()
                                    .navigateTo(context, '/register');
                              },
                              child: const Text(
                                'Register Now',
                                style: TextStyle(
                                  color: Color(0xFF20B2AA),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
