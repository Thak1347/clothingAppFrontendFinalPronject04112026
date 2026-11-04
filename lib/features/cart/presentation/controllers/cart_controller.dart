import 'package:get/get.dart';

import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/entities/product_variant.dart';

class CartController extends GetxController {
  CartController(this._repository);
  final CartRepositoryImpl _repository;
  final RxList<CartItem> items = <CartItem>[].obs;
  int get totalMinor => items.fold(0, (total, item) => total + item.lineTotalMinor);

  @override
  void onInit() { super.onInit(); items.assignAll(_repository.getItems()); }

  Future<void> addProduct(Product product, {ProductVariant? variant, int quantity = 1}) async {
    if (quantity < 1 || (variant != null && quantity > variant.stock)) return;
    final key = variant == null ? 'product:${product.id}' : 'variant:${variant.id}';
    final index = items.indexWhere((item) => item.key == key);
    if (index == -1) {
      items.add(CartItem(product: product, variant: variant, quantity: quantity));
    } else {
      final current = items[index];
      final combined = current.quantity + quantity;
      final safeQuantity = variant == null ? combined : combined.clamp(1, variant.stock).toInt();
      items[index] = CartItem(product: current.product, variant: current.variant, quantity: safeQuantity);
    }
    await _persist();
  }

  Future<void> updateQuantity(String key, int quantity) async {
    final index = items.indexWhere((item) => item.key == key);
    if (index < 0) return;
    if (quantity <= 0) {
      items.removeAt(index);
    } else {
      final current = items[index];
      if (current.variant != null && current.variant!.stock < 1) {
        items.removeAt(index);
      } else {
        final safeQuantity = current.variant == null ? quantity : quantity.clamp(1, current.variant!.stock).toInt();
        items[index] = CartItem(product: current.product, variant: current.variant, quantity: safeQuantity);
      }
    }
    await _persist();
  }

  Future<void> remove(String key) async {
    items.removeWhere((item) => item.key == key);
    await _persist();
  }

  Future<void> clear() async { items.clear(); await _persist(); }

  Future<void> _persist() => _repository.save(items.toList());
}
