import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/utils/asset_resolver.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../controllers/admin_controller.dart';
import '../widgets/admin_form_dialogs.dart';

class AdminProductsPage extends GetView<AdminController> {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => AdminFormDialogs.editProduct(context, controller),
          icon: const Icon(Icons.add),
          label: const Text('Add product'),
        ),
        body: Obx(() {
          if (controller.loadingProducts.value && controller.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: controller.products.isEmpty
                  ? _empty(context)
                  : RefreshIndicator(
                      onRefresh: controller.loadProducts,
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(AppSpacing.margin,
                            AppSpacing.lg, AppSpacing.margin, 100),
                        itemCount: controller.products.length + 1,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.md),
                        itemBuilder: (context, index) {
                          if (index == 0) return _pageIntro();
                          final product = controller.products[index - 1];
                          final id = _int(product['id']);
                          final variants = (product['variants'] as List? ??
                                  const [])
                              .whereType<Map>()
                              .map((item) => Map<String, dynamic>.from(item))
                              .toList();
                          final images =
                              (product['images'] as List? ?? const [])
                                  .whereType<Map>()
                                  .toList();
                          final imageCandidates = [
                            ...images.map((image) => image['url']),
                            product['image_url'],
                          ];
                          final rawImageUrl = imageCandidates
                              .whereType<String>()
                              .map((url) => url.trim())
                              .firstWhere((url) => url.isNotEmpty,
                                  orElse: () => '');
                          final active = product['is_active'] != false;
                          return Card(
                            margin: EdgeInsets.zero,
                            clipBehavior: Clip.antiAlias,
                            child: ExpansionTile(
                              tilePadding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm),
                              childrenPadding: const EdgeInsets.fromLTRB(
                                  AppSpacing.md,
                                  0,
                                  AppSpacing.md,
                                  AppSpacing.md),
                              leading: _ProductImage(
                                url: rawImageUrl.isEmpty
                                    ? null
                                    : ImageUrlResolver.resolve(rawImageUrl),
                              ),
                              title: Text(
                                  '${product['name'] ?? 'Untitled product'}',
                                  style: AppTextStyles.labelLg),
                              subtitle: Padding(
                                padding:
                                    const EdgeInsets.only(top: AppSpacing.xs),
                                child: Wrap(
                                    spacing: AppSpacing.sm,
                                    runSpacing: AppSpacing.xs,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                          'USD ${(_int(product['price_minor']) / 100).toStringAsFixed(2)}',
                                          style: AppTextStyles.priceMd),
                                      Text('${images.length} images',
                                          style: AppTextStyles.bodySm.copyWith(
                                              color: AppColors.inkMuted)),
                                      Text('${variants.length} variants',
                                          style: AppTextStyles.bodySm.copyWith(
                                              color: AppColors.inkMuted)),
                                      _StatusPill(
                                          label: active ? 'Active' : 'Inactive',
                                          active: active),
                                      if (_createdDate(product['created_at']) != null)
                                        Text('Added ${_createdDate(product['created_at'])}',
                                            style: AppTextStyles.bodySm.copyWith(
                                                color: AppColors.inkMuted)),
                                    ]),
                              ),
                              children: [
                                const Divider(),
                                Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Text(
                                              '${product['description'] ?? 'No description'}',
                                              style: AppTextStyles.bodyMd)),
                                      IconButton(
                                          tooltip: 'Edit product',
                                          onPressed: () =>
                                              AdminFormDialogs.editProduct(
                                                  context, controller,
                                                  product: product),
                                          icon:
                                              const Icon(Icons.edit_outlined)),
                                      IconButton(
                                          tooltip: 'Delete product',
                                          onPressed: () =>
                                              AdminFormDialogs.confirmDelete(
                                                  context,
                                                  'Delete product?',
                                                  'This removes the product and its variants.',
                                                  () => controller
                                                      .deleteProduct(id)),
                                          icon:
                                              const Icon(Icons.delete_outline)),
                                    ]),
                                if (variants.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Variants & stock',
                                          style: AppTextStyles.labelLg)),
                                  const SizedBox(height: AppSpacing.sm),
                                  ...variants.map((variant) => _VariantRow(
                                        variant: variant,
                                        onEdit: () =>
                                            AdminFormDialogs.editVariant(
                                                context, controller, id,
                                                variant: variant),
                                        onDelete: () =>
                                            AdminFormDialogs.confirmDelete(
                                                context,
                                                'Delete variant?',
                                                'This variant will no longer be available for purchase.',
                                                () => controller.deleteVariant(
                                                    id, _int(variant['id']))),
                                      )),
                                ],
                                Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton.icon(
                                      onPressed: () =>
                                          AdminFormDialogs.editVariant(
                                              context, controller, id),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add variant'),
                                    )),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          );
        }),
      );

  Widget _pageIntro() => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Products & stock', style: AppTextStyles.headlineLg),
          const SizedBox(height: AppSpacing.xs),
          Text('Manage product details, variants, images, and inventory.',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.inkMuted)),
        ]),
      );

  Widget _empty(BuildContext context) => Center(
          child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.inventory_2_outlined,
              size: 44, color: AppColors.inkMuted),
          const SizedBox(height: AppSpacing.md),
          Text('Your catalog starts here', style: AppTextStyles.headlineSm),
          const SizedBox(height: AppSpacing.sm),
          Text('Add a product to begin building your collection.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.inkMuted)),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
              onPressed: () =>
                  AdminFormDialogs.editProduct(context, controller),
              icon: const Icon(Icons.add),
              label: const Text('Add product')),
        ]),
      ));

  int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  String? _createdDate(dynamic value) {
    final date = DateTime.tryParse('$value');
    return date == null ? null : DateFormat('MMM d, yyyy').format(date.toLocal());
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: SizedBox(
          width: 54,
          height: 62,
          child: url == null
              ? _placeholder()
              : Image.network(
                  url!,
                  fit: BoxFit.cover,
                  cacheWidth: 160,
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : _placeholder(),
                  errorBuilder: (_, __, ___) => _placeholder(),
                ),
        ),
      );

  Widget _placeholder() => Image.asset(
        AssetResolver.fallbackProductImage,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: AppColors.canvas,
          child: Icon(Icons.checkroom_outlined),
        ),
      );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.active});
  final String label;
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
      child: Text(label, style: AppTextStyles.labelSm.copyWith(color: color)),
    );
  }
}

class _VariantRow extends StatelessWidget {
  const _VariantRow(
      {required this.variant, required this.onEdit, required this.onDelete});
  final Map<String, dynamic> variant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.only(left: AppSpacing.md),
        decoration: BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
        child: Row(children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            '${variant['size'] ?? ''} · ${variant['color'] ?? ''}',
                            style: AppTextStyles.labelMd),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                            'SKU ${variant['sku'] ?? '—'} · ${variant['stock_quantity'] ?? 0} in stock',
                            style: AppTextStyles.bodySm
                                .copyWith(color: AppColors.inkMuted)),
                      ]))),
          IconButton(
              tooltip: 'Edit variant',
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined)),
          IconButton(
              tooltip: 'Delete variant',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline)),
        ]),
      );
}
