import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/admin_controller.dart';

class AdminPaymentsPage extends GetView<AdminController> {
  const AdminPaymentsPage({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        if (controller.loadingPayments.value && controller.payments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.payments.isEmpty && controller.error.value.isNotEmpty) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(AppSpacing.margin),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off_outlined,
                  size: 40, color: AppColors.inkMuted),
              const SizedBox(height: AppSpacing.md),
              Text(controller.error.value,
                  textAlign: TextAlign.center, style: AppTextStyles.bodyMd),
              TextButton.icon(
                  onPressed: controller.loadPayments,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again')),
            ]),
          ));
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: controller.payments.isEmpty
                ? _empty()
                : RefreshIndicator(
                    onRefresh: controller.loadPayments,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.margin,
                          AppSpacing.lg, AppSpacing.margin, AppSpacing.xl),
                      itemCount: controller.payments.length + 1,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, index) {
                        if (index == 0) {
                          return Padding(
                            padding:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Payments',
                                      style: AppTextStyles.headlineLg),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                      'Review payment records and transaction references.',
                                      style: AppTextStyles.bodyMd
                                          .copyWith(color: AppColors.inkMuted)),
                                ]),
                          );
                        }
                        final payment = controller.payments[index - 1];
                        final amount = _int(payment['amount_minor']);
                        final status = '${payment['status'] ?? 'unknown'}';
                        return _PaymentCard(
                          provider: '${payment['provider'] ?? 'Payment'}',
                          status: status,
                          id: '${payment['id'] ?? '—'}',
                          reference:
                              '${payment['reference'] ?? 'No reference'}',
                          currency: '${payment['currency'] ?? ''}',
                          amount: (amount / 100).toStringAsFixed(2),
                        );
                      },
                    ),
                  ),
          ),
        );
      });

  Widget _empty() => Center(
          child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.payments_outlined,
              size: 44, color: AppColors.inkMuted),
          const SizedBox(height: AppSpacing.md),
          Text('No payment records yet', style: AppTextStyles.headlineSm),
          const SizedBox(height: AppSpacing.sm),
          Text('Payment activity will appear here as customers place orders.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.inkMuted)),
        ]),
      ));

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard(
      {required this.provider,
      required this.status,
      required this.id,
      required this.reference,
      required this.currency,
      required this.amount});
  final String provider;
  final String status;
  final String id;
  final String reference;
  final String currency;
  final String amount;

  @override
  Widget build(BuildContext context) => Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
              child: const Icon(Icons.credit_card_outlined),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(provider, style: AppTextStyles.labelLg),
                        _PaymentStatus(status: status),
                      ]),
                  const SizedBox(height: AppSpacing.xs),
                  Text('Payment #$id',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.inkMuted)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(reference,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.inkMuted)),
                ])),
            const SizedBox(width: AppSpacing.md),
            Text('$currency $amount',
                textAlign: TextAlign.right, style: AppTextStyles.priceLg),
          ]),
        ),
      );
}

class _PaymentStatus extends StatelessWidget {
  const _PaymentStatus({required this.status});
  final String status;
  @override
  Widget build(BuildContext context) {
    final normalized = status.toLowerCase();
    final color = switch (normalized) {
      'paid' || 'completed' || 'succeeded' => AppColors.success,
      'failed' || 'expired' || 'refunded' => AppColors.error,
      _ => AppColors.warning,
    };
    final label = normalized
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(30)),
      child: Text(label, style: AppTextStyles.labelSm.copyWith(color: color)),
    );
  }
}
