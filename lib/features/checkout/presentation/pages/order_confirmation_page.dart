import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/order.dart';

class OrderConfirmationPage extends StatelessWidget {
  const OrderConfirmationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final order = Get.arguments as Order;
    final isCashOnDelivery = order.paymentMethod == 'cash';
    final depositMinor = order.payment?.amountMinor ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Order placed')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.margin),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.section),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceWhite,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: .1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.success,
                            size: 34,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          'Thank you for your order',
                          style: AppTextStyles.headlineLg,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Order ${order.number}',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.inkMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Divider(),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          isCashOnDelivery
                              ? 'Your COD documents are awaiting admin review. After approval, pay the 50% deposit through ABA Pay. The remaining balance is paid in cash at delivery.'
                              : 'Your order was received. Payment is pending until it is confirmed by the payment provider.',
                          style: AppTextStyles.bodyMd,
                          textAlign: TextAlign.center,
                        ),
                        if (isCashOnDelivery) ...[
                          const SizedBox(height: AppSpacing.md),
                          _InfoLine(
                            label: 'Deposit after approval',
                            value:
                                '${order.currency} ${CurrencyFormatter.format(depositMinor / 100)}',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Cancellation is reviewed by admin. No payment is automatically taken or forfeited.',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.inkMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FilledButton.icon(
                    onPressed: () => Get.offNamed(
                      isCashOnDelivery ? AppRoutes.orders : AppRoutes.payment,
                      arguments: isCashOnDelivery ? null : order,
                    ),
                    icon: Icon(
                      isCashOnDelivery
                          ? Icons.receipt_long_outlined
                          : Icons.account_balance_outlined,
                    ),
                    label: Text(
                      isCashOnDelivery
                          ? 'View order status'
                          : 'Continue to payment',
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Get.offNamed(AppRoutes.orders),
                    child: const Text('View my orders'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label, style: AppTextStyles.bodySm),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(value, style: AppTextStyles.priceMd),
        ],
      );
}
