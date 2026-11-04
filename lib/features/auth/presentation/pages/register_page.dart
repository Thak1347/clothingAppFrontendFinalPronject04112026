import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/phone_number_field.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  String _phoneCountryCode = '+855';
  final _password = TextEditingController();
  final _confirmation = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.margin),
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('Join ÉTOFFE Atelier', style: AppTextStyles.displayMdMobile),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
                controller: _name,
                label: 'Full name',
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Enter your name.' : null),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
                controller: _email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || !GetUtils.isEmail(v.trim())
                    ? 'Enter a valid email.'
                    : null),
            const SizedBox(height: AppSpacing.md),
            PhoneNumberField(
              controller: _phone,
              countryCode: _phoneCountryCode,
              onCountryCodeChanged: (value) =>
                  setState(() => _phoneCountryCode = value),
              label: 'Phone (optional)',
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
                controller: _password,
                label: 'Password',
                obscureText: true,
                validator: (v) => v == null || v.length < 8
                    ? 'Use at least 8 characters.'
                    : null),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
                controller: _confirmation,
                label: 'Confirm password',
                obscureText: true,
                validator: (v) =>
                    v != _password.text ? 'Passwords do not match.' : null),
            const SizedBox(height: AppSpacing.md),
            Obx(() => controller.errorMessage.value.isEmpty
                ? const SizedBox.shrink()
                : Text(controller.errorMessage.value,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error))),
            const SizedBox(height: AppSpacing.md),
            Obx(() => AppButton(
                text: 'Create account',
                isLoading: controller.isLoading.value,
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          controller.register(
                              name: _name.text,
                              email: _email.text,
                              phone: _phone.text,
                              phoneCountryCode: _phoneCountryCode,
                              password: _password.text,
                              passwordConfirmation: _confirmation.text);
                        }
                      })),
          ]),
        ),
      ),
    );
  }
}
