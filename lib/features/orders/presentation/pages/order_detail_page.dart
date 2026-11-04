import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../domain/entities/order.dart';
import '../controllers/order_detail_controller.dart';
import '../widgets/order_status_chip.dart';
import '../../../receipts/presentation/controllers/receipt_controller.dart';
import '../../../receipts/presentation/widgets/receipt_action_buttons.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late final OrderDetailController controller;
  late final int id;

  @override
  void initState() {
    super.initState();
    id = Get.arguments as int;
    controller = Get.find<OrderDetailController>();
    controller.load(id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Order details')),
        body: Obx(() {
          final order = controller.order.value;
          if (controller.isLoading.value && order == null) {
            return const LoadingView();
          }
          if (order == null) {
            return ErrorView(
              message: controller.error.value.isEmpty
                  ? 'Unable to load this order.'
                  : controller.error.value,
              onRetry: () => controller.load(id),
            );
          }

          final cod = order.paymentMethod == 'cash';
          final canRequestCancel = [
            'pending_payment',
            'pending_verification',
            'awaiting_deposit',
            'pending_approval',
            'processing',
          ].contains(order.fulfillmentStatus);
          final canPayDeposit = cod &&
              order.fulfillmentStatus == 'awaiting_deposit' &&
              ['unpaid', 'pending', 'expired', 'failed']
                  .contains(order.payment?.status);

          return RefreshIndicator(
            onRefresh: () => controller.load(id),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.margin,
                    AppSpacing.lg,
                    AppSpacing.margin,
                    AppSpacing.xxl,
                  ),
                  children: [
                    _orderHeader(order),
                    if (controller.error.value.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      _MessageCard(
                        message: controller.error.value,
                        isError: true,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    if (cod) ...[
                      _codSection(order, canPayDeposit),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    _itemsSection(order),
                    const SizedBox(height: AppSpacing.lg),
                    _paymentSummary(order),
                    const SizedBox(height: AppSpacing.lg),
                    if (!cod &&
                        ['pending', 'expired', 'failed']
                            .contains(order.payment?.status)) ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => Get.toNamed(
                            AppRoutes.payment,
                            arguments: order,
                          ),
                          icon: const Icon(Icons.account_balance_outlined),
                          label: const Text('Continue payment'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    if (canRequestCancel)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _requestCancel(context),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Request cancellation'),
                        ),
                      ),
                    if (order.activities.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.section),
                      _activitySection(order),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    _SectionCard(
                      title: 'Receipt',
                      icon: Icons.receipt_long_outlined,
                      child: ReceiptActionButtons(
                        orderId: order.id,
                        controller: Get.find<ReceiptController>(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      );

  Widget _orderHeader(Order order) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ${order.number}', style: AppTextStyles.headlineLg),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                OrderStatusChip(status: order.fulfillmentStatus),
                OrderStatusChip(
                  status:
                      order.paymentStatus ?? order.payment?.status ?? 'unpaid',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              _statusMessage(order),
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.inkMuted),
            ),
          ],
        ),
      );

  Widget _codSection(Order order, bool canPayDeposit) => _SectionCard(
        title: 'Cash on delivery',
        icon: Icons.local_shipping_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _KeyValue(
              label: 'Document review',
              value: (order.codVerificationStatus ?? 'pending')
                  .replaceAll('_', ' '),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              order.codReviewReason ??
                  (order.codVerificationStatus == 'verified'
                      ? 'Details approved. ABA Pay deposit is available.'
                      : 'Admin reviews your details before the 50% deposit is enabled.'),
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            _KeyValue(
              label: 'Paid',
              value:
                  '${order.currency} ${CurrencyFormatter.format(order.amountPaidMinor / 100)}',
            ),
            const SizedBox(height: AppSpacing.sm),
            _KeyValue(
              label: 'Remaining at delivery',
              value:
                  '${order.currency} ${CurrencyFormatter.format(order.remainingBalanceMinor / 100)}',
            ),
            if (order.codVerificationStatus == 'correction_required') ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () =>
                      _editCod(context, order.codCustomer ?? const {}),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Correct COD information'),
                ),
              ),
            ],
            if (order.codVerificationStatus == 'rejected') ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    await controller.switchCodToAba(order.id);
                    if (controller.error.value.isEmpty) {
                      await controller.load(order.id);
                    }
                  },
                  icon: const Icon(Icons.payments_outlined),
                  label: const Text('Choose ABA Pay instead'),
                ),
              ),
            ],
            if (canPayDeposit) ...[
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Get.toNamed(
                    AppRoutes.payment,
                    arguments: order,
                  ),
                  icon: const Icon(Icons.account_balance_outlined),
                  label: const Text('Pay 50% deposit with ABA Pay'),
                ),
              ),
            ],
            if (order.fulfillmentStatus == 'cancellation_requested') ...[
              const SizedBox(height: AppSpacing.md),
              const _MessageCard(
                message:
                    'Cancellation request sent. Admin will review it. No deposit is automatically charged or forfeited.',
              ),
            ],
            if (order.fulfillmentStatus == 'pending_approval') ...[
              const SizedBox(height: AppSpacing.md),
              const _MessageCard(
                message:
                    'Deposit confirmed. Admin will make the final order approval before fulfillment.',
              ),
            ],
          ],
        ),
      );

  Widget _itemsSection(Order order) => _SectionCard(
        title: 'Items',
        icon: Icons.shopping_bag_outlined,
        child: Column(
          children: [
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name, style: AppTextStyles.bodyMd),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Qty ${item.quantity}${item.size == null ? '' : ' · ${item.size}'}${item.color == null ? '' : ' · ${item.color}'}',
                            style: AppTextStyles.bodySm.copyWith(
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      CurrencyFormatter.format(item.lineTotalMinor / 100),
                      style: AppTextStyles.priceMd,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _paymentSummary(Order order) => _SectionCard(
        title: 'Payment summary',
        icon: Icons.receipt_long_outlined,
        child: Column(
          children: [
            _KeyValue(
              label: 'Subtotal',
              value:
                  '${order.currency} ${CurrencyFormatter.format(order.subtotalMinor / 100)}',
            ),
            const SizedBox(height: AppSpacing.sm),
            _KeyValue(
              label: 'Delivery',
              value:
                  '${order.currency} ${CurrencyFormatter.format(order.deliveryFeeMinor / 100)}',
            ),
            const Divider(height: AppSpacing.lg),
            _KeyValue(
              label: 'Total',
              value:
                  '${order.currency} ${CurrencyFormatter.format(order.totalMinor / 100)}',
              emphasized: true,
            ),
            if (order.payment?.reference != null) ...[
              const SizedBox(height: AppSpacing.md),
              Align(
                alignment: Alignment.centerLeft,
                child: SelectableText(
                  'Payment reference: ${order.payment!.reference}',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      );

  Widget _activitySection(Order order) => _SectionCard(
        title: 'Order activity',
        icon: Icons.timeline_outlined,
        child: Column(
          children: order.activities
              .map(
                (activity) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.circle,
                    size: 8,
                    color: AppColors.inkMuted,
                  ),
                  title: Text(
                    '${activity['event'] ?? ''}'
                        .replaceAll('_', ' ')
                        .split(' ')
                        .map((word) => word.isEmpty
                            ? word
                            : '${word[0].toUpperCase()}${word.substring(1)}')
                        .join(' '),
                    style: AppTextStyles.bodyMd,
                  ),
                  subtitle: Text(
                    [
                      '${activity['created_at'] ?? ''}',
                      if (activity['details'] is Map &&
                          (activity['details'] as Map)['reason'] != null)
                        '${(activity['details'] as Map)['reason']}',
                    ].where((value) => value.isNotEmpty).join(' · '),
                  ),
                ),
              )
              .toList(),
        ),
      );

  Future<void> _requestCancel(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request cancellation?'),
        content: const Text(
          'This sends a request to admin. Any confirmed deposit remains recorded; this request does not automatically charge, forfeit, or refund money.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep order'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Send request'),
          ),
        ],
      ),
    );
    if (confirmed == true) await controller.cancel(id);
  }

  String _statusMessage(Order order) => switch (order.fulfillmentStatus) {
        'pending_payment' => 'Complete your payment to continue.',
        'pending_verification' => 'Your COD information is being reviewed.',
        'awaiting_deposit' =>
          'Your COD details were approved. Pay the 50% deposit to continue.',
        'pending_approval' =>
          'Your deposit is confirmed. Admin approval is pending.',
        'processing' => 'Your order is confirmed and being prepared.',
        'shipped' => 'Your order is on the way.',
        'delivered' => 'Your order has been delivered.',
        'cancellation_requested' =>
          'Your cancellation request is being reviewed.',
        'cancelled' => 'Your order has been cancelled.',
        'rejected' =>
          'Your COD request was rejected. Review the admin reason below.',
        _ => 'Your order status is ${order.fulfillmentStatus}.',
      };

  Future<void> _editCod(
    BuildContext context,
    Map<String, dynamic> customer,
  ) async {
    final name =
        TextEditingController(text: customer['name']?.toString() ?? '');
    final phone =
        TextEditingController(text: customer['phone']?.toString() ?? '');
    final email =
        TextEditingController(text: customer['email']?.toString() ?? '');
    final telegram =
        TextEditingController(text: customer['telegram']?.toString() ?? '');
    final address =
        TextEditingController(text: customer['address']?.toString() ?? '');
    XFile? photo;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          scrollable: true,
          title: const Text('Correct COD details'),
          content: SizedBox(
            width: 460,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _field(name, 'Full name'),
                  const SizedBox(height: AppSpacing.md),
                  _field(phone, 'Phone'),
                  const SizedBox(height: AppSpacing.md),
                  _field(email, 'Email'),
                  const SizedBox(height: AppSpacing.md),
                  _field(telegram, 'Telegram'),
                  const SizedBox(height: AppSpacing.md),
                  _field(address, 'Delivery address', maxLines: 2),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await ImagePicker().pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 78,
                        );
                        if (picked != null) setDialog(() => photo = picked);
                      },
                      icon: const Icon(Icons.home_outlined),
                      label: Text(
                        photo?.name ?? 'Replace home photo (optional)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.pop(ctx);
                await controller.updateCodDetails(
                  id,
                  {
                    'name': name.text.trim(),
                    'phone': phone.text.trim(),
                    'email': email.text.trim(),
                    'telegram': telegram.text.trim(),
                    'address': address.text.trim(),
                  },
                  photo,
                );
              },
              child: const Text('Resubmit'),
            ),
          ],
        ),
      ),
    );
    name.dispose();
    phone.dispose();
    email.dispose();
    telegram.dispose();
    address.dispose();
  }

  Widget _field(
    TextEditingController textController,
    String label, {
    int maxLines = 1,
  }) =>
      TextFormField(
        controller: textController,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: (value) => value == null || value.trim().isEmpty
            ? 'This field is required'
            : label == 'Email' && !GetUtils.isEmail(value.trim())
                ? 'Enter a valid email'
                : null,
      );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
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
            Row(
              children: [
                Icon(icon, color: AppColors.inkMuted),
                const SizedBox(width: AppSpacing.md),
                Text(title, style: AppTextStyles.headlineSm),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      );
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: emphasized ? AppTextStyles.labelLg : AppTextStyles.bodyMd,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            value,
            style: emphasized ? AppTextStyles.priceLg : AppTextStyles.bodyMd,
          ),
        ],
      );
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message, this.isError = false});

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: isError ? AppColors.error : AppColors.inkMuted,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(message, style: AppTextStyles.bodySm)),
          ],
        ),
      );
}
