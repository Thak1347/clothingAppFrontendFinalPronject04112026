import '../../../../core/utils/image_url_resolver.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_variant.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.priceMinor,
    super.imageUrls,
    super.categoryName,
    super.categoryId,
    required super.variants,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawVariants = json['variants'];
    final rawImages = json['images'];
    final rawCategory = json['category'];
    final category = rawCategory is Map ? rawCategory : null;

    final imageUrls = rawImages is List
        ? rawImages
            .whereType<Map>()
            .map((image) => image['url'])
            .whereType<String>()
            .map(ImageUrlResolver.resolve)
            .toList()
        : <String>[];
    final imageUrl = json['image_url'];
    if (imageUrls.isEmpty && imageUrl is String && imageUrl.isNotEmpty) {
      imageUrls.add(ImageUrlResolver.resolve(imageUrl));
    }

    return ProductModel(
      id: _asInt(json['id'], field: 'id'),
      name: _asString(json['name'], field: 'name'),
      description: json['description'] as String? ?? '',
      priceMinor: _asInt(json['price_minor'], field: 'price_minor'),
      imageUrls: imageUrls,
      categoryName: category == null ? null : category['name'] as String?,
      categoryId: category == null
          ? null
          : _asInt(category['id'], field: 'category.id'),
      variants: rawVariants is List
          ? rawVariants
              .whereType<Map>()
              .map((variant) => ProductVariant.fromJson(
                    Map<String, dynamic>.from(variant),
                  ))
              .toList(growable: false)
          : const <ProductVariant>[],
    );
  }

  static int _asInt(Object? value, {required String field}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw FormatException('Product $field must be numeric.');
  }

  static String _asString(Object? value, {required String field}) {
    if (value is String) return value;
    throw FormatException('Product $field must be a string.');
  }
}
