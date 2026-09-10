import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/category_model.dart';
import 'service_illustration.dart';

class ServiceCategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;
  final bool selected;
  const ServiceCategoryTile(
      {super.key,
      required this.category,
      required this.onTap,
      this.selected = false});

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: Material(
          color: selected ? AppColors.primaryLight : Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color: selected ? AppColors.primary : AppColors.border)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(children: [
              Center(
                  child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Flexible(
                            child: ServiceIllustration(
                                category: category.name, size: 70)),
                        const SizedBox(height: 8),
                        Text(category.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                height: 1.3)),
                      ]))),
              if (selected)
                const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(Icons.check_circle_rounded,
                        size: 18, color: AppColors.primary)),
            ]),
          ),
        ),
      );
}

class MarketplaceHeader extends StatelessWidget {
  final String name;
  final VoidCallback? onAccount;
  const MarketplaceHeader({super.key, required this.name, this.onAccount});

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 18
            ? 'Good afternoon'
            : 'Good evening';
    return Row(children: [
      Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(15)),
          child: const ServiceIllustration(size: 44)),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(greeting, style: Theme.of(context).textTheme.bodySmall),
        Text(name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium),
      ])),
      if (onAccount != null)
        IconButton(
          onPressed: onAccount,
          tooltip: 'Account',
          style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13))),
          icon: const Icon(Icons.person_rounded,
              color: AppColors.primary, size: 22),
        ),
    ]);
  }
}

class ServiceHero extends StatelessWidget {
  final bool worker;
  final VoidCallback onTap;
  const ServiceHero({super.key, required this.onTap, this.worker = false});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ColoredBox(
            color: AppColors.primary,
            child: Stack(children: [
              Positioned(
                  right: -55,
                  top: -50,
                  child: Container(
                      width: 240,
                      height: 240,
                      decoration: const BoxDecoration(
                          color: Color(0xFF3973F0), shape: BoxShape.circle))),
              Positioned(
                  right: -30,
                  bottom: -80,
                  child: Container(
                      width: 210,
                      height: 210,
                      decoration: const BoxDecoration(
                          color: Color(0xFF4B80F2), shape: BoxShape.circle))),
              Padding(
                  padding: const EdgeInsets.fromLTRB(22, 23, 14, 20),
                  child: Row(children: [
                    Expanded(
                        flex: 6,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  worker
                                      ? 'MADE FOR YOUR SKILLS'
                                      : 'A LITTLE HELP. A BETTER HOME.',
                                  style: const TextStyle(
                                      fontSize: 8,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1)),
                              const SizedBox(height: 10),
                              Text(
                                  worker
                                      ? 'Good work.\nClose to home.'
                                      : 'Expert hands.\nLess hassle.',
                                  style: const TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.w800,
                                      height: 1.16,
                                      letterSpacing: -.8,
                                      color: Colors.white)),
                              const SizedBox(height: 15),
                              TextButton(
                                  onPressed: onTap,
                                  style: TextButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primaryDark,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 11),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12))),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                            child: Text(
                                                worker
                                                    ? 'Find work'
                                                    : 'Find a service',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 11))),
                                        const SizedBox(width: 9),
                                        const Icon(Icons.arrow_forward_rounded,
                                            size: 16)
                                      ])),
                            ])),
                    const Expanded(
                        flex: 4,
                        child: FittedBox(
                            child: ServiceIllustration(
                                size: 145, fullBody: true))),
                  ])),
            ])),
      );
}

class SectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  const SectionHeading(
      {super.key, required this.title, this.subtitle, this.onSeeAll});

  @override
  Widget build(BuildContext context) => Row(children: [
        Container(
            width: 4,
            height: 29,
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 10),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (subtitle != null)
            Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        ])),
        if (onSeeAll != null)
          TextButton(
              onPressed: onSeeAll,
              child: const Text('See all →',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
      ]);
}

class RetryPanel extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const RetryPanel({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(children: [
        const Icon(Icons.cloud_off_outlined,
            color: AppColors.textSecondary, size: 30),
        const SizedBox(height: 10),
        Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textSecondary)),
        TextButton(onPressed: onRetry, child: const Text('Try again')),
      ]));
}
