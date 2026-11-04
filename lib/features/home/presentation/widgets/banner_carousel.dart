import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.onShopNow});

  final VoidCallback onShopNow;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _pageController = PageController(viewportFraction: .91);
  int _page = 0;

  static const _slides = [
    (
      eyebrow: 'THE NEW SEASON',
      title: 'A softer\npoint of view.',
      subtitle: 'Thoughtful pieces for everyday rituals.',
      colors: [AppColors.surfaceDim, AppColors.canvas],
    ),
    (
      eyebrow: 'MADE TO LAST',
      title: 'Wear what\nfeels like you.',
      subtitle: 'Discover considered wardrobe essentials.',
      colors: [AppColors.terracotta, AppColors.surfaceDim],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(children: [
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _slides.length,
            onPageChanged: (value) => setState(() => _page = value),
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: slide.colors,
                    ),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Stack(children: [
                    Positioned(
                      right: 8,
                      top: 14,
                      child: Icon(Icons.checkroom_outlined,
                          size: 112,
                          color: Colors.white.withValues(alpha: .35)),
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(slide.eyebrow,
                              style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.ink.withValues(alpha: .75))),
                          const SizedBox(height: 8),
                          Text(slide.title,
                              style: AppTextStyles.displayMdMobile
                                  .copyWith(height: 1.12)),
                          const SizedBox(height: 8),
                          Text(slide.subtitle, style: AppTextStyles.bodySm),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: widget.onShopNow,
                            icon: const Icon(Icons.arrow_forward, size: 16),
                            label: const Text('Shop collection'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.ink,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _slides.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _page == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _page == index ? AppColors.ink : AppColors.surfaceDim,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ]);
}
