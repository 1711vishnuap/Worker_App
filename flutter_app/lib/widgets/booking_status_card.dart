import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/work_model.dart';

class BookingStatusCard extends StatelessWidget {
  final WorkStatus status;
  const BookingStatusCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (title, message, icon) = switch (status) {
      WorkStatus.posted => (
          'Your request is in.',
          'Your request is posted. A professional has not been matched yet.',
          Icons.task_alt_rounded
        ),
      WorkStatus.notified => (
          'Finding your\nhelping hand.',
          'Nearby professionals have been notified. Their response will appear here.',
          Icons.person_search_outlined
        ),
      WorkStatus.accepted => (
          'You’re in good hands.',
          'A professional has accepted your request. You can now view their location.',
          Icons.handshake_outlined
        ),
      WorkStatus.workerOnTheWay => (
          'Help is on the way.',
          'Your professional is heading to you. Follow their location below.',
          Icons.near_me_outlined
        ),
      WorkStatus.arrived => (
          'Your professional\nis here.',
          'Share your start code when you meet to confirm the work can begin.',
          Icons.location_on_outlined
        ),
      WorkStatus.started => (
          'A little less\non your to-do list.',
          'Your service is in progress. Its completion will appear here.',
          Icons.home_repair_service_outlined
        ),
      WorkStatus.completed => (
          'All taken care of.',
          'Your professional has marked this service as completed.',
          Icons.check_circle_outline_rounded
        ),
      WorkStatus.cancelled => (
          'Booking cancelled.',
          'This request is closed. You can book a new service whenever you need a hand.',
          Icons.event_busy_outlined
        ),
    };
    final cancelled = status == WorkStatus.cancelled;
    final accent = cancelled ? AppColors.textSecondary : AppColors.primary;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
          color: cancelled ? const Color(0xFFF0F2F6) : AppColors.primaryLight,
          borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(workStatusLabel(status).toUpperCase(),
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: accent))),
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(13)),
              child: Icon(icon, size: 22, color: accent)),
        ]),
        const SizedBox(height: 14),
        Text(title,
            style: const TextStyle(
                fontSize: 27,
                height: 1.15,
                fontWeight: FontWeight.w800,
                letterSpacing: -.9,
                color: AppColors.textPrimary)),
        const SizedBox(height: 10),
        Text(message,
            style: const TextStyle(
                fontSize: 12, height: 1.65, color: Color(0xFF526582))),
      ]),
    );
  }
}

/// Travel updates remain in the status card; these are the four main milestones.
class BookingProgress extends StatelessWidget {
  final WorkStatus status;
  const BookingProgress({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == WorkStatus.cancelled) return const SizedBox.shrink();
    final current = switch (status) {
      WorkStatus.posted || WorkStatus.notified => 0,
      WorkStatus.accepted ||
      WorkStatus.workerOnTheWay ||
      WorkStatus.arrived =>
        1,
      WorkStatus.started => 2,
      WorkStatus.completed => 3,
      WorkStatus.cancelled => -1,
    };
    const labels = ['Requested', 'Matched', 'In progress', 'Completed'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Booking progress',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
      const SizedBox(height: 18),
      Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(labels.length, (i) {
            final reached = i <= current;
            return Expanded(
                child: Semantics(
                    label: '${labels[i]}: ${reached ? 'reached' : 'upcoming'}',
                    child: ExcludeSemantics(
                        child: Column(children: [
                      Row(children: [
                        Expanded(
                            child: Container(
                                height: 2,
                                color: i == 0
                                    ? Colors.transparent
                                    : reached
                                        ? AppColors.primary
                                        : AppColors.border)),
                        Container(
                            width: 27,
                            height: 27,
                            decoration: BoxDecoration(
                                color:
                                    reached ? AppColors.primary : Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: reached
                                        ? AppColors.primary
                                        : AppColors.border,
                                    width: 2)),
                            child: reached
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 16)
                                : Center(
                                    child: Text('${i + 1}',
                                        style: const TextStyle(
                                            fontSize: 10,
                                            color: AppColors.textSecondary,
                                            fontWeight: FontWeight.w700)))),
                        Expanded(
                            child: Container(
                                height: 2,
                                color: i == labels.length - 1
                                    ? Colors.transparent
                                    : i < current
                                        ? AppColors.primary
                                        : AppColors.border)),
                      ]),
                      const SizedBox(height: 9),
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Text(labels[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 10,
                                  height: 1.4,
                                  color: reached
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontWeight: reached
                                      ? FontWeight.w800
                                      : FontWeight.w500))),
                    ]))));
          })),
    ]);
  }
}
