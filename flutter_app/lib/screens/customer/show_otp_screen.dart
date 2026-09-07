// lib/screens/customer/show_otp_screen.dart

import 'package:flutter/material.dart';
import '../../config/app_colors.dart';
import '../../models/work_model.dart';

class ShowOtpScreen extends StatelessWidget {
  const ShowOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final work = ModalRoute.of(context)!.settings.arguments as WorkModel;

    return Scaffold(
      appBar: AppBar(title: const Text('Your OTP')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.password_outlined, size: 48, color: AppColors.primary),
              const SizedBox(height: 20),
              const Text(
                'Share this code with your worker',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'They will need to enter it once they arrive to start the work.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Text(
                  work.otpCode ?? '----',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Do not share this code until the worker has arrived at your location.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
