// lib/screens/common/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/service_illustration.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _mobileController = TextEditingController();
  String _userType = 'customer';

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final mobile = _mobileController.text.trim();
    if (mobile.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid mobile number')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final devOtp = await authProvider.sendOtp(mobile);

    if (!mounted) return;

    if (authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage!)),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.otp,
      arguments: {
        'mobile_number': mobile,
        'user_type': _userType,
        'dev_otp': devOtp
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.home_repair_service_rounded,
                    color: AppColors.primary, size: 24),
                SizedBox(width: 8),
                Text('ServiceHub',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.5)),
              ]),
              const SizedBox(height: 26),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(32)),
                padding: const EdgeInsets.symmetric(vertical: 22),
                child: const Center(
                    child: ServiceIllustration(size: 190, fullBody: true)),
              ),
              const SizedBox(height: 28),
              const Text(
                'A helping hand.\nJust when you need it.',
                style: TextStyle(
                    fontSize: 27,
                    height: 1.2,
                    letterSpacing: -.9,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Connect with local professionals.\nMake room for the things you love.',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 24),

              // I am a...
              const Text('How will you use ServiceHub?',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                      child: _roleCard(
                          'customer', 'I need a service', Icons.home_outlined)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: _roleCard('worker', 'I offer services',
                          Icons.handyman_outlined)),
                ],
              ),
              const SizedBox(height: 24),

              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                maxLength: 15,
                decoration: const InputDecoration(
                  labelText: 'Mobile number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  counterText: '',
                ),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Continue',
                icon: Icons.arrow_forward_rounded,
                isLoading: isLoading,
                onPressed: _continue,
              ),
              const SizedBox(height: 12),
              const Center(
                  child: Text('Sign in with your mobile number',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 11))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(String value, String label, IconData icon) {
    final selected = _userType == value;
    return Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _userType = value),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryLight : AppColors.surface,
              border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: 1.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Icon(icon,
                    color:
                        selected ? AppColors.primary : AppColors.textSecondary),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: selected ? AppColors.primary : AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
