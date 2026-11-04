import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (Get.find<AuthController>().user.value == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notifications')),
        body: const Center(child: Text('Sign in to manage notifications.')),
      );
    }
    final controller = Get.find<NotificationController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.margin),
            children: [
              Text('Stay in the know', style: AppTextStyles.headlineLg),
              const SizedBox(height: AppSpacing.sm),
              Text(
                  'Get timely updates about your account and shopping activity.',
                  style:
                      AppTextStyles.bodyMd.copyWith(color: AppColors.inkMuted)),
              const SizedBox(height: AppSpacing.xl),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                              color: AppColors.canvas,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusMd)),
                          child: const Icon(Icons.notifications_active_outlined,
                              color: AppColors.ink),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text('Push notifications',
                                  style: AppTextStyles.labelLg),
                              const SizedBox(height: AppSpacing.xs),
                              Obx(() => Text(
                                  _statusText(
                                      controller.permissionStatus.value),
                                  style: AppTextStyles.bodySm.copyWith(
                                      color: _statusColor(context,
                                          controller.permissionStatus.value)))),
                            ])),
                      ]),
                      Obx(() {
                        final message = controller.errorMessage.value;
                        if (message.isEmpty) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.md),
                          child: Text(
                            message,
                            style: AppTextStyles.bodySm.copyWith(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(),
                      const SizedBox(height: AppSpacing.sm),
                      _NotificationType(
                          icon: Icons.local_shipping_outlined,
                          title: 'Order updates',
                          description:
                              'Important changes to your delivery and order status.'),
                      const SizedBox(height: AppSpacing.md),
                      _NotificationType(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Account activity',
                          description:
                              'Helpful confirmations about your account and purchases.'),
                      const SizedBox(height: AppSpacing.lg),
                      Obx(() {
                        final status = controller.permissionStatus.value;
                        if (kIsWeb ||
                            (status == 'unavailable' &&
                                controller.errorMessage.value.isEmpty)) {
                          return Text(
                              'Push notifications are not available on this device.',
                              style: AppTextStyles.bodySm
                                  .copyWith(color: AppColors.inkMuted));
                        }
                        if ((status == 'enabled' ||
                                status == 'provisional' ||
                                status == 'denied') &&
                            controller.errorMessage.value.isEmpty) {
                          return OutlinedButton.icon(
                            onPressed: controller.isCheckingPermission.value
                                ? null
                                : controller.refreshPermissionStatus,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh status'),
                          );
                        }
                        return SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: controller.isCheckingPermission.value
                                ? null
                                : controller.enableNotifications,
                            icon: controller.isCheckingPermission.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Icon(Icons.notifications_outlined),
                            label: Text(status == 'denied'
                                ? 'Check notification access'
                                : 'Enable notifications'),
                          ),
                        );
                      }),
                    ]),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                  'You can also change notification access anytime in your device settings.',
                  style:
                      AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted)),
            ],
          ),
        ),
      ),
    );
  }

  static String _statusText(String status) => switch (status) {
        'enabled' => 'Enabled on this device',
        'provisional' => 'Enabled with quiet delivery',
        'denied' => 'Blocked in device settings',
        'not_requested' => 'Not enabled',
        'unavailable' => 'Status unavailable',
        _ => 'Checking permission…',
      };

  static Color _statusColor(BuildContext context, String status) =>
      switch (status) {
        'enabled' => AppColors.success,
        'provisional' => AppColors.warning,
        'denied' => Theme.of(context).colorScheme.error,
        _ => AppColors.inkMuted,
      };
}

class _NotificationType extends StatelessWidget {
  const _NotificationType(
      {required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppColors.inkMuted, size: 21),
        const SizedBox(width: AppSpacing.md),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTextStyles.labelLg),
          const SizedBox(height: AppSpacing.xs),
          Text(description,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted)),
        ])),
      ]);
}
