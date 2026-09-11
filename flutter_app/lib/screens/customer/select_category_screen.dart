import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_colors.dart';
import '../../config/app_routes.dart';
import '../../models/category_model.dart';
import '../../providers/work_provider.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/marketplace_widgets.dart';

class SelectCategoryScreen extends StatefulWidget {
  final bool embedded;
  final ValueChanged<CategoryModel>? onSelect;
  const SelectCategoryScreen({super.key, this.embedded = false, this.onSelect});
  @override
  State<SelectCategoryScreen> createState() => _SelectCategoryScreenState();
}

class _SelectCategoryScreenState extends State<SelectCategoryScreen> {
  String _query = '';
  final _search = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<WorkProvider>().loadCategories();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkProvider>();
    final categories = provider.categories
        .where(
            (c) => c.name.toLowerCase().contains(_query.trim().toLowerCase()))
        .toList();
    final body = RefreshIndicator(
        onRefresh: provider.loadCategories,
        child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
                  sliver: SliverToBoxAdapter(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        const Text('What needs a little care?',
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.7)),
                        const SizedBox(height: 6),
                        const Text('Find the right help for your home.',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
                        const SizedBox(height: 22),
                        TextField(
                            controller: _search,
                            onChanged: (value) =>
                                setState(() => _query = value),
                            decoration: InputDecoration(
                              hintText: 'Search services',
                              hintStyle: const TextStyle(fontSize: 13),
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _query.isEmpty
                                  ? null
                                  : IconButton(
                                      tooltip: 'Clear search',
                                      onPressed: () {
                                        _search.clear();
                                        setState(() => _query = '');
                                      },
                                      icon: const Icon(Icons.close, size: 18)),
                            )),
                        const SizedBox(height: 24),
                        SectionHeading(
                            title: _query.isEmpty
                                ? 'All services'
                                : 'Search results',
                            subtitle:
                                '${categories.length} services to choose from'),
                      ]))),
              if (provider.categoriesLoading && provider.categories.isEmpty)
                const SliverFillRemaining(
                    hasScrollBody: false, child: LoadingIndicator())
              else if (provider.categoriesError != null &&
                  provider.categories.isEmpty)
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                        child: RetryPanel(
                            message:
                                'We couldn’t load services. Please try again.',
                            onRetry: provider.loadCategories)))
              else if (categories.isEmpty)
                SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                        icon: Icons.search_off_rounded,
                        message: _query.isEmpty
                            ? 'No services available yet'
                            : 'No services found. Try a different search.'))
              else
                SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                    sliver:
                        SliverLayoutBuilder(builder: (context, constraints) {
                      final columns = constraints.crossAxisExtent > 550
                          ? 4
                          : constraints.crossAxisExtent < 290
                              ? 2
                              : 3;
                      final textScale =
                          MediaQuery.textScalerOf(context).scale(12) / 12;
                      return SliverGrid.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 14,
                                  mainAxisExtent: 136 + (textScale - 1) * 32),
                          itemCount: categories.length,
                          itemBuilder: (_, i) => ServiceCategoryTile(
                              category: categories[i],
                              onTap: () {
                                if (widget.onSelect != null) {
                                  widget.onSelect!(categories[i]);
                                } else {
                                  Navigator.pushNamed(
                                      context, AppRoutes.addWork,
                                      arguments: categories[i]);
                                }
                              }));
                    })),
            ]));
    if (widget.embedded) {
      return Column(children: [
        const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text('Services',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
        Expanded(child: body),
      ]);
    }
    return Scaffold(
        appBar: AppBar(title: const Text('Services')),
        body: SafeArea(child: body));
  }
}
