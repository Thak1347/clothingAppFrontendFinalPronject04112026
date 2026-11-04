import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../catalog/domain/entities/product.dart';

class NewArrivalsSection extends StatelessWidget {
  const NewArrivalsSection({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onViewAll,
  });

  final List<Product> products;
  final ValueChanged<Product> onProductTap;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('New arrivals', style: AppTextStyles.headlineSm),
            TextButton(onPressed: onViewAll, child: const Text('View all')),
          ]),
          if (products.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Fresh pieces are coming soon.',
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted)),
            )
          else
            SizedBox(
              height: 330,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (_, index) => SizedBox(
                  width: 190,
                  child: ProductCard(
                    product: products[index],
                    onTap: () => onProductTap(products[index]),
                  ),
                ),
              ),
            ),
        ],
      );
}
