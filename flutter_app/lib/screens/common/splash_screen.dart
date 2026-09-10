// lib/screens/common/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/service_illustration.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.loadSession();
    await Future.delayed(
        const Duration(milliseconds: 800)); // brief brand moment

    if (!mounted) return;

    final user = authProvider.user;
    if (user == null) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else if (user.isCustomer) {
      Navigator.pushReplacementNamed(context, AppRoutes.customerHome);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.workerHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ServiceIllustration(size: 140, fullBody: true),
            SizedBox(height: 16),
            Text(
              'ServiceHub',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Get work done, fast',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
