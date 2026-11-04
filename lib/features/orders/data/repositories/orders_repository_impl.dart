import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';
import '../models/order_list_model.dart';
import '../../../checkout/data/models/order_model.dart';
import 'package:image_picker/image_picker.dart';
class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._remote); final OrdersRemoteDataSource _remote;
  @override Future<List<Order>> getOrders() async => OrderListModel.parse(await _remote.list());
  @override Future<Order> getOrder(int id) async {
    final value = await _remote.detail(id);
    return OrderModel.fromJson(value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{});
  }
  @override Future<Order> cancelOrder(int id) async => OrderModel.fromJson(await _remote.cancel(id));
  @override Future<Order> updateCodDetails(int id, Map<String, String> details, XFile? photo) async => OrderModel.fromJson(await _remote.updateCodDetails(id, details, photo));
  @override Future<Order> switchCodToAba(int id) async => OrderModel.fromJson(await _remote.switchCodToAba(id));
}
