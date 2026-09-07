// lib/screens/worker/worker_home_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_provider.dart';
import '../../services/location_service.dart';
import 'available_works_screen.dart';
import 'work_history_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  int _tabIndex = 0;
  final _locationService = LocationService();
  StreamSubscription? _locationSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final workerProvider = context.read<WorkerProvider>();
    await workerProvider.ensureProfile();

    // Push our initial location, then keep it updated in the background
    // so nearby-worker matching stays accurate.
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      workerProvider.updateLocation(position.latitude, position.longitude);
    }
    _locationSub = _locationService.watchLocation().listen((pos) {
      context.read<WorkerProvider>().updateLocation(pos.latitude, pos.longitude);
    });
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [const _WorkerHomeTab(), const AvailableWorksScreen(embedded: true), const WorkHistoryScreen(embedded: true)];

    return Scaffold(
      body: SafeArea(child: pages[_tabIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Available'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}

class _WorkerHomeTab extends StatelessWidget {
  const _WorkerHomeTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Hi there 👋', style: TextStyle(color: AppColors.textSecondary)),
                  Text(
                    user?.name?.isNotEmpty == true ? user!.name! : 'Worker',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: AppColors.textSecondary),
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (r) => false);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: ListTile(
              leading: const Icon(Icons.category_outlined, color: AppColors.primary),
              title: const Text('Manage service categories'),
              subtitle: const Text('Choose what kind of work you can do'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.selectCategories),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.work_outline, color: AppColors.primary),
              title: const Text('View available works'),
              subtitle: const Text('See jobs posted near you'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.availableWorks),
            ),
          ),
        ],
      ),
    );
  }
}
