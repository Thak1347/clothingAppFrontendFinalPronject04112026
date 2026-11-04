import 'package:image_picker/image_picker.dart';
import '../entities/order.dart';
abstract interface class OrdersRepository { Future<List<Order>> getOrders(); Future<Order> getOrder(int id); Future<Order> cancelOrder(int id); Future<Order> updateCodDetails(int id, Map<String, String> details, XFile? photo); Future<Order> switchCodToAba(int id); }
