import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/asset_resolver.dart';
import '../../../../core/utils/image_url_resolver.dart';
import '../controllers/admin_controller.dart';

/// Consistent, responsive dialogs for the admin catalog forms.
class AdminFormDialogs {
  AdminFormDialogs._();

  static Future<void> editCategory(
    BuildContext context,
    AdminController controller, {
    Map<String, dynamic>? category,
  }) async {
    final name = TextEditingController(text: '${category?['name'] ?? ''}');
    final slug = TextEditingController(text: '${category?['slug'] ?? ''}');
    final description =
        TextEditingController(text: '${category?['description'] ?? ''}');
    var active = category?['is_active'] != false;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _DisposeControllersOnUnmount(
        controllers: [name, slug, description],
        child: StatefulBuilder(
          builder: (context, setDialogState) => _AdminFormDialog(
            title: category == null ? 'New category' : 'Edit category',
            subtitle: category == null
                ? 'Add a category to organize your collection.'
                : 'Update the details for this category.',
            icon: Icons.sell_outlined,
            actionLabel: category == null ? 'Create category' : 'Save changes',
            onCancel: () => Navigator.pop(dialogContext),
            onSubmit: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final data = <String, dynamic>{
                'name': name.text.trim(),
                'description': description.text.trim().isEmpty
                    ? null
                    : description.text.trim(),
                'is_active': active,
                if (slug.text.trim().isNotEmpty) 'slug': slug.text.trim(),
              };
              try {
                await controller.saveCategory(
                  data,
                  id: category == null ? null : _int(category['id']),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (_) {}
            },
            content: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AdminTextField(
                    controller: name,
                    label: 'Category name',
                    hint: 'e.g. New arrivals',
                    validator: _required,
                  ),
                  const SizedBox(height: 18),
                  _AdminTextField(
                    controller: slug,
                    label: 'Slug',
                    hint: 'Optional URL-friendly name',
                  ),
                  const SizedBox(height: 18),
                  _AdminTextField(
                    controller: description,
                    label: 'Description',
                    hint: 'Add a short description',
                    maxLines: 3,
                    minLines: 3,
                  ),
                  const SizedBox(height: 20),
                  _ActiveControl(
                    value: active,
                    onChanged: (value) => setDialogState(() => active = value),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> editProduct(
    BuildContext context,
    AdminController controller, {
    Map<String, dynamic>? product,
  }) async {
    if (controller.categories.isEmpty) {
      Get.snackbar(
          'Add a category first', 'Products must belong to a category.');
      return;
    }
    final name = TextEditingController(text: '${product?['name'] ?? ''}');
    final slug = TextEditingController(text: '${product?['slug'] ?? ''}');
    final description =
        TextEditingController(text: '${product?['description'] ?? ''}');
    final existingImages = (product?['images'] as List? ?? const [])
        .whereType<Map>()
        .map((image) => Map<String, dynamic>.from(image))
        .toList();
    if (existingImages.isEmpty && product?['image_url'] is String) {
      existingImages.add({'url': product!['image_url']});
    }
    final selectedImages = <XFile>[];
    final removedImageIds = <int>{};
    final price = TextEditingController(
      text: product == null
          ? ''
          : (_int(product['price_minor']) / 100).toStringAsFixed(2),
    );
    var categoryId = _int(product?['category_id']) > 0
        ? _int(product?['category_id'])
        : _int(controller.categories.first['id']);
    var active = product?['is_active'] != false;
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _DisposeControllersOnUnmount(
        controllers: [name, slug, description, price],
        child: StatefulBuilder(
          builder: (context, setDialogState) => _AdminFormDialog(
            title: product == null ? 'New product' : 'Edit product',
            subtitle: product == null
                ? 'Add a product to your store catalog.'
                : 'Update product details, images, and availability.',
            icon: Icons.checkroom_outlined,
            actionLabel: product == null ? 'Create product' : 'Save changes',
            onCancel: () => Navigator.pop(dialogContext),
            onSubmit: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              if (product == null && selectedImages.isEmpty) {
                Get.snackbar(
                  'Product image required',
                  'Choose at least one product image.',
                );
                return;
              }
              final parsedPrice = double.parse(price.text.trim());
              final data = <String, dynamic>{
                'category_id': categoryId,
                'name': name.text.trim(),
                'description': description.text.trim().isEmpty
                    ? null
                    : description.text.trim(),
                'price_minor': (parsedPrice * 100).round(),
                'is_active': active,
                'images': selectedImages,
                'remove_image_ids': removedImageIds.toList(),
                if (slug.text.trim().isNotEmpty) 'slug': slug.text.trim(),
              };
              try {
                await controller.saveProduct(
                  data,
                  id: product == null ? null : _int(product['id']),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (_) {}
            },
            content: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DropdownButtonFormField<int>(
                    initialValue: categoryId,
                    isExpanded: true,
                    decoration: _inputDecoration(
                      label: 'Category',
                      hint: 'Select a category',
                    ),
                    items: controller.categories
                        .map(
                          (category) => DropdownMenuItem<int>(
                            value: _int(category['id']),
                            child: Text(
                              '${category['name']}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setDialogState(() => categoryId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 18),
                  _AdminTextField(
                    controller: name,
                    label: 'Product name',
                    hint: 'e.g. Relaxed linen shirt',
                    validator: _required,
                  ),
                  const SizedBox(height: 18),
                  _AdminTextField(
                    controller: slug,
                    label: 'Slug',
                    hint: 'Optional URL-friendly name',
                  ),
                  const SizedBox(height: 18),
                  _AdminTextField(
                    controller: description,
                    label: 'Description',
                    hint: 'Describe the product',
                    maxLines: 3,
                    minLines: 3,
                  ),
                  const SizedBox(height: 18),
                  _AdminTextField(
                    controller: price,
                    label: 'Price (USD)',
                    hint: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (value) => double.tryParse(value ?? '') == null
                        ? 'Enter a valid price'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  _SectionHeading(
                    title: 'Product images',
                    subtitle: 'Choose up to 10 images for this product.',
                  ),
                  const SizedBox(height: 12),
                  if (existingImages.isNotEmpty || selectedImages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          ...existingImages
                              .where((image) =>
                                  !removedImageIds.contains(_int(image['id'])))
                              .map(
                                (image) => _imageTile(
                                  child: _existingProductImage(
                                    image['url'] as String?,
                                  ),
                                  onRemove: image['id'] == null
                                      ? null
                                      : () => setDialogState(
                                            () => removedImageIds
                                                .add(_int(image['id'])),
                                          ),
                                ),
                              ),
                          ...selectedImages.asMap().entries.map(
                                (entry) => _imageTile(
                                  child: Image.file(
                                    File(entry.value.path),
                                    fit: BoxFit.cover,
                                  ),
                                  onRemove: () => setDialogState(
                                    () => selectedImages.removeAt(entry.key),
                                  ),
                                ),
                              ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: existingImages.length -
                                  removedImageIds.length +
                                  selectedImages.length >=
                              10
                          ? null
                          : () async {
                              final picked = await ImagePicker()
                                  .pickMultiImage(imageQuality: 85);
                              if (picked.isEmpty || !context.mounted) return;
                              setDialogState(() {
                                final available = 10 -
                                    (existingImages.length -
                                        removedImageIds.length +
                                        selectedImages.length);
                                selectedImages.addAll(picked.take(available));
                              });
                            },
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: const Text('Choose images'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ActiveControl(
                    value: active,
                    onChanged: (value) => setDialogState(() => active = value),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> editVariant(
    BuildContext context,
    AdminController controller,
    int productId, {
    Map<String, dynamic>? variant,
  }) async {
    final sku = TextEditingController(text: '${variant?['sku'] ?? ''}');
    final size = TextEditingController(text: '${variant?['size'] ?? ''}');
    final color = TextEditingController(text: '${variant?['color'] ?? ''}');
    final stock =
        TextEditingController(text: '${variant?['stock_quantity'] ?? ''}');
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _DisposeControllersOnUnmount(
        controllers: [sku, size, color, stock],
        child: _AdminFormDialog(
          title: variant == null ? 'New variant' : 'Edit variant',
          subtitle: variant == null
              ? 'Set the size, color, and inventory details.'
              : 'Update this product variant and its inventory.',
          icon: Icons.tune_outlined,
          actionLabel: variant == null ? 'Create variant' : 'Save changes',
          onCancel: () => Navigator.pop(dialogContext),
          onSubmit: () async {
            if (!(formKey.currentState?.validate() ?? false)) return;
            try {
              await controller.saveVariant(
                productId,
                {
                  'sku': sku.text.trim(),
                  'size': size.text.trim(),
                  'color': color.text.trim(),
                  'stock_quantity': int.parse(stock.text),
                },
                id: variant == null ? null : _int(variant['id']),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            } catch (_) {}
          },
          content: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _AdminTextField(
                  controller: sku,
                  label: 'SKU',
                  hint: 'Unique stock keeping unit',
                  validator: _required,
                ),
                const SizedBox(height: 18),
                _AdminTextField(
                  controller: size,
                  label: 'Size',
                  hint: 'e.g. S, M, L or 32',
                  validator: _required,
                ),
                const SizedBox(height: 18),
                _AdminTextField(
                  controller: color,
                  label: 'Color',
                  hint: 'e.g. Midnight navy',
                  validator: _required,
                ),
                const SizedBox(height: 18),
                _AdminTextField(
                  controller: stock,
                  label: 'Stock quantity',
                  hint: '0',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (value) => int.tryParse(value ?? '') == null
                      ? 'Enter a stock quantity'
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Future<void> confirmDelete(
    BuildContext context,
    String title,
    String message,
    Future<void> Function() action,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: const EdgeInsets.fromLTRB(28, 26, 28, 8),
        contentPadding: const EdgeInsets.fromLTRB(28, 0, 28, 8),
        actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 22),
        title: Text(title, style: Theme.of(context).textTheme.titleLarge),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) await action();
  }

  static String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'This field is required' : null;

  static InputDecoration _inputDecoration({
    required String label,
    String? hint,
  }) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
      );

  static Widget _imageTile({
    required Widget child,
    VoidCallback? onRemove,
  }) =>
      SizedBox(
        width: 76,
        height: 76,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
            if (onRemove != null)
              Positioned(
                top: 2,
                right: 2,
                child: IconButton.filledTonal(
                  visualDensity: VisualDensity.compact,
                  constraints:
                      const BoxConstraints.tightFor(width: 30, height: 30),
                  padding: EdgeInsets.zero,
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, size: 16),
                ),
              ),
          ],
        ),
      );

  static Widget _existingProductImage(String? imageUrl) {
    final value = imageUrl?.trim();
    if (value == null || value.isEmpty) return _productImagePlaceholder();

    return Image.network(
      ImageUrlResolver.resolve(value),
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : _productImagePlaceholder(),
      errorBuilder: (_, __, ___) => _productImagePlaceholder(),
    );
  }

  static Widget _productImagePlaceholder() => Image.asset(
        AssetResolver.fallbackProductImage,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: AppColors.canvas,
          child: Icon(Icons.checkroom_outlined),
        ),
      );

  static int _int(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
}

class _AdminFormDialog extends StatelessWidget {
  const _AdminFormDialog({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.onCancel,
    required this.onSubmit,
    required this.content,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onCancel;
  final Future<void> Function() onSubmit;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < 520;
    final maxHeight =
        size.height - MediaQuery.viewInsetsOf(context).bottom - 32;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 32,
        vertical: 16,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: maxHeight.clamp(280.0, 900.0).toDouble(),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(compact ? 20 : 28, 22, 16, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.canvas,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: AppColors.ink, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.inkMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    visualDensity: VisualDensity.compact,
                    onPressed: onCancel,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    compact ? 20 : 28, 24, compact ? 20 : 28, 24),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: content,
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  compact ? 20 : 28, 16, compact ? 20 : 28, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      onPressed: onCancel,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(11),
                        ),
                      ),
                      onPressed: onSubmit,
                      child: Text(actionLabel),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTextField extends StatelessWidget {
  const _AdminTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        minLines: minLines,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: AdminFormDialogs._inputDecoration(
          label: label,
          hint: hint,
        ),
      );
}

class _ActiveControl extends StatelessWidget {
  const _ActiveControl({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: const Text('Active'),
          subtitle: const Text('Make this available in your store'),
          value: value,
          onChanged: onChanged,
        ),
      );
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.inkMuted),
          ),
        ],
      );
}

/// Keeps controllers alive through the dialog's reverse transition and only
/// disposes them after Flutter has removed the dialog subtree.
class _DisposeControllersOnUnmount extends StatefulWidget {
  const _DisposeControllersOnUnmount({
    required this.controllers,
    required this.child,
  });

  final List<TextEditingController> controllers;
  final Widget child;

  @override
  State<_DisposeControllersOnUnmount> createState() =>
      _DisposeControllersOnUnmountState();
}

class _DisposeControllersOnUnmountState
    extends State<_DisposeControllersOnUnmount> {
  @override
  void dispose() {
    for (final controller in widget.controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
