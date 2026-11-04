import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/profile_controller.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Change password')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.margin),
                children: [
                  Text('Keep your account secure',
                      style: AppTextStyles.headlineLg),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Enter your current password, then choose a new one.',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppTextField(
                    controller: _currentPassword,
                    label: 'Current password',
                    obscureText: true,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) => value == null || value.isEmpty
                        ? 'Enter your current password.'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _newPassword,
                    label: 'New password',
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) => value == null || value.length < 8
                        ? 'Use at least 8 characters.'
                        : value == _currentPassword.text
                            ? 'Choose a password different from your current one.'
                            : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _confirmPassword,
                    label: 'Confirm new password',
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: (value) => value != _newPassword.text
                        ? 'Passwords do not match.'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Obx(() => controller.errorMessage.value.isEmpty
                      ? const SizedBox.shrink()
                      : Text(
                          controller.errorMessage.value,
                          style: AppTextStyles.bodySm.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )),
                  const SizedBox(height: AppSpacing.lg),
                  Obx(
                    () => AppButton(
                      text: 'Update password',
                      isLoading: controller.isLoading.value,
                      onPressed: controller.isLoading.value
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              final updated = await controller.updatePassword(
                                currentPassword: _currentPassword.text,
                                newPassword: _newPassword.text,
                              );
                              if (!updated || !context.mounted) return;
                              Get.back(result: true);
                              Get.snackbar(
                                'Password updated',
                                'Your password has been changed.',
                              );
                            },
                    ),
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
