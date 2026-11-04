import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';

class CartItem {
  const CartItem({required this.product, this.variant, required this.quantity});

  final Product product;
  final ProductVariant? variant;
  final int quantity;
  int get unitPriceMinor => variant?.priceMinor ?? product.priceMinor;
  int get lineTotalMinor => unitPriceMinor * quantity;
  String get key => variant == null ? 'product:${product.id}' : 'variant:${variant!.id}';
}
