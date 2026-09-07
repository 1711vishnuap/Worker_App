// lib/screens/common/otp_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/primary_button.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  late String _mobileNumber;
  late String _userType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _mobileNumber = args['mobile_number'];
    _userType = args['user_type'];
    final devOtp = args['dev_otp'] as String?;
    // Pre-fill in development so testing is fast — remove this line
    // once you wire up a real SMS provider in production.
    if (devOtp != null && _otpController.text.isEmpty) {
      _otpController.text = devOtp;
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the 4-digit OTP')),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.verifyOtp(
      mobileNumber: _mobileNumber,
      otp: otp,
      userType: _userType,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? 'Invalid OTP')),
      );
      return;
    }

    final user = authProvider.user!;
    Navigator.pushNamedAndRemoveUntil(
      context,
      user.isCustomer ? AppRoutes.customerHome : AppRoutes.workerHome,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the 4-digit code sent to',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                _mobileNumber,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 28,
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold),
                decoration: const InputDecoration(counterText: ''),
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                  label: 'Verify & Continue',
                  isLoading: isLoading,
                  onPressed: _verify),
            ],
          ),
        ),
      ),
    );
  }
}
