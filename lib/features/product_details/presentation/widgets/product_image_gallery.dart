import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../catalog/domain/entities/product.dart';

class ProductImageGallery extends StatefulWidget {
  const ProductImageGallery({super.key, required this.product});

  final Product product;

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late final PageController _controller;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.product.imageUrls;
    if (urls.isEmpty) {
      return AspectRatio(
        aspectRatio: .86,
        child: _localImage(),
      );
    }

    return AspectRatio(
      aspectRatio: .86,
      child: Stack(fit: StackFit.expand, children: [
        PageView.builder(
          controller: _controller,
          itemCount: urls.length,
          onPageChanged: (value) => setState(() => _index = value),
          itemBuilder: (_, index) => Image.network(
            urls[index],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _localImage(),
          ),
        ),
        if (urls.length > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                urls.length,
                (index) => Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: index == _index ? AppColors.onInk : AppColors.onInk.withValues(alpha: .55),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _localImage() => Image.asset(
        'assets/images/placeholder_product.png',
        fit: BoxFit.cover,
      );
}
