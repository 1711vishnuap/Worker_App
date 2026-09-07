// lib/screens/worker/work_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';

class WorkerWorkDetailsScreen extends StatefulWidget {
  const WorkerWorkDetailsScreen({super.key});

  @override
  State<WorkerWorkDetailsScreen> createState() => _WorkerWorkDetailsScreenState();
}

class _WorkerWorkDetailsScreenState extends State<WorkerWorkDetailsScreen> {
  bool _accepting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final workId = ModalRoute.of(context)!.settings.arguments as int;
    context.read<WorkerProvider>().loadWorkById(workId);
  }

  Future<void> _accept(int workId) async {
    setState(() => _accepting = true);
    final success = await context.read<WorkerProvider>().acceptWork(workId);
    if (!mounted) return;
    setState(() => _accepting = false);

    if (success) {
      Navigator.pushReplacementNamed(context, AppRoutes.acceptedWork, arguments: workId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<WorkerProvider>().errorMessage ?? 'This work is no longer available')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final work = context.watch<WorkerProvider>().acceptedWork;

    return Scaffold(
      appBar: AppBar(title: const Text('Work Details')),
      body: work == null
          ? const LoadingIndicator()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(work.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                                StatusBadge(status: work.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (work.categoryName != null)
                              Text(work.categoryName!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                            if (work.distanceKm != null) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text('${work.distanceKm} km away', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                            const SizedBox(height: 20),
                            if (work.description != null && work.description!.isNotEmpty) ...[
                              const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Text(work.description!, style: const TextStyle(color: AppColors.textSecondary)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    PrimaryButton(
                      label: 'Accept This Work',
                      isLoading: _accepting,
                      onPressed: () => _accept(work.id),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
