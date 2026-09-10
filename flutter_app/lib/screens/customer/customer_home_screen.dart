import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../models/category_model.dart';
import '../../models/work_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/work_provider.dart';
import '../../widgets/marketplace_widgets.dart';
import '../../widgets/work_card.dart';
import '../common/account_screen.dart';
import 'my_works_screen.dart';
import 'select_category_screen.dart';

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
      if (mounted) _refresh();
    });
  }

  Future<void> _refresh() async {
    final provider = context.read<WorkProvider>();
    await Future.wait([provider.loadMyWorks(), provider.loadCategories()]);
  }

  Future<void> _openCategory(CategoryModel category) async {
    await Navigator.pushNamed(context, AppRoutes.addWork, arguments: category);
    if (mounted) await context.read<WorkProvider>().loadMyWorks();
  }

  Future<void> _openWork(WorkModel work) async {
    await Navigator.pushNamed(context, AppRoutes.workTracking,
        arguments: work.id);
    if (mounted) await context.read<WorkProvider>().loadMyWorks();
  }

  void _openAccount() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const AccountScreen()));
  }

  @override
  Widget build(BuildContext context) {
    // Only 3 tab pages — Post is an action, not a page
    final pages = [
      _HomeTab(
          onServices: () => setState(() => _tabIndex = 1),
          onAccount: _openAccount,
          onCategory: _openCategory,
          onWork: _openWork,
          onRefresh: _refresh),
      SelectCategoryScreen(embedded: true, onSelect: _openCategory),
      const MyWorksScreen(embedded: true),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_tabIndex]),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.border))),
        child: NavigationBar(
            selectedIndex: _tabIndex,
            onDestinationSelected: (i) {
              setState(() => _tabIndex = i);
              if (i == 2) context.read<WorkProvider>().loadMyWorks();
            },
            destinations: const [
              NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: 'Home'),
              NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded),
                  label: 'Services'),
              NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long_rounded),
                  label: 'My bookings'),
            ]),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final VoidCallback onServices;
  final VoidCallback onAccount;
  final ValueChanged<CategoryModel> onCategory;
  final ValueChanged<WorkModel> onWork;
  final Future<void> Function() onRefresh;
  const _HomeTab(
      {required this.onServices,
      required this.onAccount,
      required this.onCategory,
      required this.onWork,
      required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<WorkProvider>();
    final activeWorks = provider.myWorks
        .where((w) =>
            w.status != WorkStatus.completed &&
            w.status != WorkStatus.cancelled)
        .toList();
    return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          children: [
            MarketplaceHeader(
                name: user?.name?.isNotEmpty == true
                    ? user!.name!
                    : 'Welcome home',
                onAccount: onAccount),
            const SizedBox(height: 24),
            ServiceHero(onTap: onServices),
            const SizedBox(height: 28),
            const SectionHeading(
                title: 'Services for your home',
                subtitle: 'Choose the help you need'),
            const SizedBox(height: 16),
            if (provider.categoriesLoading && provider.categories.isEmpty)
              const Padding(
                  padding: EdgeInsets.all(28),
                  child: Center(child: CircularProgressIndicator()))
            else if (provider.categoriesError != null &&
                provider.categories.isEmpty)
              RetryPanel(
                  message: "We couldn't load services.",
                  onRetry: provider.loadCategories)
            else if (provider.categories.isEmpty)
              const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('Services will appear here when available.'))
            else
              SizedBox(
                  height: 132,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: provider.categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => SizedBox(
                        width: 100,
                        child: ServiceCategoryTile(
                            category: provider.categories[i],
                            onTap: () => onCategory(provider.categories[i]))),
                  )),
            const SizedBox(height: 28),
            SectionHeading(
                title: 'Your active bookings',
                subtitle: activeWorks.length > 3
                    ? 'Showing 3 of ${activeWorks.length} active bookings'
                    : null),
            const SizedBox(height: 16),
            if (provider.isLoading && provider.myWorks.isEmpty)
              const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()))
            else if (provider.errorMessage != null)
              RetryPanel(
                  message: "We couldn't refresh your bookings.",
                  onRetry: provider.loadMyWorks)
            else if (activeWorks.isEmpty)
              Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(20)),
                  child: const Row(children: [
                    Icon(Icons.home_repair_service_outlined,
                        color: AppColors.primary, size: 30),
                    SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text('No active bookings',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 13)),
                          SizedBox(height: 4),
                          Text('Your next booking will appear here.',
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11)),
                        ])),
                  ]))
            else
              ...activeWorks.take(3).map((work) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: WorkCard(work: work, onTap: () => onWork(work)))),
          ],
        ));
  }
}
