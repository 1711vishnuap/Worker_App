// lib/screens/customer/my_works_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../models/work_model.dart';
import '../../providers/work_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/work_card.dart';

class MyWorksScreen extends StatefulWidget {
  final bool embedded; // true when shown inside CustomerHomeScreen's bottom nav
  const MyWorksScreen({super.key, this.embedded = false});

  @override
  State<MyWorksScreen> createState() => _MyWorksScreenState();
}

class _MyWorksScreenState extends State<MyWorksScreen> {
  @override
  void initState() {
    super.initState();
    if (!widget.embedded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<WorkProvider>().loadMyWorks();
      });
    }
  }

  void _openWork(WorkModel work) {
    final route = work.status == WorkStatus.completed ? AppRoutes.completedWork : AppRoutes.workTracking;
    Navigator.pushNamed(context, route, arguments: work.id);
  }

  @override
  Widget build(BuildContext context) {
    final works = context.watch<WorkProvider>().myWorks;
    final isLoading = context.watch<WorkProvider>().isLoading;

    final body = RefreshIndicator(
      onRefresh: () => context.read<WorkProvider>().loadMyWorks(),
      child: isLoading && works.isEmpty
          ? const LoadingIndicator()
          : works.isEmpty
              ? const EmptyState(icon: Icons.list_alt_outlined, message: 'You haven\'t posted any work yet')
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: works.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => WorkCard(work: works[index], onTap: () => _openWork(works[index])),
                ),
    );

    if (widget.embedded) {
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('My Works', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(appBar: AppBar(title: const Text('My Works')), body: body);
  }
}
