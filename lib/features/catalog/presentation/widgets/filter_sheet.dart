import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../domain/entities/category.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.minPriceMinor,
    required this.maxPriceMinor,
  });

  final List<Category> categories;
  final int? selectedCategoryId;
  final int? minPriceMinor;
  final int? maxPriceMinor;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  int? _categoryId;
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.selectedCategoryId;
    _minController = TextEditingController(
      text: widget.minPriceMinor == null
          ? ''
          : (widget.minPriceMinor! / 100).toStringAsFixed(2),
    );
    _maxController = TextEditingController(
      text: widget.maxPriceMinor == null
          ? ''
          : (widget.maxPriceMinor! / 100).toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  int? _parseMinor(String value) {
    if (value.trim().isEmpty) return null;
    final amount = double.tryParse(value.trim());
    return amount == null || amount < 0 ? null : (amount * 100).round();
  }

  bool get _hasInvalidPrice =>
      (_minController.text.trim().isNotEmpty &&
          _parseMinor(_minController.text) == null) ||
      (_maxController.text.trim().isNotEmpty &&
          _parseMinor(_maxController.text) == null);

  void _apply() {
    final min = _parseMinor(_minController.text);
    final max = _parseMinor(_maxController.text);
    if (_hasInvalidPrice) {
      setState(() => _priceError = 'Enter a valid, non-negative price.');
      return;
    }
    if (min != null && max != null && min > max) {
      setState(() => _priceError = 'Minimum price must be below maximum.');
      return;
    }
    Navigator.pop(
      context,
      FilterSheetResult.apply(
        categoryId: _categoryId,
        minPriceMinor: min,
        maxPriceMinor: max,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.margin,
        AppSpacing.sm,
        AppSpacing.margin,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDim,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Refine your search',
                          style: AppTextStyles.headlineLg),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Choose a category or set a price range.',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Close filters',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.section),
            DropdownButtonFormField<int?>(
              key: ValueKey<int?>(_categoryId),
              initialValue: _categoryId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'All categories',
              ),
              items: [
                const DropdownMenuItem<int?>(
                  value: null,
                  child: Text('All categories'),
                ),
                ...widget.categories.map(
                  (category) => DropdownMenuItem<int?>(
                    value: category.id,
                    child: Text(
                      category.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _categoryId = value),
            ),
            const SizedBox(height: AppSpacing.section),
            Text('Price range', style: AppTextStyles.labelLg),
            const SizedBox(height: AppSpacing.sm),
            LayoutBuilder(
              builder: (context, constraints) {
                final gap = AppSpacing.md;
                final fieldWidth = (constraints.maxWidth - gap) / 2;
                return Wrap(
                  spacing: gap,
                  runSpacing: AppSpacing.md,
                  children: [
                    SizedBox(
                      width: fieldWidth,
                      child: TextField(
                        controller: _minController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() => _priceError = null),
                        decoration: const InputDecoration(
                          labelText: 'Minimum',
                          prefixText: '\$ ',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: fieldWidth,
                      child: TextField(
                        controller: _maxController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() => _priceError = null),
                        decoration: const InputDecoration(
                          labelText: 'Maximum',
                          prefixText: '\$ ',
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (_priceError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _priceError!,
                style: AppTextStyles.bodySm.copyWith(color: AppColors.error),
              ),
            ],
            const SizedBox(height: AppSpacing.section),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(
                    context,
                    const FilterSheetResult.clear(),
                  ),
                  child: const Text('Clear all'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _apply,
                  child: const Text('Show results'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FilterSheetResult {
  const FilterSheetResult._({
    this.categoryId,
    this.minPriceMinor,
    this.maxPriceMinor,
    this.clear = false,
  });

  const FilterSheetResult.apply({
    int? categoryId,
    int? minPriceMinor,
    int? maxPriceMinor,
  }) : this._(
          categoryId: categoryId,
          minPriceMinor: minPriceMinor,
          maxPriceMinor: maxPriceMinor,
        );

  const FilterSheetResult.clear() : this._(clear: true);

  final int? categoryId;
  final int? minPriceMinor;
  final int? maxPriceMinor;
  final bool clear;
}
