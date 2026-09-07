// lib/screens/worker/work_history_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/work_card.dart';

class WorkHistoryScreen extends StatefulWidget {
  final bool embedded;
  const WorkHistoryScreen({super.key, this.embedded = false});

  @override
  State<WorkHistoryScreen> createState() => _WorkHistoryScreenState();
}

class _WorkHistoryScreenState extends State<WorkHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = context.watch<WorkerProvider>().history;
    final isLoading = context.watch<WorkerProvider>().isLoading;

    final body = RefreshIndicator(
      onRefresh: () => context.read<WorkerProvider>().loadHistory(),
      child: isLoading && history.isEmpty
          ? const LoadingIndicator()
          : history.isEmpty
              ? const EmptyState(icon: Icons.history, message: 'No completed works yet')
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => WorkCard(work: history[index], onTap: () {}),
                ),
    );

    if (widget.embedded) {
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Work History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(appBar: AppBar(title: const Text('Work History')), body: body);
  }
}
