import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../../../../core/widgets/product_card.dart';
import '../controllers/catalog_controller.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/sort_dropdown.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final controller = Get.find<CatalogController>();
    _searchController = TextEditingController(
      text: controller.searchQuery.value,
    );
    final categoryId = Get.arguments;
    if (categoryId is int) controller.setCategory(categoryId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CatalogController>();

    return Scaffold(
      bottomNavigationBar: const AppBottomNavigationBar(),
      appBar: AppBar(
        title: const Text('ÉTOFFE Atelier'),
        actions: [
          IconButton(
            tooltip: 'Shopping bag',
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => Get.toNamed(AppRoutes.cart),
          ),
          IconButton(
            tooltip: 'Profile',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Get.toNamed(AppRoutes.profile),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.margin,
              AppSpacing.sm,
              AppSpacing.margin,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The collection', style: AppTextStyles.displayMdMobile),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Considered pieces for your everyday wardrobe.',
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _searchController,
                  onChanged: controller.setSearch,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search the collection',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Obx(() => controller.searchQuery.value.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            tooltip: 'Clear search',
                            onPressed: () {
                              _searchController.clear();
                              controller.setSearch('');
                            },
                            icon: const Icon(Icons.close),
                          )),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Obx(() {
                  final filterCount =
                      (controller.selectedCategoryId.value == null ? 0 : 1) +
                          (controller.minPriceMinor.value == null ? 0 : 1) +
                          (controller.maxPriceMinor.value == null ? 0 : 1);
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 400;
                      return Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () => _showFilters(context, controller),
                            icon: const Icon(Icons.tune, size: 18),
                            label: Text(
                              filterCount == 0
                                  ? 'Filter'
                                  : 'Filter ($filterCount)',
                            ),
                          ),
                          const Spacer(),
                          if (!compact) ...[
                            Text(
                              'Sort by',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.inkMuted,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                          ],
                          SizedBox(
                            width: compact ? 148 : 200,
                            child: SortDropdown(
                              value: controller.sort.value,
                              onChanged: controller.setSort,
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const LoadingView();
              if (controller.errorMessage.value.isNotEmpty) {
                return ErrorView(
                  message: controller.errorMessage.value,
                  onRetry: controller.fetchProducts,
                );
              }

              final products = controller.visibleProducts;
              if (products.isEmpty) {
                return EmptyView(
                  message: controller.products.isEmpty
                      ? 'No pieces are available right now.'
                      : 'No pieces match your search or filters.',
                  actionLabel: controller.products.isEmpty
                      ? null
                      : 'Clear search and filters',
                  onAction: controller.products.isEmpty
                      ? null
                      : () {
                          _searchController.clear();
                          controller.setSearch('');
                          controller.clearFilters();
                        },
                );
              }

              return CustomScrollView(
                key: const PageStorageKey<String>('catalog-products'),
                slivers: [
                  if (controller.categories.isNotEmpty)
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: 52,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.margin,
                          ),
                          scrollDirection: Axis.horizontal,
                          children: [
                            Obx(() => Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.sm,
                                  ),
                                  child: _CategoryChip(
                                    label: 'All',
                                    selected:
                                        controller.selectedCategoryId.value ==
                                            null,
                                    onSelected: () =>
                                        controller.setCategory(null),
                                  ),
                                )),
                            ...controller.categories.map(
                              (category) => Obx(() => Padding(
                                    padding: const EdgeInsets.only(
                                      right: AppSpacing.sm,
                                    ),
                                    child: _CategoryChip(
                                      label: category.name,
                                      selected:
                                          controller.selectedCategoryId.value ==
                                              category.id,
                                      onSelected: () =>
                                          controller.setCategory(category.id),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.margin,
                        AppSpacing.md,
                        AppSpacing.margin,
                        AppSpacing.xs,
                      ),
                      child: Text(
                        '${products.length} ${products.length == 1 ? 'piece' : 'pieces'}',
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                  ),
                  SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final availableWidth = constraints.crossAxisExtent;
                      final columns = availableWidth >= 1100
                          ? 4
                          : availableWidth >= 720
                              ? 3
                              : 2;
                      final cellWidth = (availableWidth -
                              AppSpacing.margin * 2 -
                              AppSpacing.gutter * (columns - 1)) /
                          columns;
                      return SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.margin,
                          AppSpacing.sm,
                          AppSpacing.margin,
                          AppSpacing.xl,
                        ),
                        sliver: SliverGrid.builder(
                          itemCount: products.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: AppSpacing.gutter,
                            mainAxisSpacing: AppSpacing.lg,
                            childAspectRatio: cellWidth / (cellWidth * 1.58),
                          ),
                          itemBuilder: (_, index) => ProductCard(
                            product: products[index],
                            onTap: () => Get.toNamed(
                              AppRoutes.productDetails,
                              arguments: products[index].id,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilters(
    BuildContext context,
    CatalogController controller,
  ) async {
    final result = await showModalBottomSheet<FilterSheetResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusLg),
        ),
      ),
      builder: (_) => FilterSheet(
        categories: controller.categories,
        selectedCategoryId: controller.selectedCategoryId.value,
        minPriceMinor: controller.minPriceMinor.value,
        maxPriceMinor: controller.maxPriceMinor.value,
      ),
    );
    if (result == null) return;
    if (result.clear) {
      controller.clearFilters();
    } else {
      controller.setCategory(result.categoryId);
      controller.setPriceRange(result.minPriceMinor, result.maxPriceMinor);
    }
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) => ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
        selectedColor: AppColors.ink,
        backgroundColor: AppColors.surfaceWhite,
        side: BorderSide(
          color: selected ? AppColors.ink : AppColors.border,
        ),
        labelStyle: AppTextStyles.bodySm.copyWith(
          color: selected ? AppColors.onInk : AppColors.ink,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      );
}
