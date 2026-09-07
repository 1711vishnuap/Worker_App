// lib/screens/customer/completed_work_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/work_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/primary_button.dart';

class CompletedWorkScreen extends StatefulWidget {
  const CompletedWorkScreen({super.key});

  @override
  State<CompletedWorkScreen> createState() => _CompletedWorkScreenState();
}

class _CompletedWorkScreenState extends State<CompletedWorkScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final workId = ModalRoute.of(context)!.settings.arguments as int;
    context.read<WorkProvider>().loadWorkById(workId);
  }

  @override
  Widget build(BuildContext context) {
    final work = context.watch<WorkProvider>().currentWork;

    return Scaffold(
      appBar: AppBar(title: const Text('Work Completed')),
      body: work == null
          ? const LoadingIndicator()
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle, size: 72, color: AppColors.statusCompleted),
                    const SizedBox(height: 20),
                    const Text('All done!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      work.title,
                      style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    if (work.categoryName != null)
                      Text(work.categoryName!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 32),
                    PrimaryButton(label: 'Back to Home', onPressed: () => Navigator.popUntil(context, (r) => r.isFirst)),
                  ],
                ),
              ),
            ),
    );
  }
}
