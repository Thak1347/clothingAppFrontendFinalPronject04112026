import '../entities/checkout_preview.dart';
import '../entities/order.dart';
import 'package:image_picker/image_picker.dart';

abstract interface class CheckoutRepository {
  Future<CheckoutPreview> preview(int addressId, List<Map<String, int>> items);
  Future<Order> submit(int addressId, List<Map<String, int>> items, String idempotencyKey, {String? paymentMethod, Map<String, dynamic>? cod, XFile? homePhoto});
}
