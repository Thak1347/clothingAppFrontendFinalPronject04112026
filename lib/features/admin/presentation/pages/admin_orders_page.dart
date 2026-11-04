import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../orders/presentation/widgets/order_status_chip.dart';
import '../controllers/admin_controller.dart';

class AdminOrdersPage extends GetView<AdminController> {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        if (controller.loadingOrders.value && controller.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.value.isNotEmpty && controller.orders.isEmpty) {
          return _retry(controller.error.value);
        }
        if (controller.orders.isEmpty) {
          return const Center(child: Text('There are no orders yet.'));
        }
        return RefreshIndicator(
          onRefresh: controller.loadOrders,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(AppSpacing.margin,
                    AppSpacing.lg, AppSpacing.margin, AppSpacing.xl),
                itemCount: controller.orders.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Orders', style: AppTextStyles.headlineLg),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                                'Review order progress, payment, and requests that need attention.',
                                style: AppTextStyles.bodyMd
                                    .copyWith(color: AppColors.inkMuted)),
                          ]),
                    );
                  }
                  final order = controller.orders[index - 1];
                  final updating =
                      controller.updatingOrderIds.contains(order.id);
                  final needsCodReview = order.paymentMethod == 'cash' &&
                      ['pending', 'correction_required']
                          .contains(order.codVerificationStatus) &&
                      order.fulfillmentStatus == 'pending_verification';
                  final needsCancellationReview =
                      order.fulfillmentStatus == 'cancellation_requested';
                  final needsCodApproval = order.paymentMethod == 'cash' &&
                      order.fulfillmentStatus == 'pending_approval' &&
                      order.paymentStatus == 'partially_paid';
                  final statusOptions = order.fulfillmentStatus == 'processing'
                      ? ['shipped', 'cancelled']
                      : order.fulfillmentStatus == 'shipped' &&
                              order.paymentMethod != 'cash'
                          ? ['delivered', 'cancelled']
                          : ['cancelled'];
                  return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                        title: Text('Order ${order.number}'),
                        subtitle: Text(
                            '${order.items.length} items · ${order.currency} ${(order.totalMinor / 100).toStringAsFixed(2)} · Payment ${order.paymentStatus ?? order.payment?.status ?? 'unknown'}${order.codVerificationStatus == null ? '' : ' · COD ${order.codVerificationStatus}'}'),
                        leading:
                            OrderStatusChip(status: order.fulfillmentStatus),
                        trailing: updating
                            ? const SizedBox.square(
                                dimension: 22,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : needsCancellationReview
                                ? IconButton(
                                    onPressed: () =>
                                        _reviewCancellation(context, order),
                                    tooltip: 'Review cancellation request',
                                    icon:
                                        const Icon(Icons.rule_folder_outlined))
                                : needsCodApproval
                                    ? IconButton(
                                        onPressed: () =>
                                            _approveCodOrder(context, order),
                                        tooltip: 'Approve COD for processing',
                                        icon: const Icon(
                                            Icons.check_circle_outline))
                                    : needsCodReview
                                        ? IconButton(
                                            onPressed: () =>
                                                _reviewCod(context, order),
                                            tooltip: 'Review COD customer',
                                            icon: const Icon(
                                                Icons.verified_user_outlined))
                                        : order.paymentMethod == 'cash' &&
                                                order.fulfillmentStatus ==
                                                    'shipped'
                                            ? IconButton(
                                                onPressed: () =>
                                                    _collectCodBalance(
                                                        context, order),
                                                tooltip:
                                                    'Record COD cash and deliver',
                                                icon: const Icon(
                                                    Icons.payments_outlined))
                                            : [
                                                      'delivered',
                                                      'cancelled',
                                                      'rejected'
                                                    ].contains(order
                                                        .fulfillmentStatus) &&
                                                    order.refundPendingMinor > 0
                                                ? IconButton(
                                                    onPressed: () =>
                                                        _completeRefund(
                                                            context, order),
                                                    tooltip: 'Record completed refund',
                                                    icon: const Icon(Icons.assignment_turned_in_outlined))
                                                : ['delivered', 'cancelled', 'rejected'].contains(order.fulfillmentStatus) && order.amountPaidMinor > order.refundedMinor
                                                    ? IconButton(onPressed: () => _initiateRefund(context, order), tooltip: 'Initiate refund', icon: const Icon(Icons.currency_exchange))
                                                    : ['delivered', 'cancelled', 'rejected'].contains(order.fulfillmentStatus)
                                                        ? const SizedBox.shrink()
                                                        : PopupMenuButton<String>(tooltip: 'Update fulfillment', onSelected: (status) => controller.updateFulfillment(order.id, status), itemBuilder: (_) => statusOptions.map((status) => PopupMenuItem(value: status, child: Text(status.replaceAll('_', ' ')))).toList()),
                      ));
                },
              ),
            ),
          ),
        );
      });

  Widget _retry(String message) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(message, textAlign: TextAlign.center),
        TextButton(onPressed: controller.loadOrders, child: const Text('Retry'))
      ]));

  void _reviewCod(BuildContext context, dynamic order) {
    final customer = order.codCustomer as Map<String, dynamic>? ?? const {};
    final reason = TextEditingController(text: order.codReviewReason ?? '');
    showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: Text('Review COD · ${order.number}'),
              content: SizedBox(
                  width: 440,
                  child: ListView(shrinkWrap: true, children: [
                    Text('Name: ${customer['name'] ?? ''}'),
                    Text('Phone: ${customer['phone'] ?? ''}'),
                    Text('Email: ${customer['email'] ?? ''}'),
                    Text('Telegram: ${customer['telegram'] ?? ''}'),
                    Text('Address: ${customer['address'] ?? ''}'),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                        onPressed: () async {
                          final bytes =
                              await controller.loadCodDocument(order.id);
                          if (bytes != null && context.mounted) {
                            showDialog<void>(
                                context: context,
                                builder: (_) => Dialog(
                                    child: InteractiveViewer(
                                        child: Image.memory(bytes))));
                          }
                        },
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('View private home photo')),
                    Text(
                        'Order total: ${order.currency} ${(order.totalMinor / 100).toStringAsFixed(2)}'),
                    Text(
                        'Deposit due after approval: ${order.currency} ${((order.payment?.amountMinor ?? 0) / 100).toStringAsFixed(2)}'),
                    Text(
                        'Deposit status: ${order.payment?.status ?? 'unpaid'}'),
                    Text(
                        'Provider transaction: ${order.payment?.metadata?['provider_txn_ref'] ?? order.payment?.reference ?? 'not paid'}'),
                    Text(
                        'COD terms accepted: ${order.codTermsAcceptedAt ?? 'not recorded'}'),
                    TextField(
                        controller: reason,
                        maxLines: 3,
                        decoration: const InputDecoration(
                            labelText:
                                'Reason for correction or rejection (required for those decisions)')),
                  ])),
              actions: [
                TextButton(
                    onPressed: () {
                      if (reason.text.trim().isEmpty) {
                        Get.snackbar('Reason required',
                            'Explain what the customer must correct.');
                        return;
                      }
                      Navigator.pop(dialogContext);
                      controller.reviewCod(order.id, 'request_correction',
                          reason: reason.text);
                    },
                    child: const Text('Request correction')),
                TextButton(
                    onPressed: () {
                      if (reason.text.trim().isEmpty) {
                        Get.snackbar('Reason required',
                            'Explain why this order is rejected.');
                        return;
                      }
                      Navigator.pop(dialogContext);
                      controller.reviewCod(order.id, 'reject',
                          reason: reason.text);
                    },
                    child: const Text('Reject')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      controller.reviewCod(order.id, 'approve');
                    },
                    child: const Text('Approve details')),
              ],
            ));
  }

  void _reviewCancellation(BuildContext context, dynamic order) {
    final reason = TextEditingController();
    showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: Text('Cancellation request · ${order.number}'),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment status: ${order.paymentStatus ?? 'unpaid'}'),
                    Text(
                        'Amount received: ${order.currency} ${(order.amountPaidMinor / 100).toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    TextField(
                        controller: reason,
                        maxLines: 2,
                        decoration:
                            const InputDecoration(labelText: 'Decision note')),
                    const Text(
                        'Approving cancellation does not automatically refund a confirmed deposit. Record any refund separately after it is processed.'),
                  ]),
              actions: [
                TextButton(
                    onPressed: () {
                      if (reason.text.trim().isEmpty) {
                        Get.snackbar('Decision note required',
                            'Explain why the order will remain active.');
                        return;
                      }
                      Navigator.pop(dialogContext);
                      controller.reviewCancellation(order.id, 'reject',
                          reason: reason.text);
                    },
                    child: const Text('Keep order active')),
                FilledButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      controller.reviewCancellation(order.id, 'approve',
                          reason: reason.text);
                    },
                    child: const Text('Approve cancellation')),
              ],
            ));
  }

  Future<void> _approveCodOrder(BuildContext context, dynamic order) async {
    final approved = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Approve COD order · ${order.number}'),
              content: Text(
                  'The customer details were approved and ABA confirmed the ${order.currency} ${(order.amountPaidMinor / 100).toStringAsFixed(2)} deposit (transaction ${order.payment?.metadata?['provider_txn_ref'] ?? order.payment?.reference ?? 'verified by provider'}). Move this order to processing? The remaining ${order.currency} ${(order.remainingBalanceMinor / 100).toStringAsFixed(2)} is due in cash at delivery.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Back')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Approve order'))
              ],
            ));
    if (approved == true) {
      await controller.approveCodOrder(order.id);
    }
  }

  Future<void> _collectCodBalance(BuildContext context, dynamic order) async {
    final amount = order.remainingBalanceMinor as int;
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
              title: const Text('Record cash collected?'),
              content: Text(
                  'Confirm the courier received ${order.currency} ${(amount / 100).toStringAsFixed(2)} in cash from the customer. This records the remaining balance and marks the order delivered.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Back')),
                FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Confirm cash received'))
              ],
            ));
    if (confirmed == true) {
      await controller.recordCodBalance(order.id);
    }
  }

  Future<void> _initiateRefund(BuildContext context, dynamic order) async {
    final values = await showDialog<(int, String)?>(
        context: context,
        builder: (_) => _RefundInitiationDialog(
              orderNumber: order.number.toString(),
              refundableMinor: order.amountPaidMinor - order.refundedMinor,
            ));
    if (values != null) {
      await controller.recordRefund(order.id, 'initiated',
          amountMinor: values.$1, reason: values.$2);
    }
  }

  Future<void> _completeRefund(BuildContext context, dynamic order) async {
    final confirmed = await showDialog<String?>(
        context: context,
        builder: (_) =>
            _RefundCompletionDialog(orderNumber: order.number.toString()));
    if (confirmed != null) {
      await controller.recordRefund(order.id, 'completed', reason: confirmed);
    }
  }
}

