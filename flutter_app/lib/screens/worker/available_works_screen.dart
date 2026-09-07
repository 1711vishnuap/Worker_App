// lib/screens/worker/available_works_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_routes.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/work_card.dart';

class AvailableWorksScreen extends StatefulWidget {
  final bool embedded;
  const AvailableWorksScreen({super.key, this.embedded = false});

  @override
  State<AvailableWorksScreen> createState() => _AvailableWorksScreenState();
}

class _AvailableWorksScreenState extends State<AvailableWorksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().loadAvailableWorks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final works = context.watch<WorkerProvider>().availableWorks;
    final isLoading = context.watch<WorkerProvider>().isLoading;

    final body = RefreshIndicator(
      onRefresh: () => context.read<WorkerProvider>().loadAvailableWorks(),
      child: isLoading && works.isEmpty
          ? const LoadingIndicator()
          : works.isEmpty
              ? const EmptyState(icon: Icons.search_off, message: 'No work available near you right now')
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: works.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => WorkCard(
                    work: works[index],
                    onTap: () => Navigator.pushNamed(context, AppRoutes.workerWorkDetails, arguments: works[index].id),
                  ),
                ),
    );

    if (widget.embedded) {
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Available Works', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(appBar: AppBar(title: const Text('Available Works')), body: body);
  }
}
