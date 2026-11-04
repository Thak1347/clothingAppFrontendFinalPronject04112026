import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/address.dart';
import '../controllers/addresses_controller.dart';

class AddressFormPage extends StatefulWidget {
  const AddressFormPage({super.key});
  @override
  State<AddressFormPage> createState() => _AddressFormPageState();
}

class _AddressFormPageState extends State<AddressFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final Address? _existing;
  late final TextEditingController _label, _recipient, _phone, _line, _province;
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    _existing = Get.arguments is Address ? Get.arguments as Address : null;
    final picked = Get.arguments is Map ? Get.arguments as Map : const {};
    _label = TextEditingController(text: _existing?.label ?? '');
    _recipient = TextEditingController(text: _existing?.recipientName ?? '');
    _phone = TextEditingController(text: _existing?.phone ?? '');
    _line = TextEditingController(
        text: (picked['address_line'] as String?) ??
            _existing?.addressLine ??
            '');
    _province = TextEditingController(
        text: (picked['province'] as String?) ?? _existing?.province ?? '');
    _isDefault = _existing?.isDefault ?? false;
  }

  @override
  void dispose() {
    _label.dispose();
    _recipient.dispose();
    _phone.dispose();
    _line.dispose();
    _province.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AddressesController>();
    if (Get.find<AuthController>().user.value == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sign in required')),
        body: Center(
            child: TextButton(
          onPressed: () => Get.toNamed(AppRoutes.login),
          child: const Text('Sign in to save an address'),
        )),
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(_existing == null ? 'Add address' : 'Edit address')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: ListView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppSpacing.margin),
                children: [
                  Text(
                      _existing == null
                          ? 'Where should we deliver?'
                          : 'Update delivery details',
                      style: AppTextStyles.headlineLg),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Save a place to make your next checkout quicker.',
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.inkMuted)),
                  const SizedBox(height: AppSpacing.lg),
                  OutlinedButton.icon(
                    onPressed: _chooseOnMap,
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Choose location on map'),
                    style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52)),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                      controller: _label, label: 'Home, work, or another name'),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                      controller: _recipient,
                      label: 'Full name',
                      validator: _required),
                  const SizedBox(height: AppSpacing.lg),
                 
                  AppTextField(
                      controller: _phone,
                      label: 'Contact phone',
                      keyboardType: TextInputType.phone,
                      validator: _required),
                  const SizedBox(height: AppSpacing.lg),
                  
                  AppTextField(
                      controller: _line,
                      label: 'House, street, and area',
                      validator: _required,
                      maxLines: 2),
                  const SizedBox(height: AppSpacing.lg),
                  
                  AppTextField(
                      controller: _province,
                      label: 'Province / city',
                      validator: _required),
                  const SizedBox(height: AppSpacing.sm),
                  CheckboxListTile(
                    value: _isDefault,
                    onChanged: (value) =>
                        setState(() => _isDefault = value ?? false),
                    title: Text('Set as default address',
                        style: AppTextStyles.labelLg),
                    subtitle: Text('Use this address first at checkout.',
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.inkMuted)),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                  Obx(() => controller.errorMessage.value.isEmpty
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: Text(controller.errorMessage.value,
                              style: AppTextStyles.bodySm.copyWith(
                                  color: Theme.of(context).colorScheme.error)),
                        )),
                  const SizedBox(height: AppSpacing.lg),
                  Obx(() => AppButton(
                        text:
                            _existing == null ? 'Save address' : 'Save changes',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.isLoading.value ? null : _save,
                      )),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _chooseOnMap() async {
    final picked = await Get.toNamed(AppRoutes.mapPicker);
    if (picked is Map && mounted) {
      setState(() {
        _line.text = picked['address_line'] as String? ?? _line.text;
        _province.text = picked['province'] as String? ?? _province.text;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final address = Address(
      id: _existing?.id,
      label: _label.text.trim(),
      recipientName: _recipient.text.trim(),
      phone: _phone.text.trim(),
      addressLine: _line.text.trim(),
      province: _province.text.trim(),
      isDefault: _isDefault,
    );
    if (await Get.find<AddressesController>().save(address)) Get.back();
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required.' : null;
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Text(text, style: AppTextStyles.labelMd),
      );
}
