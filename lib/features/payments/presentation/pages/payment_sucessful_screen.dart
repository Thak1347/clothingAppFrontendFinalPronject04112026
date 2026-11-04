import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../checkout/domain/entities/order.dart';

/// Shown only after the authenticated order refresh reports a provider-verified
/// payment. A COD deposit is identified separately from full payment.
class PaymentSuccessfulScreen extends StatelessWidget {
  const PaymentSuccessfulScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final isDeposit = order.payment?.status == 'partially_paid';
    final amountMinor = order.payment?.amountMinor ?? order.totalMinor;

    return Scaffold(
      appBar: AppBar(
        title: Text(isDeposit ? 'Deposit confirmed' : 'Payment confirmed'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.margin),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.section),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: .1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: AppColors.success,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      isDeposit
                          ? 'Your 50% deposit is verified.'
                          : 'Your payment is verified.',
                      style: AppTextStyles.headlineLg,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Order ${order.number}',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.inkMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isDeposit ? 'Deposit paid' : 'Amount paid',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            '${order.currency} ${CurrencyFormatter.format(amountMinor / 100)}',
                            style: AppTextStyles.priceLg,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    if (isDeposit) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Remaining at delivery: ${order.currency} ${CurrencyFormatter.format(order.remainingBalanceMinor / 100)}',
                        style: AppTextStyles.bodyMd,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        order.fulfillmentStatus == 'pending_approval'
                            ? 'Your COD documents and deposit are ready for admin approval.'
                            : 'Your order is being processed.',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.inkMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.section),
                    if (order.payment?.status == 'paid')
                      FilledButton.icon(
                        onPressed: () => Get.toNamed(
                          AppRoutes.receipt,
                          arguments: order.id,
                        ),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('View receipt'),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () => Get.toNamed(
                          AppRoutes.receipt,
                          arguments: order.id,
                        ),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('View deposit receipt'),
                      ),
                    TextButton(
                      onPressed: () => Get.offAllNamed(AppRoutes.orders),
                      child: const Text('View my orders'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
