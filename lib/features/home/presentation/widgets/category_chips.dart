import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../catalog/domain/entities/category.dart';

class CategoryChips extends StatelessWidget {
  const CategoryChips(
      {super.key, required this.categories, required this.onTap});

  final List<Category> categories;
  final ValueChanged<Category> onTap;

  static const _icons = [
    Icons.checkroom_outlined,
    Icons.dry_cleaning_outlined,
    Icons.shopping_bag_outlined,
    Icons.watch_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Text('New collections are on their way.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted));
    }
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final category = categories[index];
          return SizedBox(
            width: 80,
            child: InkWell(
              onTap: () => onTap(category),
              borderRadius: BorderRadius.circular(8),
              child: Column(children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child:
                      Icon(_icons[index % _icons.length], color: AppColors.ink),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySm),
              ]),
            ),
          );
        },
      ),
    );
  }
}
