import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/addresses_controller.dart';
import '../widgets/address_tile.dart';

class AddressListPage extends StatelessWidget {
  const AddressListPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.find<AuthController>().user.value == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Saved addresses')),
        body: Center(
            child: TextButton(
          onPressed: () => Get.toNamed(AppRoutes.login),
          child: const Text('Sign in to manage saved addresses'),
        )),
      );
    }
    final controller = Get.find<AddressesController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Saved addresses')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addressForm),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add address'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingView();
        if (controller.errorMessage.value.isNotEmpty &&
            controller.addresses.isEmpty) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.all(AppSpacing.margin),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.wifi_off_outlined,
                  size: 40, color: AppColors.inkMuted),
              const SizedBox(height: AppSpacing.md),
              Text(controller.errorMessage.value,
                  textAlign: TextAlign.center, style: AppTextStyles.bodyMd),
              TextButton.icon(
                  onPressed: controller.load,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again')),
            ]),
          ));
        }
        if (controller.addresses.isEmpty) {
          return Center(
              child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.margin),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: const BoxDecoration(
                      color: AppColors.surfaceWhite, shape: BoxShape.circle),
                  child: const Icon(Icons.location_on_outlined,
                      size: 38, color: AppColors.inkMuted),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Your places, ready when you are',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineSm),
                const SizedBox(height: AppSpacing.sm),
                Text(
                    'Save a delivery address for a quicker checkout next time.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.inkMuted)),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.addressForm),
                    icon: const Icon(Icons.add),
                    label: const Text('Add an address')),
              ]),
            ),
          ));
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: RefreshIndicator(
              onRefresh: controller.load,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.margin, AppSpacing.lg, AppSpacing.margin, 100),
                itemCount: controller.addresses.length + 1,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (_, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Text(
                          'Choose a saved place at checkout. Set one as default for faster delivery.',
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.inkMuted)),
                    );
                  }
                  final address = controller.addresses[index - 1];
                  return AddressTile(
                    address: address,
                    onEdit: () =>
                        Get.toNamed(AppRoutes.addressForm, arguments: address),
                    onDelete: () => controller.remove(address.id!),
                    onMakeDefault: () => controller.makeDefault(address.id!),
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
