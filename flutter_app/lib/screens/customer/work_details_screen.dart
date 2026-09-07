// lib/screens/customer/work_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/work_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/status_badge.dart';

class WorkDetailsScreen extends StatefulWidget {
  const WorkDetailsScreen({super.key});

  @override
  State<WorkDetailsScreen> createState() => _WorkDetailsScreenState();
}

class _WorkDetailsScreenState extends State<WorkDetailsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final workId = ModalRoute.of(context)!.settings.arguments as int;
    context.read<WorkProvider>().loadWorkById(workId);
  }

  @override
  Widget build(BuildContext context) {
    final workProvider = context.watch<WorkProvider>();
    final work = workProvider.currentWork;

    return Scaffold(
      appBar: AppBar(title: const Text('Work Details')),
      body: work == null
          ? const LoadingIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(work.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ),
                      StatusBadge(status: work.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (work.categoryName != null)
                    Text(work.categoryName!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 20),
                  if (work.description != null && work.description!.isNotEmpty) ...[
                    const Text('Description', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(work.description!, style: const TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 20),
                  ],
                  const Text('Posted on', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(work.createdAt, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 28),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.workTracking, arguments: work.id),
                    child: const Text('View Tracking'),
                  ),
                ],
              ),
            ),
    );
  }
}
