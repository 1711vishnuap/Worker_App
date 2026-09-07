// lib/screens/worker/enter_otp_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/primary_button.dart';

class WorkerEnterOtpScreen extends StatefulWidget {
  const WorkerEnterOtpScreen({super.key});

  @override
  State<WorkerEnterOtpScreen> createState() => _WorkerEnterOtpScreenState();
}

class _WorkerEnterOtpScreenState extends State<WorkerEnterOtpScreen> {
  final _otpController = TextEditingController();
  late int _workId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _workId = ModalRoute.of(context)!.settings.arguments as int;
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

    final success = await context.read<WorkerProvider>().verifyOtp(_workId, otp);
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.workCompleted, arguments: _workId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<WorkerProvider>().errorMessage ?? 'Invalid OTP')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<WorkerProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ask the customer for their OTP and enter it below to start the work.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(counterText: ''),
              ),
              const SizedBox(height: 24),
              PrimaryButton(label: 'Verify & Start Work', isLoading: isLoading, onPressed: _verify),
            ],
          ),
        ),
      ),
    );
  }
}
