import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/asset_resolver.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/cart_item.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onDecrement,
    required this.onIncrement,
    required this.onRemove,
  });

  final CartItem item;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final imageSize = constraints.maxWidth < 360 ? 76.0 : 96.0;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: item.product.imageUrls.isEmpty
                      ? Image.asset(
                          AssetResolver.fallbackProductImage,
                          width: imageSize,
                          height: imageSize * 1.2,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          item.product.imageUrls.first,
                          width: imageSize,
                          height: imageSize * 1.2,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Image.asset(
                            AssetResolver.fallbackProductImage,
                            width: imageSize,
                            height: imageSize * 1.2,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: AppTextStyles.bodyLg.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.variant != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '${item.variant!.size} · ${item.variant!.color}',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        CurrencyFormatter.format(item.lineTotalMinor / 100),
                        style: AppTextStyles.priceMd,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: [
                          _QuantityControl(
                            quantity: item.quantity,
                            canDecrement: item.quantity > 1,
                            canIncrement: item.variant == null ||
                                item.quantity < item.variant!.stock,
                            onDecrement: onDecrement,
                            onIncrement: onIncrement,
                          ),
                          IconButton(
                            tooltip: 'Remove item',
                            onPressed: onRemove,
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );
}

class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.canDecrement,
    required this.canIncrement,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final bool canDecrement;
  final bool canIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Decrease quantity',
              onPressed: canDecrement ? onDecrement : null,
              icon: const Icon(Icons.remove, size: 18),
            ),
            Text('$quantity', style: AppTextStyles.labelMd),
            IconButton(
              tooltip: 'Increase quantity',
              onPressed: canIncrement ? onIncrement : null,
              icon: const Icon(Icons.add, size: 18),
            ),
          ],
        ),
      );
}
