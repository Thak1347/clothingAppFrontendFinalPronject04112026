import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_form_dialogs.dart';

class AdminCategoriesPage extends GetView<AdminController> {
  const AdminCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => AdminFormDialogs.editCategory(context, controller),
          icon: const Icon(Icons.add),
          label: const Text('Add category'),
        ),
        body: Obx(() {
          if (controller.loadingCategories.value &&
              controller.categories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: controller.categories.isEmpty
                  ? _empty(context)
                  : RefreshIndicator(
                      onRefresh: controller.loadCategories,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.margin,
                            AppSpacing.lg, AppSpacing.margin, 100),
                        itemCount: controller.categories.length + 1,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(bottom: AppSpacing.md),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Categories',
                                        style: AppTextStyles.headlineLg),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                        'Organize products into clear collections for your customers.',
                                        style: AppTextStyles.bodyMd.copyWith(
                                            color: AppColors.inkMuted)),
                                  ]),
                            );
                          }
                          final category = controller.categories[index - 1];
                          final id = _int(category['id']);
                          final active = category['is_active'] != false;
                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm),
                              leading: Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                    color: AppColors.canvas,
                                    borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm)),
                                child: const Icon(Icons.category_outlined),
                              ),
                              title: Text(
                                  '${category['name'] ?? 'Untitled category'}',
                                  style: AppTextStyles.labelLg),
                              subtitle: Padding(
                                padding:
                                    const EdgeInsets.only(top: AppSpacing.xs),
                                child: Wrap(
                                    spacing: AppSpacing.sm,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text('${category['slug'] ?? ''}',
                                          style: AppTextStyles.bodySm.copyWith(
                                              color: AppColors.inkMuted)),
                                      _CategoryStatus(active: active),
                                      if (_createdDate(category['created_at']) != null)
                                        Text('Added ${_createdDate(category['created_at'])}',
                                            style: AppTextStyles.bodySm.copyWith(
                                                color: AppColors.inkMuted)),
                                    ]),
                              ),
                              onTap: () => AdminFormDialogs.editCategory(
                                  context, controller,
                                  category: category),
                              trailing: PopupMenuButton<String>(
                                tooltip: 'Category actions',
                                onSelected: (action) {
                                  if (action == 'edit') {
                                    AdminFormDialogs.editCategory(
                                        context, controller,
                                        category: category);
                                  }
                                  if (action == 'delete') {
                                    AdminFormDialogs.confirmDelete(
                                        context,
                                        'Delete category?',
                                        'Categories with products cannot be deleted.',
                                        () => controller.deleteCategory(id));
                                  }
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                      value: 'edit',
                                      child: ListTile(
                                          leading: Icon(Icons.edit_outlined),
                                          title: Text('Edit'),
                                          dense: true)),
                                  PopupMenuItem(
                                      value: 'delete',
                                      child: ListTile(
                                          leading: Icon(Icons.delete_outline),
                                          title: Text('Delete'),
                                          dense: true)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          );
        }),
      );

  Widget _empty(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.category_outlined,
              size: 44, color: AppColors.inkMuted),
          const SizedBox(height: AppSpacing.md),
          Text('Create your first collection', style: AppTextStyles.headlineSm),
          const SizedBox(height: AppSpacing.sm),
          Text(
              'Categories make it easier for customers to explore your catalog.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
              onPressed: () =>
                  AdminFormDialogs.editCategory(context, controller),
              icon: const Icon(Icons.add),
              label: const Text('Add category')),
        ]),
      ));

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  String? _createdDate(dynamic value) {
    final date = DateTime.tryParse('$value');
    return date == null ? null : DateFormat('MMM d, yyyy').format(date.toLocal());
  }
}

class _CategoryStatus extends StatelessWidget {
  const _CategoryStatus({required this.active});
  final bool active;
  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.success : AppColors.inkMuted;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
          color: color.withValues(alpha: .1),
          borderRadius: BorderRadius.circular(30)),
      child: Text(active ? 'Active' : 'Inactive',
          style: AppTextStyles.labelSm.copyWith(color: color)),
    );
  }
}