class _RefundInitiationDialog extends StatefulWidget {
  const _RefundInitiationDialog({
    required this.orderNumber,
    required this.refundableMinor,
  });

  final String orderNumber;
  final int refundableMinor;

  @override
  State<_RefundInitiationDialog> createState() =>
      _RefundInitiationDialogState();
}

class _RefundInitiationDialogState extends State<_RefundInitiationDialog> {
  late final TextEditingController amount;
  final reason = TextEditingController();
  final form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    amount = TextEditingController(
      text: (widget.refundableMinor / 100).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    amount.dispose();
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Start refund · ${widget.orderNumber}'),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Refund the customer through ABA or their original payment channel first. This only records the refund in the shop.',
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: amount,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration:
                      const InputDecoration(labelText: 'Amount to refund'),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    return parsed == null ||
                            parsed <= 0 ||
                            parsed * 100 > widget.refundableMinor
                        ? 'Enter an amount within the refundable balance'
                        : null;
                  },
                ),
                TextFormField(
                  controller: reason,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Reason'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () {
              if (!(form.currentState?.validate() ?? false)) return;
              Navigator.pop(
                context,
                (
                  (double.parse(amount.text) * 100).round(),
                  reason.text.trim(),
                ),
              );
            },
            child: const Text('Mark refund as pending'),
          ),
        ],
      );
}

class _RefundCompletionDialog extends StatefulWidget {
  const _RefundCompletionDialog({required this.orderNumber});

  final String orderNumber;

  @override
  State<_RefundCompletionDialog> createState() =>
      _RefundCompletionDialogState();
}

class _RefundCompletionDialogState extends State<_RefundCompletionDialog> {
  final reason = TextEditingController();

  @override
  void dispose() {
    reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text('Confirm refund completed · ${widget.orderNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Only confirm after the refund has been sent to the customer through ABA or their original payment channel.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: reason,
              decoration: const InputDecoration(
                labelText: 'Provider refund reference or note',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () {
              if (reason.text.trim().isEmpty) return;
              Navigator.pop(context, reason.text.trim());
            },
            child: const Text('Confirm completed'),
          ),
        ],
      );
}
