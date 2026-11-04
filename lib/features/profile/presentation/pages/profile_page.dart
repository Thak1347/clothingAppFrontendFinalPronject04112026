import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        bottomNavigationBar: const AppBottomNavigationBar(),
        appBar: AppBar(title: const Text('My account')),
        body: const ProfileContent(),
      );
}

/// Profile body shared with the admin dashboard's embedded Profile tab.
class ProfileContent extends StatelessWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    if (auth.user.value == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.margin),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.person_outline,
                size: 44, color: AppColors.inkMuted),
            const SizedBox(height: AppSpacing.md),
            Text('Your account, all in one place',
                style: AppTextStyles.headlineSm),
            const SizedBox(height: AppSpacing.sm),
            Text('Sign in to manage your profile, addresses, and orders.',
                textAlign: TextAlign.center, style: AppTextStyles.bodyMd),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
                onPressed: () => Get.toNamed(AppRoutes.login),
                child: const Text('Sign in')),
          ]),
        ),
      );
    }

    final controller = Get.find<ProfileController>();
    return Obx(() {
      if (controller.isLoading.value && controller.profile.value == null) {
        return const LoadingView();
      }
      final profile = controller.profile.value;
      final avatarBytes = controller.pendingAvatarBytes.value;
      final ImageProvider? avatarImage = avatarBytes != null
          ? MemoryImage(avatarBytes)
          : profile?.avatarUrl == null
              ? null
              : NetworkImage(profile!.avatarUrl!);

      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.margin, AppSpacing.lg,
                AppSpacing.margin, AppSpacing.xxl),
            children: [
              Center(
                child: Column(children: [
                  Stack(alignment: Alignment.bottomRight, children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceWhite,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: AppColors.canvas,
                        backgroundImage: avatarImage,
                        onBackgroundImageError:
                            avatarImage == null ? null : (_, __) {},
                        child: avatarImage == null
                            ? const Icon(Icons.person_outline,
                                size: 42, color: AppColors.inkMuted)
                            : null,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Material(
                        color: AppColors.ink,
                        shape: const CircleBorder(),
                        child: IconButton(
                          tooltip: 'Change profile photo',
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints.tightFor(
                              width: 38, height: 38),
                          onPressed: controller.isUploading.value
                              ? null
                              : controller.pickAndUploadAvatar,
                          color: AppColors.onInk,
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text('ÉTOFFE MEMBER',
                        style: AppTextStyles.labelSm
                            .copyWith(color: AppColors.inkMuted)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    profile?.name ?? '',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.displayMdMobile,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(profile?.email ?? '',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.inkMuted)),
                  if (profile?.createdAt != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Member since ${DateFormat('MMM d, yyyy').format(profile!.createdAt!.toLocal())}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.inkMuted),
                    ),
                  ],
                  if ((profile?.phone ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                        '${profile?.phoneCountryCode ?? ''} ${profile?.phone?.trim() ?? ''}'
                            .trim(),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySm
                            .copyWith(color: AppColors.inkMuted)),
                  ],
                ]),
              ),
              if (controller.isUploading.value) ...[
                const SizedBox(height: AppSpacing.md),
                LinearProgressIndicator(value: controller.uploadProgress.value),
              ],
              if (profile?.avatarUrl != null)
                Center(
                  child: TextButton.icon(
                    onPressed: controller.removeAvatar,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove photo'),
                  ),
                ),
              if (controller.errorMessage.value.isNotEmpty)
                _AccountError(message: controller.errorMessage.value),
              const SizedBox(height: AppSpacing.xl),
              _AccountSection(title: 'MY ACCOUNT', children: [
                _AccountLink(
                    icon: Icons.person_outline,
                    title: 'Personal details',
                    subtitle: 'Name, email and phone',
                    onTap: () => Get.toNamed(AppRoutes.editProfile)),
                _AccountLink(
                    icon: Icons.lock_outline,
                    title: 'Change password',
                    subtitle: 'Update your account password',
                    onTap: () => Get.toNamed(AppRoutes.changePassword)),
                _AccountLink(
                    icon: Icons.location_on_outlined,
                    title: 'Saved addresses',
                    subtitle: 'Manage delivery locations',
                    onTap: () => Get.toNamed(AppRoutes.addresses)),
                _AccountLink(
                    icon: Icons.notifications_none,
                    title: 'Notifications',
                    subtitle: 'Manage delivery updates',
                    onTap: () => Get.toNamed(AppRoutes.notifications)),
                _AccountLink(
                    icon: Icons.receipt_long_outlined,
                    title: 'My orders',
                    subtitle: 'Track orders and view receipts',
                    onTap: () => Get.toNamed(AppRoutes.orders),
                    last: true),
              ]),
              const SizedBox(height: AppSpacing.xl),
              _AccountSection(title: 'DISCOVER', children: [
                _AccountLink(
                    icon: Icons.storefront_outlined,
                    title: 'Shop home',
                    subtitle: 'Discover the latest styles',
                    onTap: () => Get.toNamed(AppRoutes.home)),
                _AccountLink(
                    icon: Icons.grid_view_outlined,
                    title: 'Browse catalog',
                    subtitle: 'Explore products and categories',
                    onTap: () => Get.toNamed(AppRoutes.catalog)),
                _AccountLink(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Shopping cart',
                    subtitle: 'Review items before checkout',
                    onTap: () => Get.toNamed(AppRoutes.cart),
                    last: true),
              ]),
              if (auth.user.value?.role == 'admin') ...[
                const SizedBox(height: AppSpacing.xl),
                _AccountSection(title: 'ADMINISTRATION', children: [
                  _AccountLink(
                      icon: Icons.admin_panel_settings_outlined,
                      title: 'Admin dashboard',
                      subtitle: 'Manage the store',
                      onTap: () => Get.offNamed(AppRoutes.admin),
                      last: true),
                ]),
              ],
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: controller.logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign out'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    minimumSize:
                        const Size.fromHeight(AppSpacing.minTouchTarget + 4),
                    side: BorderSide(
                        color: AppColors.error.withValues(alpha: .4)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headlineSm),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(children: children),
          ),
        ],
      );
}

class _AccountLink extends StatelessWidget {
  const _AccountLink(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.last = false});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) => Column(children: [
        ListTile(
          onTap: onTap,
          minVerticalPadding: AppSpacing.sm,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          leading: Icon(icon, color: AppColors.inkMuted),
          title: Text(title, style: AppTextStyles.labelLg),
          subtitle: Text(subtitle,
              style: AppTextStyles.bodySm.copyWith(color: AppColors.inkMuted)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.inkMuted),
        ),
        if (!last) const Divider(height: 1, indent: 56),
      ]);
}

class _AccountError extends StatelessWidget {
  const _AccountError({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: Text(message,
            style: AppTextStyles.bodySm
                .copyWith(color: Theme.of(context).colorScheme.error)),
      );
}
