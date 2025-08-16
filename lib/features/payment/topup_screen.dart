import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/custom_back_button.dart';
import '../../shared/widgets/status_bar.dart';

import '../profile/bloc/user_bloc.dart';
import '../profile/bloc/user_event.dart' as user_events;
import 'bloc/topup_bloc.dart';
import 'bloc/topup_event.dart';
import 'bloc/topup_state.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  final TextEditingController _amountController = TextEditingController();
  String _selectedPaymentMethod = 'cash';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _deposit() {
    print('💰 Deposit button clicked!');
    print('💰 _deposit method called successfully!');
    final amountText = _amountController.text.trim();
    print('💰 Amount text: "$amountText"');

    if (amountText.isEmpty) {
      print('❌ Amount is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final amount = int.tryParse(amountText);
    print('💰 Parsed amount: $amount');
    print('💰 Payment method: $_selectedPaymentMethod');

    if (amount == null || amount <= 0) {
      print('❌ Invalid amount: $amount');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print(
        '💰 Dispatching DepositMoney event with amount: $amount, paymentMethod: $_selectedPaymentMethod');
    context.read<TopUpBloc>().add(DepositMoney(
          amount: amount,
          paymentMethod: _selectedPaymentMethod,
        ));
    print('💰 DepositMoney event dispatched successfully');
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TopUpBloc, TopUpState>(
      listener: (context, state) {
        if (state is TopUpSuccess) {
          // Refresh user profile to update balance after money deposit
          print(
              '💰 Money deposited successfully, refreshing user profile to update balance');
          context.read<UserBloc>().add(user_events.LoadUserProfile());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully deposited ৳${state.amount}'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate back to home after successful deposit
          context.go('/home');
        } else if (state is TopUpFailure) {
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

              // Header with back button
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    const CustomBackButton(),
                    const SizedBox(width: 16),
                    const Text(
                      'Top Up Balance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Add Money to Your Wallet',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter the amount you want to add to your balance',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Amount Input
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Amount (৳)',
                          prefixIcon: const Icon(Icons.money),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8F9FA),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Payment Method Selection
                      const Text(
                        'Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: const Row(
                                children: [
                                  Icon(Icons.money, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text('Cash'),
                                ],
                              ),
                              value: 'cash',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Row(
                                children: [
                                  Icon(Icons.phone_android,
                                      color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text('Mobile Banking'),
                                ],
                              ),
                              value: 'mobile_banking',
                              groupValue: _selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  _selectedPaymentMethod = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),

                      // Deposit Button
                      BlocBuilder<TopUpBloc, TopUpState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state is TopUpLoading
                                  ? null
                                  : () {
                                      print('💰 Button pressed!');
                                      _deposit();
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF20B2AA),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: state is TopUpLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Deposit Money',
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
