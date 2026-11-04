import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/receipt.dart';
import '../controllers/receipt_controller.dart';
import '../widgets/receipt_action_buttons.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  late final ReceiptController controller;
  late final int orderId;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ReceiptController>();
    orderId = Get.arguments as int;
    // Start loading before the first frame so the page shows its loading state
    // instead of briefly rendering the empty/error state after navigation.
    controller.load(orderId);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Order receipt')),
        body: Obx(() {
          final receipt = controller.receipt.value;
          if (controller.loading.value && receipt == null) {
            return const LoadingView();
          }
          if (receipt == null) {
            return ErrorView(
              message: controller.error.value.isEmpty
                  ? 'Unable to load this order receipt.'
                  : controller.error.value,
              onRetry: () => controller.load(orderId, force: true),
            );
          }
          return LayoutBuilder(
            builder: (context, constraints) {
              final content = ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.margin,
                    AppSpacing.md,
                    AppSpacing.margin,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                  _ReceiptHeading(receipt: receipt),
                  const SizedBox(height: AppSpacing.md),
                  _ReceiptSection(
                    title: 'Customer and delivery',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoLine(
                            label: 'Name', value: _value(receipt.customerName)),
                        _InfoLine(
                            label: 'Phone',
                            value: _value(receipt.customerPhone)),
                        _InfoLine(
                            label: 'Email',
                            value: _value(receipt.customerEmail)),
                        _InfoLine(
                          label: 'Address',
                          value: _value(receipt.deliveryAddress),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ReceiptSection(
                    title: 'Products',
                    child: Column(
                      children: receipt.items
                          .map((item) =>
                              _ReceiptItemRow(item: item, receipt: receipt))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ReceiptSection(
                    title: receipt.isCodDeposit
                        ? 'Order and deposit summary'
                        : 'Payment summary',
                    child: Column(
                      children: [
                        _AmountLine(
                          label: 'Subtotal',
                          value:
                              _money(receipt.subtotalMinor, receipt.currency),
                        ),
                        _AmountLine(
                          label: 'Discount',
                          value:
                              '- ${_money(receipt.discountMinor, receipt.currency)}',
                        ),
                        _AmountLine(
                          label: 'Delivery fee',
                          value: _money(
                              receipt.deliveryFeeMinor, receipt.currency),
                        ),
                        const Divider(height: AppSpacing.lg),
                        _AmountLine(
                          label: 'Total order amount',
                          value: _money(receipt.totalMinor, receipt.currency),
                          emphasized: true,
                        ),
                        if (receipt.isCodDeposit) ...[
                          const Divider(height: AppSpacing.lg),
                          _AmountLine(
                            label: '50% deposit paid',
                            value: _money(
                              receipt.amountPaidMinor,
                              receipt.currency,
                            ),
                          ),
                          _AmountLine(
                            label: 'Remaining due at delivery',
                            value: _money(
                              receipt.remainingBalanceMinor,
                              receipt.currency,
                            ),
                            emphasized: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _ReceiptSection(
                    title: 'Payment information',
                    child: Column(
                      children: [
                        _InfoLine(
                          label: 'Method',
                          value: receipt.isCodDeposit
                              ? 'Cash on delivery · ABA Pay deposit'
                              : _value(receipt.paymentMethod),
                        ),
                        _InfoLine(
                          label: 'Transaction ID',
                          value: _value(receipt.transactionId),
                        ),
                        _InfoLine(
                          label: 'Payment date',
                          value: _date(receipt.paymentDate),
                        ),
                        _InfoLine(
                          label: 'Payment status',
                          value: _status(receipt.paymentStatus),
                        ),
                      ],
                    ),
                  ),
                    ],
                  ),
                ),
              );

              // Center a short receipt in the available space. Long receipts
              // remain top-aligned and scroll naturally on smaller screens.
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(child: content),
                ),
              );
            },
          );
        }),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surfaceWhite,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.margin,
              vertical: AppSpacing.sm,
            ),
            child: ReceiptActionButtons(
              orderId: orderId,
              controller: controller,
            ),
          ),
        ),
      );
}

class _ReceiptHeading extends StatelessWidget {
  const _ReceiptHeading({required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ÉTOFFE ATELIER'),
            const SizedBox(height: AppSpacing.sm),
            Text(
              receipt.isCodDeposit ? 'Deposit receipt' : 'Order receipt',
              style: AppTextStyles.headlineLg,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Order ${receipt.orderNumber}', style: AppTextStyles.bodyMd),
            Text(
              'Issued ${_date(receipt.issuedAt)}',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _StatusPill(label: _status(receipt.paymentStatus)),
                _StatusPill(
                  label: 'Order ${_status(receipt.fulfillmentStatus)}',
                ),
              ],
            ),
          ],
        ),
      );
}

class _ReceiptSection extends StatelessWidget {
  const _ReceiptSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      );
}

class _ReceiptItemRow extends StatelessWidget {
  const _ReceiptItemRow({required this.item, required this.receipt});

  final ReceiptItem item;
  final Receipt receipt;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: AppTextStyles.bodyMd),
                  Text(
                    [
                      'Qty ${item.quantity}',
                      if (item.size?.isNotEmpty ?? false) 'Size ${item.size}',
                      if (item.color?.isNotEmpty ?? false)
                        'Color ${item.color}',
                    ].join(' · '),
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              _money(item.subtotalMinor, receipt.currency),
              style: AppTextStyles.priceMd,
            ),
          ],
        ),
      );
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 125,
              child: Text(
                label,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
              ),
            ),
            Expanded(child: Text(value, style: AppTextStyles.bodyMd)),
          ],
        ),
      );
}

class _AmountLine extends StatelessWidget {
  const _AmountLine({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style:
                    emphasized ? AppTextStyles.labelLg : AppTextStyles.bodyMd,
              ),
            ),
            Text(
              value,
              style: emphasized ? AppTextStyles.priceLg : AppTextStyles.bodyMd,
            ),
          ],
        ),
      );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Text(label, style: AppTextStyles.labelMd),
      );
}

String _value(String value) => value.trim().isEmpty ? 'Not provided' : value;

String _date(DateTime? date) => date == null
    ? 'Not available'
    : DateFormat('MMM d, yyyy · h:mm a').format(date.toLocal());

String _status(String value) => value
    .replaceAll('_', ' ')
    .split(' ')
    .where((word) => word.isNotEmpty)
    .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
    .join(' ');

String _money(int minor, String currency) {
  final amount = NumberFormat('#,##0.00').format(minor / 100);
  return currency.toUpperCase() == 'USD' ? '\$$amount' : '$currency $amount';
}
