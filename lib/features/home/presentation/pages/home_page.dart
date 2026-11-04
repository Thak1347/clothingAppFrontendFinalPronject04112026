import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_bottom_navigation_bar.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/loading_view.dart';
import '../controllers/home_controller.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/category_chips.dart';
import '../widgets/new_arrivals_section.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.canvas,
        bottomNavigationBar: const AppBottomNavigationBar(),
        appBar: AppBar(
          title: Text('ÉTOFFE Atelier', style: AppTextStyles.headlineSm),
          actions: [
            IconButton(
              tooltip: 'Shopping bag',
              onPressed: () => Get.toNamed(AppRoutes.cart),
              icon: const Icon(Icons.shopping_bag_outlined),
            ),
            IconButton(
              tooltip: 'Profile',
              onPressed: () => Get.toNamed(AppRoutes.profile),
              icon: const Icon(Icons.person_outline),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingView();
          }
          if (controller.errorMessage.value.isNotEmpty &&
              controller.newArrivals.isEmpty) {
            return ErrorView(
              message: controller.errorMessage.value,
              onRetry: controller.loadHome,
            );
          }
          return RefreshIndicator(
            onRefresh: controller.loadHome,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(
                top: AppSpacing.md,
                bottom: AppSpacing.xxl,
              ),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
                  child: BannerCarousel(
                    onShopNow: () => Get.toNamed(AppRoutes.catalog),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SHOP BY CATEGORY',
                          style: AppTextStyles.labelSm
                              .copyWith(color: AppColors.inkMuted)),
                      const SizedBox(height: AppSpacing.md),
                      CategoryChips(
                        categories: controller.categories,
                        onTap: (category) => Get.toNamed(
                          AppRoutes.catalog,
                          arguments: category.id,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      NewArrivalsSection(
                        products: controller.newArrivals,
                        onProductTap: (product) => Get.toNamed(
                          AppRoutes.productDetails,
                          arguments: product.id,
                        ),
                        onViewAll: () => Get.toNamed(AppRoutes.catalog),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.section),
                // Container(
                //   margin:
                //       const EdgeInsets.symmetric(horizontal: AppSpacing.margin),
                //   padding: const EdgeInsets.all(AppSpacing.lg),
                //   decoration: BoxDecoration(
                //     color: AppColors.surfaceWhite,
                //     border: Border.all(color: AppColors.border),
                //     borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                //   ),
                //   // child: Row(children: [
                //   //   const Icon(Icons.eco_outlined, color: AppColors.inkMuted),
                //   //   const SizedBox(width: AppSpacing.md),
                //   //   Expanded(
                //   //     child: Column(
                //   //       crossAxisAlignment: CrossAxisAlignment.start,
                //   //       children: [
                //   //         Text('Considered by design',
                //   //             style: AppTextStyles.headlineSm
                //   //                 .copyWith(color: AppColors.ink)),
                //   //         const SizedBox(height: AppSpacing.xs),
                //   //         Text(
                //   //             'Fewer, better pieces for a wardrobe that feels like yours.',
                //   //             style: AppTextStyles.bodySm
                //   //                 .copyWith(color: AppColors.inkMuted)),
                //   //       ],
                //   //     ),
                //   //   ),
                //   // ]),
                // ),
              ],
            ),
          );
        }),
      );
}
