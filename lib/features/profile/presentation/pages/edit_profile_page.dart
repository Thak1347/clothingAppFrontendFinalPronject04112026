import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/phone_number_field.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});
  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  String _phoneCountryCode = '+855';

  @override
  void initState() {
    super.initState();
    final profile = Get.find<ProfileController>().profile.value;
    _name = TextEditingController(text: profile?.name ?? '');
    _email = TextEditingController(text: profile?.email ?? '');
    _phone = TextEditingController(text: profile?.phone ?? '');
    _phoneCountryCode = profile?.phoneCountryCode ?? '+855';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Personal details')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.margin),
                children: [
                  Text('Your details', style: AppTextStyles.headlineLg),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                      'Keep your contact information up to date for order updates.',
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.inkMuted)),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                      controller: _name,
                      label: 'Your name',
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Name is required.'
                          : null),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                      controller: _email,
                      label: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || !GetUtils.isEmail(v.trim())
                          ? 'Enter a valid email.'
                          : null),
                  const SizedBox(height: AppSpacing.lg),
                  PhoneNumberField(
                      controller: _phone,
                      countryCode: _phoneCountryCode,
                      onCountryCodeChanged: (value) =>
                          setState(() => _phoneCountryCode = value),
                      label: 'Your phone number',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Obx(() => controller.errorMessage.value.isEmpty
                      ? const SizedBox.shrink()
                      : Text(controller.errorMessage.value,
                          style: AppTextStyles.bodySm.copyWith(
                              color: Theme.of(context).colorScheme.error))),
                  const SizedBox(height: AppSpacing.lg),
                  Obx(() => AppButton(
                        text: 'Save changes',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  controller.saveProfile(
                                      name: _name.text,
                                      email: _email.text,
                                      phone: _phone.text,
                                      phoneCountryCode: _phoneCountryCode);
                                }
                              },
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
