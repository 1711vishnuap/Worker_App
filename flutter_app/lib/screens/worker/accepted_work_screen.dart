// lib/screens/worker/accepted_work_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';

class AcceptedWorkScreen extends StatefulWidget {
  const AcceptedWorkScreen({super.key});

  @override
  State<AcceptedWorkScreen> createState() => _AcceptedWorkScreenState();
}

class _AcceptedWorkScreenState extends State<AcceptedWorkScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final workId = ModalRoute.of(context)!.settings.arguments as int;
    context.read<WorkerProvider>().loadWorkById(workId);
  }

  @override
  Widget build(BuildContext context) {
    final work = context.watch<WorkerProvider>().acceptedWork;

    return Scaffold(
      appBar: AppBar(title: const Text('Accepted Work')),
      body: work == null
          ? const LoadingIndicator()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(work.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                        StatusBadge(status: work.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (work.categoryName != null)
                      Text(work.categoryName!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.textSecondary),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Navigate to the customer\'s location. Once you arrive, ask them for the OTP to start work.',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: 'Navigate to Customer',
                      icon: Icons.directions_outlined,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.navigationMap, arguments: work.id),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.password_outlined),
                      label: const Text('Enter Customer OTP'),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.workerEnterOtp, arguments: work.id),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
