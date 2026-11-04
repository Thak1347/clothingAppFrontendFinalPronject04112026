class ProductVariant {
  final int id;
  final String size;
  final String color;
  final int stock;
  /// Price in minor units. Laravel currently returns the product price here.
  final int priceMinor;

  const ProductVariant({
    required this.id,
    required this.size,
    required this.color,
    required this.stock,
    required this.priceMinor,
  });

  double get price => priceMinor / 100;

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: _toInt(json['id'], 'id'),
      size: json['size'] as String? ?? '',
      color: json['color'] as String? ?? '',
      stock: _toInt(json['stock_quantity'], 'stock_quantity'),
      priceMinor: _toInt(json['price_minor'], 'price_minor'),
    );
  }

  static int _toInt(Object? value, String field) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    throw FormatException('Variant $field must be numeric.');
  }
}
