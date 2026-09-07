// lib/widgets/status_badge.dart

import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/work_model.dart';

Color statusColor(WorkStatus status) {
  switch (status) {
    case WorkStatus.posted:
      return AppColors.statusPosted;
    case WorkStatus.notified:
      return AppColors.statusNotified;
    case WorkStatus.accepted:
      return AppColors.statusAccepted;
    case WorkStatus.workerOnTheWay:
      return AppColors.statusOnTheWay;
    case WorkStatus.arrived:
      return AppColors.statusArrived;
    case WorkStatus.started:
      return AppColors.statusStarted;
    case WorkStatus.completed:
      return AppColors.statusCompleted;
    case WorkStatus.cancelled:
      return AppColors.statusCancelled;
  }
}

class StatusBadge extends StatelessWidget {
  final WorkStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        workStatusLabel(status),
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}
