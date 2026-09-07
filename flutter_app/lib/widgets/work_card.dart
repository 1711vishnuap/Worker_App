// lib/widgets/work_card.dart

import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/work_model.dart';
import 'status_badge.dart';

class WorkCard extends StatelessWidget {
  final WorkModel work;
  final VoidCallback onTap;

  const WorkCard({super.key, required this.work, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      work.title,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(status: work.status),
                ],
              ),
              const SizedBox(height: 6),
              if (work.categoryName != null)
                Text(
                  work.categoryName!,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
              if (work.distanceKm != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${work.distanceKm} km away',
                      style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
