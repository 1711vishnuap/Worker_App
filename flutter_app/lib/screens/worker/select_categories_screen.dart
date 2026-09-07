// lib/screens/worker/select_categories_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/work_provider.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/primary_button.dart';

class SelectCategoriesScreen extends StatefulWidget {
  const SelectCategoriesScreen({super.key});

  @override
  State<SelectCategoriesScreen> createState() => _SelectCategoriesScreenState();
}

class _SelectCategoriesScreenState extends State<SelectCategoriesScreen> {
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkProvider>().loadCategories();
    });
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
      );
      return;
    }
    final success = await context.read<WorkerProvider>().setCategories(_selected.toList());
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Categories saved')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.read<WorkerProvider>().errorMessage ?? 'Failed to save')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<WorkProvider>().categories;
    final isLoading = context.watch<WorkerProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Services')),
      body: categories.isEmpty
          ? const LoadingIndicator()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final CategoryModel category = categories[index];
                      final selected = _selected.contains(category.id);
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => setState(() {
                          selected ? _selected.remove(category.id) : _selected.add(category.id);
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.surface,
                            border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: 1.5),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                selected ? Icons.check_circle : Icons.circle_outlined,
                                color: selected ? AppColors.primary : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 14),
                              Text(category.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: PrimaryButton(label: 'Save', isLoading: isLoading, onPressed: _save),
                ),
              ],
            ),
    );
  }
}
