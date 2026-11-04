import '../../../checkout/data/models/order_model.dart';
import '../../domain/entities/order.dart';
class OrderListModel {
  static List<Order> parse(dynamic value) {
    final root = value is Map && value['data'] is List ? value['data'] as List : value is List ? value : const [];
    return root.whereType<Map>().map((item) => OrderModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }
}
