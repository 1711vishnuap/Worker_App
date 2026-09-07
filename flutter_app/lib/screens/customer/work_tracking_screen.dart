// lib/screens/customer/work_tracking_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../models/work_model.dart';
import '../../providers/work_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_badge.dart';

const _statusSteps = [
  WorkStatus.posted,
  WorkStatus.notified,
  WorkStatus.accepted,
  WorkStatus.workerOnTheWay,
  WorkStatus.arrived,
  WorkStatus.started,
  WorkStatus.completed,
];

class WorkTrackingScreen extends StatefulWidget {
  const WorkTrackingScreen({super.key});

  @override
  State<WorkTrackingScreen> createState() => _WorkTrackingScreenState();
}

class _WorkTrackingScreenState extends State<WorkTrackingScreen> {
  late int _workId;
  Timer? _pollTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _workId = ModalRoute.of(context)!.settings.arguments as int;
    context.read<WorkProvider>().loadWorkById(_workId);
    _pollTimer ??= Timer.periodic(const Duration(seconds: 8), (_) {
      context.read<WorkProvider>().loadWorkById(_workId);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final work = context.watch<WorkProvider>().currentWork;

    return Scaffold(
      appBar: AppBar(title: const Text('Track Work')),
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
                      Expanded(child: Text(work.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                      StatusBadge(status: work.status),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _timeline(work.status),
                  const SizedBox(height: 28),

                  if (work.status == WorkStatus.accepted ||
                      work.status == WorkStatus.workerOnTheWay ||
                      work.status == WorkStatus.arrived) ...[
                    PrimaryButton(
                      label: 'View Worker Location',
                      icon: Icons.map_outlined,
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.workerMap, arguments: _workId),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.password_outlined),
                      label: const Text('Show OTP to Worker'),
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.showOtp, arguments: work),
                    ),
                  ],

                  if (work.status == WorkStatus.started) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.statusStarted.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.build_circle_outlined, color: AppColors.statusStarted),
                          SizedBox(width: 12),
                          Expanded(child: Text('Work is in progress. Sit back and relax!')),
                        ],
                      ),
                    ),
                  ],

                  if (work.status == WorkStatus.completed) ...[
                    PrimaryButton(
                      label: 'View Completed Work',
                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.completedWork, arguments: _workId),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _timeline(WorkStatus current) {
    final currentIndex = _statusSteps.indexOf(current == WorkStatus.cancelled ? WorkStatus.posted : current);

    return Column(
      children: List.generate(_statusSteps.length, (i) {
        final step = _statusSteps[i];
        final isDone = i <= currentIndex;
        final isLast = i == _statusSteps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? AppColors.primary : AppColors.border,
                    ),
                    child: isDone ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                  ),
                  if (!isLast) Expanded(child: Container(width: 2, color: isDone ? AppColors.primary : AppColors.border)),
                ],
              ),
              const SizedBox(width: 14),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  workStatusLabel(step),
                  style: TextStyle(
                    fontWeight: isDone ? FontWeight.w600 : FontWeight.normal,
                    color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
