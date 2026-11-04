import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome back')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text('Sign in', style: AppTextStyles.displayMdMobile),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(controller: _email, label: 'Email', keyboardType: TextInputType.emailAddress, validator: (value) => value == null || !GetUtils.isEmail(value.trim()) ? 'Enter a valid email.' : null),
              const SizedBox(height: AppSpacing.md),
              AppTextField(controller: _password, label: 'Password', obscureText: true, validator: (value) => value == null || value.isEmpty ? 'Enter your password.' : null),
              const SizedBox(height: AppSpacing.md),
              Obx(() => controller.errorMessage.value.isEmpty ? const SizedBox.shrink() : Text(controller.errorMessage.value, style: TextStyle(color: Theme.of(context).colorScheme.error))),
              const SizedBox(height: AppSpacing.md),
              Obx(() => AppButton(text: 'Sign in', isLoading: controller.isLoading.value, onPressed: controller.isLoading.value ? null : () { if (_formKey.currentState!.validate()) controller.login(_email.text, _password.text); })),
              TextButton(onPressed: () => Get.toNamed(AppRoutes.register), child: const Text('Create an account')),
            ]),
          ),
        ),
      ),
    );
  }
}
