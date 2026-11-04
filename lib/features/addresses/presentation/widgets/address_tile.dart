import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/address.dart';

class AddressTile extends StatelessWidget {
  const AddressTile(
      {super.key,
      required this.address,
      required this.onEdit,
      required this.onDelete,
      required this.onMakeDefault});
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMakeDefault;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
              color: address.isDefault ? AppColors.ink : AppColors.border,
              width: address.isDefault ? 1.3 : 1),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
              child: Icon(_iconFor(address.label), color: AppColors.inkMuted),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Row(children: [
                    Expanded(
                        child: Text(
                            address.label?.trim().isNotEmpty == true
                                ? address.label!.trim()
                                : 'Delivery address',
                            style: AppTextStyles.labelLg)),
                    if (address.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                        decoration: BoxDecoration(
                            color: AppColors.canvas,
                            borderRadius: BorderRadius.circular(30)),
                        child: Text('DEFAULT', style: AppTextStyles.labelSm),
                      ),
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                  Text(address.recipientName, style: AppTextStyles.bodyMd),
                  const SizedBox(height: AppSpacing.xs),
                  Text(address.phone,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.inkMuted)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${address.addressLine}, ${address.province}',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.inkMuted)),
                ])),
          ]),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit')),
              TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete')),
              if (!address.isDefault)
                TextButton.icon(
                    onPressed: onMakeDefault,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text('Set as default')),
            ],
          ),
        ]),
      );

  IconData _iconFor(String? label) {
    switch (label?.toLowerCase().trim()) {
      case 'home':
        return Icons.home_outlined;
      case 'work':
      case 'office':
        return Icons.work_outline;
      default:
        return Icons.location_on_outlined;
    }
  }
}
