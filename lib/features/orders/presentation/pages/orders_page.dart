import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../controllers/orders_controller.dart';
import '../widgets/order_status_chip.dart';

class OrdersPage extends GetView<OrdersController> {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        bottomNavigationBar: const AppBottomNavigationBar(),
        appBar: AppBar(title: const Text('My orders')),
        body: Obx(() {
          if (controller.isLoading.value && controller.orders.isEmpty) {
            return const LoadingView();
          }
          if (controller.error.value.isNotEmpty && controller.orders.isEmpty) {
            return ErrorView(
              message: controller.error.value,
              onRetry: controller.load,
            );
          }
          if (controller.orders.isEmpty) {
            return const EmptyView(
              icon: Icons.receipt_long_outlined,
              message: 'Your orders will appear here after checkout.',
              actionLabel: 'Start shopping',
              onAction: _goShopping,
            );
          }

          return RefreshIndicator(
            onRefresh: controller.load,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.margin,
                    AppSpacing.lg,
                    AppSpacing.margin,
                    AppSpacing.xxl,
                  ),
                  itemCount: controller.orders.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (_, index) {
                    final order = controller.orders[index];
                    final paymentStatus = order.paymentStatus ??
                        order.payment?.status ??
                        'unpaid';
                    return Material(
                      color: AppColors.surfaceWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Get.toNamed(
                          AppRoutes.orderDetail,
                          arguments: order.id,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Order ${order.number}',
                                          style: AppTextStyles.headlineSm,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'} · ${order.fulfillmentStatus.replaceAll('_', ' ')}',
                                          style: AppTextStyles.bodySm.copyWith(
                                            color: AppColors.inkMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  const Icon(
                                    Icons.chevron_right,
                                    color: AppColors.inkMuted,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: [
                                  OrderStatusChip(
                                    status: order.fulfillmentStatus,
                                  ),
                                  OrderStatusChip(status: paymentStatus),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Divider(height: 1),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Order total',
                                    style: AppTextStyles.bodySm.copyWith(
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                  Text(
                                    '${order.currency} ${CurrencyFormatter.format(order.totalMinor / 100)}',
                                    style: AppTextStyles.priceMd,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }),
      );

  static void _goShopping() => Get.offAllNamed(AppRoutes.home);
}
