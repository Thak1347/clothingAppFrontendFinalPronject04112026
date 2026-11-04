import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../addresses/domain/entities/address.dart';
import '../../../addresses/presentation/controllers/addresses_controller.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../domain/entities/checkout_preview.dart';
import '../controllers/checkout_controller.dart';

class CheckoutPage extends GetView<CheckoutController> {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Checkout')),
        body: Obx(() {
          final addresses = _uniqueAddresses(
            Get.find<AddressesController>().addresses,
          );
          final selectedId = controller.selectedAddress.value?.id;
          final selectedAddress = addresses
              .where((address) => address.id == selectedId)
              .firstOrNull;
          final cart = Get.find<CartController>();

          if (cart.items.isEmpty) {
            return const EmptyView(
              icon: Icons.shopping_bag_outlined,
              message: 'Your bag is empty. Add a piece before checkout.',
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= 900) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1240),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.section,
                        AppSpacing.lg,
                        AppSpacing.section,
                        AppSpacing.lg,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 6,
                            child: ListView(
                              children: [
                                _addressSection(
                                  context,
                                  addresses,
                                  selectedAddress,
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _paymentSection(context),
                              ],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.section),
                          Expanded(
                            flex: 5,
                            child: ListView(
                              children: [
                                _orderSummary(context, cart),
                                const SizedBox(height: AppSpacing.lg),
                                _totalsSection(
                                    context, controller.preview.value),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.margin,
                  AppSpacing.lg,
                  AppSpacing.margin,
                  AppSpacing.xl,
                ),
                children: [
                  _orderSummary(context, cart),
                  const SizedBox(height: AppSpacing.section),
                  _addressSection(context, addresses, selectedAddress),
                  const SizedBox(height: AppSpacing.section),
                  _paymentSection(context),
                  const SizedBox(height: AppSpacing.section),
                  _totalsSection(context, controller.preview.value),
                ],
              );
            },
          );
        }),
        bottomNavigationBar: Obx(() {
          final preview = controller.preview.value;
          if (preview == null) return const SizedBox.shrink();
          return _CheckoutActionBar(
            totalMinor: preview.totalMinor,
            currency: preview.currency,
            isSubmitting: controller.isSubmitting.value,
            enabled: !controller.isLoading.value,
            onSubmit: () => _submit(context),
          );
        }),
      );

  List<Address> _uniqueAddresses(List<Address> source) => source
      .where((address) => address.id != null)
      .fold<Map<int, Address>>({}, (unique, address) {
        unique.putIfAbsent(address.id!, () => address);
        return unique;
      })
      .values
      .toList(growable: false);

  Widget _addressSection(
    BuildContext context,
    List<Address> addresses,
    Address? selectedAddress,
  ) =>
      _SectionCard(
        title: 'Delivery address',
        subtitle: 'Choose where you would like your order delivered.',
        icon: Icons.location_on_outlined,
        child: addresses.isEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add a saved address to continue.',
                    style: AppTextStyles.bodyMd.copyWith(
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Get.toNamed(AppRoutes.addressForm);
                      await controller.reloadAddresses();
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add address'),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: selectedAddress?.id,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Saved address',
                      hintText: 'Choose an address',
                    ),
                    items: addresses
                        .map(
                          (address) => DropdownMenuItem<int>(
                            value: address.id!,
                            child: Text(
                              '${address.label ?? 'Address'} · ${address.addressLine}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (id) {
                      if (id == null) return;
                      final address =
                          addresses.firstWhereOrNull((item) => item.id == id);
                      if (address != null) controller.selectAddress(address);
                    },
                  ),
                  if (selectedAddress != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.canvas,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Text(
                        '${selectedAddress.recipientName} · ${selectedAddress.phone}\n${selectedAddress.province}',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      );

  Widget _paymentSection(BuildContext context) => _SectionCard(
        title: 'Payment method',
        subtitle: 'Choose how you would like to pay.',
        icon: Icons.account_balance_wallet_outlined,
        child: Obx(
          () => RadioGroup<String>(
            groupValue: controller.paymentMethod.value,
            onChanged: (value) {
              if (value != null) controller.paymentMethod.value = value;
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'aba_pay',
                  title: const Text('ABA Pay QR'),
                  subtitle: const Text('Scan a secure QR code with ABA Mobile.'),
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.qr_code_2),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  value: 'khqr_checkout',
                  title: const Text('ABA Pay checkout page'),
                  subtitle: const Text(
                    'Open a secure hosted checkout with an ABA Mobile link.',
                  ),
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.open_in_browser_outlined),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  value: 'cash',
                  title: const Text('Cash on delivery'),
                  subtitle: const Text('50% deposit after document approval.'),
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.local_shipping_outlined),
                ),
                if (controller.paymentMethod.value == 'cash') ...[
                  const SizedBox(height: AppSpacing.md),
                  _codInformation(context),
                  const SizedBox(height: AppSpacing.md),
                  Form(
                    key: controller.codFormKey,
                    child: Column(
                      children: [
                        _field(controller.codName, 'Full name'),
                        const SizedBox(height: AppSpacing.md),
                        _field(
                          controller.codPhone,
                          'Phone',
                          type: TextInputType.phone,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _field(
                          controller.codEmail,
                          'Email',
                          type: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _field(
                          controller.codTelegram,
                          'Telegram username or number',
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _field(
                          controller.codAddress,
                          'Home delivery address',
                          maxLines: 2,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Obx(() => SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _pickHomePhoto,
                                icon: const Icon(Icons.home_outlined),
                                label: Text(
                                  controller.codHomePhoto.value?.name ??
                                      'Upload a photo of your home address',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )),
                        const SizedBox(height: AppSpacing.sm),
                        Obx(() => CheckboxListTile(
                              value: controller.codPolicyAccepted.value,
                              onChanged: (value) => controller
                                  .codPolicyAccepted.value = value ?? false,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                              title: const Text(
                                'I understand the 50% deposit, admin review, cancellation request, and privacy information above.',
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );

  Widget _codInformation(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Text(
          'We use these details and your home photo to verify delivery and reduce fake orders. Only authorized admins can view the photo. Photos are deleted immediately when a request is rejected or cancelled, and 90 days after delivery. A cancellation request is reviewed by admin. No money is collected before ABA confirms the 50% deposit, and no deposit is automatically forfeited or refunded on cancellation.',
          style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted),
        ),
      );

  Widget _orderSummary(BuildContext context, CartController cart) =>
      _SectionCard(
        title: 'Your items',
        subtitle:
            '${cart.items.length} ${cart.items.length == 1 ? 'item' : 'items'} in your bag',
        icon: Icons.shopping_bag_outlined,
        child: Column(
          children: cart.items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              [
                                if (item.variant?.size.isNotEmpty == true)
                                  item.variant!.size,
                                if (item.variant?.color.isNotEmpty == true)
                                  item.variant!.color,
                                'Qty ${item.quantity}',
                              ].join(' · '),
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
              )
              .toList(),
        ),
      );

  Widget _totalsSection(BuildContext context, CheckoutPreview? preview) =>
      _SectionCard(
        title: 'Order total',
        subtitle: preview == null
            ? 'Your total will appear when delivery is calculated.'
            : 'Delivery and payment breakdown.',
        icon: Icons.receipt_long_outlined,
        child: Column(
          children: [
            if (controller.isLoading.value) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: AppSpacing.md),
            ],
            if (preview != null) ...[
              _price('Subtotal', preview.subtotalMinor, preview.currency),
              _price('Delivery', preview.deliveryFeeMinor, preview.currency),
              const Divider(height: AppSpacing.lg),
              _price('Total', preview.totalMinor, preview.currency, bold: true),
              if (controller.paymentMethod.value == 'cash') ...[
                const SizedBox(height: AppSpacing.md),
                _price(
                  '50% deposit after approval',
                  (preview.totalMinor + 1) ~/ 2,
                  preview.currency,
                ),
                _price(
                  'Remaining cash at delivery',
                  preview.totalMinor - ((preview.totalMinor + 1) ~/ 2),
                  preview.currency,
                ),
              ],
            ],
            if (controller.error.value.isNotEmpty) ...[
              if (preview != null) const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  controller.error.value,
                  style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: controller.refreshPreview,
                  child: const Text('Retry total'),
                ),
              ),
            ],
          ],
        ),
      );

  Widget _price(
    String label,
    int minor,
    String currency, {
    bool bold = false,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: bold ? AppTextStyles.labelLg : AppTextStyles.bodyMd,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '$currency ${CurrencyFormatter.format(minor / 100)}',
              style: bold ? AppTextStyles.priceLg : AppTextStyles.bodyMd,
            ),
          ],
        ),
      );

  Widget _field(
    RxString value,
    String label, {
    TextInputType? type,
    int maxLines = 1,
  }) =>
      TextFormField(
        key: ValueKey(label),
        initialValue: value.value,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(labelText: label),
        validator: (input) {
          final text = input?.trim() ?? '';
          if (text.isEmpty) return 'This field is required';
          if (label == 'Email' && !GetUtils.isEmail(text)) {
            return 'Enter a valid email';
          }
          value.value = text;
          return null;
        },
        onChanged: (input) => value.value = input,
      );

  Future<void> _pickHomePhoto() async {
    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 78,
    );
    if (file != null) controller.codHomePhoto.value = file;
  }

  Future<void> _submit(BuildContext context) async {
    if (controller.paymentMethod.value == 'cash' &&
        (!(controller.codFormKey.currentState?.validate() ?? false) ||
            controller.codHomePhoto.value == null ||
            !controller.codPolicyAccepted.value)) {
      Get.snackbar(
        'COD details required',
        'Complete the form, upload your home photo, and accept the COD terms.',
      );
      return;
    }
    final order = await controller.submit();
    if (order != null) {
      Get.toNamed(AppRoutes.orderConfirmation, arguments: order);
    }
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  final String title;
  final String subtitle;
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.canvas,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(icon, color: AppColors.inkMuted, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTextStyles.headlineSm),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            child,
          ],
        ),
      );
}

class _CheckoutActionBar extends StatelessWidget {
  const _CheckoutActionBar({
    required this.totalMinor,
    required this.currency,
    required this.isSubmitting,
    required this.enabled,
    required this.onSubmit,
  });

  final int totalMinor;
  final String currency;
  final bool isSubmitting;
  final bool enabled;
  final VoidCallback onSubmit;

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
                      'Total',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '$currency ${CurrencyFormatter.format(totalMinor / 100)}',
                      style: AppTextStyles.priceLg,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: enabled && !isSubmitting ? onSubmit : null,
                  child: isSubmitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Place order'),
                ),
              ),
            ],
          ),
        ),
      );
}
