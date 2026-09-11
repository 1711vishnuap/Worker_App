import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../models/work_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/worker_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/marketplace_widgets.dart';
import '../../widgets/work_card.dart';
import '../common/account_screen.dart';
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
  String? _locationMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _bootstrap();
    });
  }

  Future<void> _bootstrap() async {
    final provider = context.read<WorkerProvider>();
    await provider.ensureProfile();
    if (!mounted) return;
    provider.loadAvailableWorks();
    final result = await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() => _locationMessage = result.error);
    if (result.position != null) {
      await provider.updateLocation(
          result.position!.latitude, result.position!.longitude);
      if (!mounted) return;
      _locationSub = _locationService.watchLocation().listen((pos) {
        provider.updateLocation(pos.latitude, pos.longitude);
      }, onError: (Object error) {
        if (mounted) {
          setState(() => _locationMessage =
              'Location updates paused. Check your location permission.');
        }
      });
    }
  }

  @override
  void dispose() {
    _locationSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _WorkerHomeTab(
          onAvailable: () => setState(() => _tabIndex = 1),
          locationMessage: _locationMessage),
      const AvailableWorksScreen(embedded: true),
      const WorkHistoryScreen(embedded: true),
      const AccountScreen(),
    ];
    return Scaffold(
      body: SafeArea(child: pages[_tabIndex]),
      bottomNavigationBar: DecoratedBox(
          decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border))),
          child: NavigationBar(
              selectedIndex: _tabIndex,
              onDestinationSelected: (i) => setState(() => _tabIndex = i),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.work_outline_rounded),
                    selectedIcon: Icon(Icons.work_rounded),
                    label: 'Find work'),
                NavigationDestination(
                    icon: Icon(Icons.history_rounded), label: 'History'),
                NavigationDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: 'Account'),
              ])),
    );
  }
}

class _WorkerHomeTab extends StatelessWidget {
  final VoidCallback onAvailable;
  final String? locationMessage;
  const _WorkerHomeTab({required this.onAvailable, this.locationMessage});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<WorkerProvider>();
    final active = provider.acceptedWork;
    return RefreshIndicator(
        onRefresh: provider.loadAvailableWorks,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          children: [
            MarketplaceHeader(
                name: user?.name?.isNotEmpty == true
                    ? user!.name!
                    : 'Let’s get to work'),
            const SizedBox(height: 24),
            ServiceHero(worker: true, onTap: onAvailable),
            if (locationMessage != null) ...[
              const SizedBox(height: 18),
              Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(children: [
                    const Icon(Icons.location_off_outlined,
                        color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Text(locationMessage!,
                            style: const TextStyle(fontSize: 12)))
                  ])),
            ],
            const SizedBox(height: 26),
            if (active != null &&
                const {
                  WorkStatus.accepted,
                  WorkStatus.workerOnTheWay,
                  WorkStatus.arrived,
                  WorkStatus.started,
                }.contains(active.status)) ...[
              const SectionHeading(title: 'Your current job'),
              const SizedBox(height: 14),
              WorkCard(
                  work: active,
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.acceptedWork,
                      arguments: active.id)),
              const SizedBox(height: 26),
            ],
            SectionHeading(
                title: 'Work near you',
                subtitle: provider.availableWorks.length > 3
                    ? 'Showing 3 of ${provider.availableWorks.length} matching requests'
                    : 'Opportunities that match your skills'),
            const SizedBox(height: 16),
            if (provider.isLoading && provider.availableWorks.isEmpty)
              const Center(
                  child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator()))
            else if (provider.errorMessage != null)
              RetryPanel(
                  message: 'We couldn’t load nearby work.',
                  onRetry: provider.loadAvailableWorks)
            else if (provider.availableWorks.isEmpty)
              Card(
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Your next job starts with your skills',
                                style: TextStyle(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 8),
                            const Text(
                                'Choose the services you offer to receive matching requests nearby.',
                                style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12)),
                            const SizedBox(height: 12),
                            TextButton(
                                onPressed: () => Navigator.pushNamed(
                                    context, AppRoutes.selectCategories),
                                child: const Text('Choose my services →')),
                          ])))
            else
              ...provider.availableWorks.take(3).map((work) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WorkCard(
                      work: work,
                      onTap: () => Navigator.pushNamed(
                          context, AppRoutes.workerWorkDetails,
                          arguments: work.id)))),
          ],
        ));
  }
}
