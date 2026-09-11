import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../providers/work_provider.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/marketplace_widgets.dart';
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
      if (mounted) context.read<WorkProvider>().loadCategories();
    });
  }

  Future<void> _save() async {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one service')));
      return;
    }
    final success =
        await context.read<WorkerProvider>().setCategories(_selected.toList());
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Services saved')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.read<WorkerProvider>().errorMessage ??
              'Failed to save')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkProvider>();
    final isSaving = context.watch<WorkerProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(title: const Text('My services')),
      body: SafeArea(
          child: Column(children: [
        const Padding(
            padding: EdgeInsets.fromLTRB(22, 12, 22, 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Put your skills to work.',
                  style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.7)),
              SizedBox(height: 8),
              Text(
                  'Select all the services you want to offer. We’ll match you with nearby requests.',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ])),
        Expanded(
            child: provider.categoriesLoading && provider.categories.isEmpty
                ? const LoadingIndicator()
                : provider.categoriesError != null &&
                        provider.categories.isEmpty
                    ? Center(
                        child: RetryPanel(
                            message: 'We couldn’t load services.',
                            onRetry: provider.loadCategories))
                    : provider.categories.isEmpty
                        ? const EmptyState(
                            icon: Icons.grid_view_rounded,
                            message: 'No services available yet')
                        : LayoutBuilder(
                            builder: (context, constraints) => GridView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount:
                                              constraints.maxWidth < 360
                                                  ? 2
                                                  : 3,
                                          crossAxisSpacing: 12,
                                          mainAxisSpacing: 14,
                                          mainAxisExtent: 145 +
                                              (MediaQuery.textScalerOf(context)
                                                          .scale(12) -
                                                      12) *
                                                  2),
                                  itemCount: provider.categories.length,
                                  itemBuilder: (_, i) {
                                    final category = provider.categories[i];
                                    final selected =
                                        _selected.contains(category.id);
                                    return ServiceCategoryTile(
                                        category: category,
                                        selected: selected,
                                        onTap: () {
                                          if (!isSaving) {
                                            setState(() {
                                              selected
                                                  ? _selected
                                                      .remove(category.id)
                                                  : _selected.add(category.id);
                                            });
                                          }
                                        });
                                  },
                                ))),
        Padding(
            padding: const EdgeInsets.all(22),
            child: PrimaryButton(
                label: _selected.isEmpty
                    ? 'Save services'
                    : 'Save ${_selected.length} services',
                isLoading: isSaving,
                onPressed: _save)),
      ])),
    );
  }
}
