import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final normalized = status.isEmpty ? 'unknown' : status.toLowerCase();
    final label = normalized
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
    final color = switch (normalized) {
      'paid' ||
      'partially_paid' ||
      'delivered' ||
      'completed' =>
        AppColors.success,
      'failed' || 'expired' || 'cancelled' || 'rejected' => AppColors.error,
      'processing' || 'shipped' => AppColors.ink,
      _ => AppColors.warning,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMd.copyWith(color: color),
      ),
    );
  }
}
