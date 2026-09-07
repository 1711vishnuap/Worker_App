// lib/screens/customer/customer_home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/work_provider.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/work_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../models/work_model.dart';
import 'my_works_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkProvider>().loadMyWorks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [const _HomeTab(), const MyWorksScreen(embedded: true)];

    return Scaffold(
      body: SafeArea(child: pages[_tabIndex]),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.selectCategory),
              icon: const Icon(Icons.add),
              label: const Text('New Work'),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: 'My Works'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab();

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final workProvider = context.watch<WorkProvider>();

    final activeWorks = workProvider.myWorks
        .where((w) => w.status != WorkStatus.completed && w.status != WorkStatus.cancelled)
        .toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Hi there 👋', style: TextStyle(color: AppColors.textSecondary)),
                    Text(
                      user?.name?.isNotEmpty == true ? user!.name! : 'Welcome',
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
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Need something done?', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    const Text(
                      'Post a work request and get matched with a nearby worker.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Post a Work',
                      icon: Icons.add_circle_outline,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.selectCategory),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text('Active Works', style: Theme.of(context).textTheme.titleMedium),
          ),
        ),
        if (workProvider.isLoading)
          const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(24), child: LoadingIndicator()))
        else if (activeWorks.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyState(icon: Icons.inbox_outlined, message: 'No active work requests yet'),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WorkCard(
                    work: activeWorks[index],
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.workTracking,
                      arguments: activeWorks[index].id,
                    ),
                  ),
                ),
                childCount: activeWorks.length,
              ),
            ),
          ),
      ],
    );
  }
}
