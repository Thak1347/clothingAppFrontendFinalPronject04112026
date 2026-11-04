import 'dart:convert';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/prefs_storage.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';
import '../../domain/entities/cart_item.dart';

class CartLocalDataSource {
  CartLocalDataSource(this._storage);
  final PrefsStorage _storage;

  List<CartItem> read() {
    final encoded = _storage.getString(StorageKeys.cart);
    if (encoded == null) return const [];
    try {
      final rows = jsonDecode(encoded) as List;
      return rows.map((raw) {
        final row = Map<String, dynamic>.from(raw as Map);
        final product = ProductModel.fromJson(Map<String, dynamic>.from(row['product'] as Map));
        final rawVariant = row['variant'];
        final variant = rawVariant == null
            ? null
            : ProductVariant.fromJson(Map<String, dynamic>.from(rawVariant as Map));
        return CartItem(product: product, variant: variant, quantity: (row['quantity'] as num).toInt());
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> write(List<CartItem> items) async {
    final rows = items.map((item) => {
          'product': _productJson(item.product),
          'variant': item.variant == null ? null : _variantJson(item.variant!),
          'quantity': item.quantity,
        }).toList();
    await _storage.setString(StorageKeys.cart, jsonEncode(rows));
  }

  Map<String, dynamic> _productJson(Product product) => {
        'id': product.id,
        'name': product.name,
        'description': product.description,
        'price_minor': product.priceMinor,
        'image_url': product.imageUrls.isEmpty ? null : product.imageUrls.first,
        'images': product.imageUrls.map((url) => {'url': url}).toList(),
        'category': product.categoryId == null && product.categoryName == null
            ? null
            : {'id': product.categoryId ?? 0, 'name': product.categoryName ?? ''},
        'variants': product.variants.map(_variantJson).toList(),
      };

  Map<String, dynamic> _variantJson(ProductVariant variant) => {
        'id': variant.id,
        'size': variant.size,
        'color': variant.color,
        'stock_quantity': variant.stock,
        'price_minor': variant.priceMinor,
      };
}
