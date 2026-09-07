// lib/screens/worker/work_completed_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/primary_button.dart';

class WorkCompletedScreen extends StatefulWidget {
  const WorkCompletedScreen({super.key});

  @override
  State<WorkCompletedScreen> createState() => _WorkCompletedScreenState();
}

class _WorkCompletedScreenState extends State<WorkCompletedScreen> {
  bool _completing = false;
  bool _done = false;

  Future<void> _markComplete(int workId) async {
    setState(() => _completing = true);
    final success = await context.read<WorkerProvider>().completeWork(workId);
    if (!mounted) return;
    setState(() {
      _completing = false;
      _done = success;
    });
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(context.read<WorkerProvider>().errorMessage ??
                'Failed to complete work')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final workId = ModalRoute.of(context)!.settings.arguments as int;
    final work = context.watch<WorkerProvider>().acceptedWork;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Finish Work'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _done ? Icons.check_circle : Icons.build_circle_outlined,
                size: 72,
                color: _done ? AppColors.statusCompleted : AppColors.primary,
              ),
              const SizedBox(height: 20),
              Text(
                _done
                    ? 'Work marked as completed!'
                    : 'OTP verified — work started',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (work != null)
                Text(work.title,
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center),
              const SizedBox(height: 32),
              if (!_done)
                PrimaryButton(
                  label: 'Mark Work as Completed',
                  isLoading: _completing,
                  onPressed: () => _markComplete(workId),
                )
              else
                PrimaryButton(
                  label: 'Back to Home',
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
