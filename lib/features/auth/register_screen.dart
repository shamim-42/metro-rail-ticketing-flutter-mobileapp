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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthSuccess) {
          print('🔑 Registration successful, saving token: ${state.token}');
          // Save token and user data
          await TokenService.saveToken(state.token);
          await TokenService.saveUserId(state.user.id);

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
                        'Hello!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const Text(
                        'Register to get started',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Full Name Field
                      TextField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Email Field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Phone Number Field
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
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
                          hintText: 'Password',
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

                      const SizedBox(height: 20),

                      // Confirm Password Field
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: const TextStyle(
                            color: Color(0xFF7F8C8D),
                            fontSize: 16,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: const Color(0xFF7F8C8D),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Register Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: state is AuthLoading
                                  ? null
                                  : () {
                                      final fullName =
                                          _fullNameController.text.trim();
                                      final email =
                                          _emailController.text.trim();
                                      final phoneNumber =
                                          _phoneController.text.trim();
                                      final password =
                                          _passwordController.text.trim();
                                      final confirmPassword =
                                          _confirmPasswordController.text
                                              .trim();

                                      if (fullName.isEmpty ||
                                          email.isEmpty ||
                                          phoneNumber.isEmpty ||
                                          password.isEmpty ||
                                          confirmPassword.isEmpty) {
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

                                      if (password != confirmPassword) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content:
                                                Text('Passwords do not match'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      context.read<AuthBloc>().add(
                                            AuthRegisterRequested(fullName,
                                                email, phoneNumber, password),
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
                                      'Register',
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
                              'Already have an account? ',
                              style: TextStyle(
                                color: Color(0xFF7F8C8D),
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                NavigationService()
                                    .navigateTo(context, '/login');
                              },
                              child: const Text(
                                'Login Now',
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
