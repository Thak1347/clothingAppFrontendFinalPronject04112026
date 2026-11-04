import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../checkout/domain/entities/order.dart';
import '../../../orders/presentation/widgets/order_status_chip.dart';
import '../controllers/payment_controller.dart';
import '../widgets/qr_display.dart';
import 'hosted_checkout_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  late final PaymentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<PaymentController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final argument = Get.arguments;
      if (argument is Order) {
        controller.start(argument);
      } else {
        controller.error.value = 'Payment information is unavailable.';
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColors.canvas,
          elevation: 0,
          title: Text('Payment', style: AppTextStyles.headlineSm),
          leading: IconButton(
            tooltip: 'Go back',
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Obx(() {
            final order = controller.order.value;
            if (order == null) {
              return Center(
                child: controller.error.value.isEmpty
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.all(AppSpacing.margin),
                        child: _Notice(
                          icon: Icons.error_outline,
                          message: controller.error.value,
                          isError: true,
                        ),
                      ),
              );
            }

            final payment = order.payment;
            final status = payment?.status ?? order.paymentStatus ?? 'pending';
            final initiation = controller.initiation.value;
            final provider =
                initiation?.provider ?? controller.selectedMethod.value;
            final cashSelected = provider == 'cash';
            final amountMinor = _amountMinor(initiation?.amount) ??
                payment?.amountMinor ??
                order.totalMinor;
            final currency =
                initiation?.currency ?? payment?.currency ?? order.currency;
            final reference = initiation?.reference ?? payment?.reference;
            final hasQr = initiation?.hasQr == true;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.margin,
                    AppSpacing.sm,
                    AppSpacing.margin,
                    AppSpacing.xxl,
                  ),
                  children: [
                    Text(
                      'Complete your payment',
                      style: AppTextStyles.displayMdMobile,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Order ${order.number}',
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _PaymentSummary(
                      status: status,
                      currency: currency,
                      amountMinor: amountMinor,
                    ),
                    if (status == 'pending' && initiation == null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _Panel(
                        title: 'Payment method',
                        child: Column(
                          children: [
                            RadioGroup<String>(
                              groupValue: controller.selectedMethod.value,
                              onChanged: (value) {
                                if (!controller.isLoading.value &&
                                    value != null) {
                                  controller.selectMethod(value);
                                }
                              },
                              child: Column(
                                children: [
                                  if (order.paymentMethod == null)
                                    RadioListTile<String>(
                                      value: 'cash',
                                      title: const Text('Cash on delivery'),
                                      subtitle: const Text(
                                        'A 50% ABA Pay deposit is required after document approval.',
                                      ),
                                      secondary: const Icon(
                                        Icons.local_shipping_outlined,
                                      ),
                                    ),
                                  if (order.paymentMethod == null)
                                    RadioListTile<String>(
                                      value: 'aba_pay',
                                      title: const Text('ABA Pay QR'),
                                      subtitle: const Text(
                                        'Scan a secure code with your banking app.',
                                      ),
                                      secondary: const Icon(Icons.qr_code_2),
                                    ),
                                  if (order.paymentMethod == null)
                                    RadioListTile<String>(
                                      value: 'khqr_checkout',
                                      title: const Text(
                                        'ABA Pay checkout page',
                                      ),
                                      subtitle: const Text(
                                        'Open a secure hosted checkout page.',
                                      ),
                                      secondary: const Icon(
                                        Icons.open_in_browser_outlined,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : controller.initiate,
                                icon: controller.isLoading.value
                                    ? const SizedBox.square(
                                        dimension: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.arrow_forward),
                                label: Text(
                                  controller.isLoading.value
                                      ? 'Setting up payment…'
                                      : cashSelected
                                          ? 'Pay with cash on delivery'
                                          : controller.selectedMethod.value ==
                                                  'aba_pay'
                                              ? 'Generate ABA Pay QR'
                                              : controller.selectedMethod
                                                          .value ==
                                                      'khqr_checkout'
                                                  ? 'Open ABA Pay checkout'
                                                  : 'Continue with KHQR',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (order.paymentMethod == 'cash' &&
                        ['unpaid', 'expired', 'failed'].contains(status)) ...[
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.initiate,
                          icon: controller.isLoading.value
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.account_balance),
                          label: Text(
                            controller.isLoading.value
                                ? 'Opening ABA Pay…'
                                : 'Pay 50% deposit with ABA Pay',
                          ),
                        ),
                      ),
                    ],
                    if (order.paymentMethod == 'cash') ...[
                      const SizedBox(height: AppSpacing.md),
                      _Panel(
                        title: 'Cash on delivery',
                        child: Text(
                          'The remaining 50% is paid in cash at delivery after admin approves your COD documents.',
                          style: AppTextStyles.bodyMd,
                        ),
                      ),
                    ],
                    if (hasQr) ...[
                      const SizedBox(height: AppSpacing.lg),
                      _BankingAppsSection(controller: controller),
                      const SizedBox(height: AppSpacing.md),
                      _Panel(
                        title: 'Scan to pay',
                        child: Column(
                          children: [
                            Text(
                              'Use your banking app to scan this secure payment code.',
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.inkMuted,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final qrSize =
                                    constraints.maxWidth.clamp(180.0, 260.0);
                                return Center(
                                  child: QrDisplay(
                                    value: initiation?.qrString ?? '',
                                    qrImageUrl: initiation?.qrImageUrl ??
                                        initiation?.qrUrl,
                                    qrImageBase64: initiation?.qrImageBase64,
                                    fallbackUrl: initiation?.qrUrl,
                                    size: qrSize,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _PaymentReference(
                        reference: reference,
                        amountMinor: amountMinor,
                        currency: currency,
                      ),
                    ],
                    if (initiation?.provider == 'khqr_checkout' &&
                        initiation?.deepLink != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => Get.to(
                            () => HostedCheckoutPage(
                              checkoutUrl: initiation!.deepLink!,
                              pollStatus: () async {
                                await controller.refresh();
                                return controller
                                        .order.value?.payment?.status ??
                                    'pending';
                              },
                            ),
                          ),
                          icon: const Icon(Icons.open_in_browser_outlined),
                          label: const Text('Open ABA Pay checkout'),
                        ),
                      ),
                    ],
                    if (controller.error.value.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      _Notice(
                        icon: Icons.info_outline,
                        message: controller.error.value,
                        isError: true,
                      ),
                    ],
                    if (['pending', 'processing'].contains(status) &&
                        ['khqr', 'aba_pay', 'khqr_checkout'].contains(
                          initiation?.provider ?? payment?.provider,
                        )) ...[
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: controller.isCheckingStatus.value
                              ? null
                              : controller.refresh,
                          icon: controller.isCheckingStatus.value
                              ? const SizedBox.square(
                                  dimension: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh_rounded),
                          label: Text(
                            controller.isCheckingStatus.value
                                ? 'Checking payment status…'
                                : 'Check payment status',
                          ),
                        ),
                      ),
                    ],
                    if (status == 'paid') ...[
                      const SizedBox(height: AppSpacing.lg),
                      const _Notice(
                        icon: Icons.verified_outlined,
                        message: 'Payment confirmed by the server.',
                      ),
                      OutlinedButton.icon(
                        onPressed: () =>
                            Get.toNamed(AppRoutes.receipt, arguments: order.id),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('View receipt'),
                      ),
                    ],
                    if (status == 'partially_paid') ...[
                      const SizedBox(height: AppSpacing.lg),
                      const _Notice(
                        icon: Icons.verified_outlined,
                        message:
                            'Your 50% deposit was verified. Admin will review the order before fulfillment.',
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        child: Text(
                          'Remaining at delivery: ${order.currency} ${CurrencyFormatter.format(order.remainingBalanceMinor / 100)}',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.priceMd,
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: () => Get.toNamed(
                          AppRoutes.receipt,
                          arguments: order.id,
                        ),
                        icon: const Icon(Icons.receipt_long_outlined),
                        label: const Text('View deposit receipt'),
                      ),
                      OutlinedButton(
                        onPressed: () => Get.offNamed(AppRoutes.orders),
                        child: const Text('View my orders'),
                      ),
                    ],
                    if (status == 'failed' || status == 'expired') ...[
                      const SizedBox(height: AppSpacing.md),
                      _Notice(
                        icon: Icons.error_outline,
                        message: status == 'failed'
                            ? 'Payment failed. You can retry from the order details.'
                            : 'This payment has expired. Start a new payment from the order details.',
                        isError: true,
                      ),
                    ],
                    if (status == 'refunded') ...[
                      const SizedBox(height: AppSpacing.md),
                      const _Notice(
                        icon: Icons.info_outline,
                        message: 'This payment was refunded.',
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      );
}

int? _amountMinor(String? amount) {
  if (amount == null) return null;
  final parsed = double.tryParse(amount);
  return parsed == null ? null : (parsed * 100).round();
}

class _PaymentSummary extends StatelessWidget {
  const _PaymentSummary({
    required this.status,
    required this.currency,
    required this.amountMinor,
  });

  final String status;
  final String currency;
  final int amountMinor;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadowLevel2,
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount due',
              style: AppTextStyles.labelMd.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '$currency ${CurrencyFormatter.format(amountMinor / 100)}',
              style: AppTextStyles.displayMdMobile,
            ),
            const SizedBox(height: AppSpacing.md),
            OrderStatusChip(status: status),
          ],
        ),
      );
}

class _BankingAppsSection extends StatelessWidget {
  const _BankingAppsSection({required this.controller});

  final PaymentController controller;

  @override
  Widget build(BuildContext context) => _Panel(
        title: 'Pay with your banking app',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Open a supported app or scan the QR code.',
              style: AppTextStyles.bodySm.copyWith(
                color: AppColors.inkMuted,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              mainAxisExtent: 54,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: CambodianBank.values.map((bank) {
                final hasDeepLink =
                    controller.initiation.value?.bankDeepLinks[bank.key] !=
                        null;
                return OutlinedButton.icon(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.openBankApp(bank),
                  icon: Icon(bank.icon, size: 19),
                  label: Text(
                    bank.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: BorderSide(
                      color: hasDeepLink ? AppColors.border : AppColors.divider,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
}

class _PaymentReference extends StatelessWidget {
  const _PaymentReference({
    required this.reference,
    required this.amountMinor,
    required this.currency,
  });

  final String? reference;
  final int amountMinor;
  final String currency;

  @override
  Widget build(BuildContext context) => _Panel(
        title: 'Payment details',
        child: Column(
          children: [
            _DetailRow(
              label: 'Reference',
              value: reference?.isNotEmpty == true ? reference! : '—',
              trailing: IconButton(
                tooltip: 'Copy payment reference',
                onPressed: reference?.isNotEmpty == true
                    ? () async {
                        await Clipboard.setData(
                          ClipboardData(text: reference!),
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment reference copied'),
                            ),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.copy_rounded, size: 18),
              ),
            ),
            const Divider(height: AppSpacing.lg),
            _DetailRow(
              label: 'Amount',
              value: '$currency ${CurrencyFormatter.format(amountMinor / 100)}',
            ),
          ],
        ),
      );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Text(
            label,
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.inkMuted,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTextStyles.labelMd,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: AppSpacing.xs),
            trailing!,
          ],
        ],
      );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
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

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.message,
    this.isError = false,
  });

  final IconData icon;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.success;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(message, style: AppTextStyles.bodyMd)),
        ],
      ),
    );
  }
}
