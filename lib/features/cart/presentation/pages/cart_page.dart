import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../features/auth/presentation/controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../widgets/cart_item_tile.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CartController>();

    return Scaffold(
      bottomNavigationBar: const AppBottomNavigationBar(),
      appBar: AppBar(title: const Text('Shopping bag')),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return Column(
            children: [
              const Expanded(
                child: EmptyView(
                  icon: Icons.shopping_bag_outlined,
                  message: 'Your bag is ready for something new.',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.md,
                  AppSpacing.margin,
                  AppSpacing.margin,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.home),
                    child: const Text('Continue shopping'),
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.margin,
                      AppSpacing.lg,
                      AppSpacing.margin,
                      AppSpacing.lg,
                    ),
                    itemCount: controller.items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.md),
                    itemBuilder: (_, index) {
                      final item = controller.items[index];
                      return CartItemTile(
                        item: item,
                        onDecrement: () => controller.updateQuantity(
                          item.key,
                          item.quantity - 1,
                        ),
                        onIncrement: () => controller.updateQuantity(
                          item.key,
                          item.quantity + 1,
                        ),
                        onRemove: () => controller.remove(item.key),
                      );
                    },
                  ),
                ),
              ),
            ),
            SafeArea(
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal · ${controller.items.length} ${controller.items.length == 1 ? 'item' : 'items'}',
                              style: AppTextStyles.bodyMd,
                            ),
                            Text(
                              CurrencyFormatter.format(
                                controller.totalMinor / 100,
                              ),
                              style: AppTextStyles.priceLg,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FilledButton.icon(
                          onPressed: () {
                            if (Get.find<AuthController>().user.value == null) {
                              Get.toNamed(AppRoutes.login);
                            } else {
                              Get.toNamed(AppRoutes.checkout);
                            }
                          },
                          icon: const Icon(Icons.lock_outline),
                          label: const Text('Continue to checkout'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
