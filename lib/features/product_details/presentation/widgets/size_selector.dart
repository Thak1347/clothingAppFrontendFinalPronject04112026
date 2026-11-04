import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class SizeSelector extends StatelessWidget {
  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selected,
    required this.isAvailable,
    required this.onSelected,
  });

  final List<String> sizes;
  final String? selected;
  final bool Function(String) isAvailable;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: sizes.map((size) {
        final available = isAvailable(size);
        final chosen = selected == size;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: available ? () => onSelected(size) : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: Ink(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: chosen ? AppColors.ink : Colors.transparent,
                border: Border.all(
                  color: chosen ? AppColors.ink : AppColors.border,
                ),
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusMd,
                ),
              ),
              child: Text(
                size,
                style: AppTextStyles.labelMd.copyWith(
                  color: chosen
                      ? AppColors.onInk
                      : available
                          ? AppColors.ink
                          : AppColors.border,
                  decoration: available ? null : TextDecoration.lineThrough,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
