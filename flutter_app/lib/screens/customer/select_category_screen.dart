// lib/screens/customer/select_category_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../providers/work_provider.dart';
import '../../widgets/loading_indicator.dart';

const _categoryIcons = {
  'Electrician': Icons.electrical_services,
  'Plumber': Icons.plumbing,
  'Carpenter': Icons.carpenter,
  'Cleaning': Icons.cleaning_services,
  'AC Repair': Icons.ac_unit,
};

class SelectCategoryScreen extends StatefulWidget {
  const SelectCategoryScreen({super.key});

  @override
  State<SelectCategoryScreen> createState() => _SelectCategoryScreenState();
}

class _SelectCategoryScreenState extends State<SelectCategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkProvider>().loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final workProvider = context.watch<WorkProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Select a Category')),
      body: workProvider.categories.isEmpty
          ? const LoadingIndicator()
          : GridView.builder(
              padding: const EdgeInsets.all(20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: workProvider.categories.length,
              itemBuilder: (context, index) {
                final category = workProvider.categories[index];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.addWork,
                    arguments: category,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _categoryIcons[category.name] ?? Icons.build_outlined,
                          size: 40,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          category.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
