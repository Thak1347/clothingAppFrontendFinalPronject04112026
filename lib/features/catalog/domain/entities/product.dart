import 'product_variant.dart';

class Product {
  final int id;
  final String name;
  final String description;
  /// Price in minor currency units (for example, cents).
  final int priceMinor;
  final List<String> imageUrls;
  final String? categoryName;
  final int? categoryId;
  final List<ProductVariant> variants;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.priceMinor,
    this.imageUrls = const <String>[],
    this.categoryName,
    this.categoryId,
    required this.variants,
  });

  @Deprecated('Use priceMinor so currency arithmetic stays exact.')
  double get basePrice => price;

  double get price => priceMinor / 100;
}
