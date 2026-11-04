import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../../catalog/domain/entities/product.dart';
import '../controllers/product_details_controller.dart';
import '../widgets/color_selector.dart';
import '../widgets/product_image_gallery.dart';
import '../widgets/quantity_stepper.dart';
import '../widgets/size_selector.dart';

class ProductDetailsPage extends StatelessWidget {
  const ProductDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProductDetailsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ÉTOFFE Atelier'),
        actions: [
          IconButton(
            tooltip: 'Shopping bag',
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => Get.toNamed(AppRoutes.cart),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingView();
        if (controller.errorMessage.value.isNotEmpty) {
          return ErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.loadProduct,
          );
        }

        final product = controller.product;
        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 900) {
              return SafeArea(
                top: false,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.section,
                        vertical: AppSpacing.lg,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: SingleChildScrollView(
                              child: ProductImageGallery(product: product),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.section),
                          Expanded(
                            flex: 5,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.lg,
                              ),
                              child: _ProductInformation(
                                product: product,
                                controller: controller,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: ProductImageGallery(product: product),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.margin,
                    AppSpacing.lg,
                    AppSpacing.margin,
                    AppSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _ProductInformation(
                      product: product,
                      controller: controller,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value ||
            controller.errorMessage.value.isNotEmpty) {
          return const SizedBox.shrink();
        }
        return _PurchaseBar(
          priceMinor: controller.selectedPriceMinor,
          onAdd: () => _addToCart(controller),
        );
      }),
    );
  }

  void _addToCart(ProductDetailsController controller) {
    if (!controller.validateSelection()) return;
    Get.find<CartController>().addProduct(
      controller.product,
      variant: controller.selectedVariant.value,
      quantity: controller.quantity.value,
    );
    Get.snackbar(
      'Added to bag',
      controller.product.name,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

class _ProductInformation extends StatelessWidget {
  const _ProductInformation({required this.product, required this.controller});

  final Product product;
  final ProductDetailsController controller;

  @override
  Widget build(BuildContext context) => Obx(() {
        final selected = controller.selectedVariant.value;
        final available = controller.availableStock;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.categoryName != null) ...[
              Text(
                product.categoryName!.toUpperCase(),
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
            Text(
              product.name,
              style: AppTextStyles.displayMdMobile,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              CurrencyFormatter.format(controller.selectedPriceMinor / 100),
              style: AppTextStyles.priceLg,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              product.description.isEmpty
                  ? 'A considered piece for everyday wear.'
                  : product.description,
              style: AppTextStyles.bodyMd,
            ),
            if (controller.sizes.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.section),
              _sectionHeading('Select size'),
              const SizedBox(height: AppSpacing.md),
              SizeSelector(
                sizes: controller.sizes,
                selected: selected?.size,
                isAvailable: (size) => controller.isCombinationAvailable(
                  size: size,
                  color: selected?.color,
                ),
                onSelected: controller.selectSize,
              ),
            ],
            if (controller.colors.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.section),
              _sectionHeading('Select color'),
              const SizedBox(height: AppSpacing.md),
              ColorSelector(
                colors: controller.colors,
                selected: selected?.color,
                isAvailable: (color) => controller.isCombinationAvailable(
                  color: color,
                  size: selected?.size,
                ),
                onSelected: controller.selectColor,
              ),
            ],
            if (product.variants.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                selected == null
                    ? 'Select options to check availability'
                    : available > 0
                        ? '$available available'
                        : 'Out of stock',
                style: AppTextStyles.bodySm.copyWith(
                  color: selected != null && available == 0
                      ? AppColors.error
                      : AppColors.inkMuted,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.section),
            _sectionHeading('Quantity'),
            const SizedBox(height: AppSpacing.md),
            QuantityStepper(
              quantity: controller.quantity.value,
              onDecrement: controller.decrement,
              onIncrement: controller.increment,
              canIncrement: product.variants.isEmpty ||
                  (selected != null && controller.quantity.value < available),
            ),
            if (controller.validationMessage.value.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                controller.validationMessage.value,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
              ),
            ],
          ],
        );
      });

  Widget _sectionHeading(String title) => Text(
        title,
        style: AppTextStyles.labelLg,
      );
}

class _PurchaseBar extends StatelessWidget {
  const _PurchaseBar({required this.priceMinor, required this.onAdd});

  final int priceMinor;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceWhite,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.margin,
            AppSpacing.md,
            AppSpacing.margin,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      CurrencyFormatter.format(priceMinor / 100),
                      style: AppTextStyles.priceLg,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: const Text('Add to bag'),
                ),
              ),
            ],
          ),
        ),
      );
}
