import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/service_illustration.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My account',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const SizedBox(height: 16),
        const Center(child: ServiceIllustration(size: 112)),
        const SizedBox(height: 16),
        Text(
            user?.name?.isNotEmpty == true
                ? user!.name!
                : 'Welcome to ServiceHub',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
            user?.isWorker == true
                ? 'Service professional'
                : 'Your home, in good hands',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 30),
        Card(
            child: Column(children: [
          ListTile(
              leading:
                  const Icon(Icons.phone_outlined, color: AppColors.primary),
              title: const Text('Mobile number'),
              subtitle: Text(user?.mobileNumber ?? 'Not available')),
          const Divider(height: 1, indent: 56),
          ListTile(
              leading:
                  const Icon(Icons.badge_outlined, color: AppColors.primary),
              title: const Text('Account type'),
              subtitle: Text(user?.isWorker == true ? 'Worker' : 'Customer')),
        ])),
        if (user?.isWorker == true) ...[
          const SizedBox(height: 16),
          Card(
              child: ListTile(
                  leading: const Icon(Icons.grid_view_rounded,
                      color: AppColors.primary),
                  title: const Text('My services'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.selectCategories))),
        ],
        const SizedBox(height: 28),
        OutlinedButton.icon(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, AppRoutes.login, (_) => false);
              }
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Sign out')),
      ]),
    );
  }
}
