import '../../domain/entities/checkout_preview.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_datasource.dart';
import '../models/checkout_preview_model.dart';
import '../models/order_model.dart';
import 'package:image_picker/image_picker.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  CheckoutRepositoryImpl(this._remote);
  final CheckoutRemoteDataSource _remote;
  @override
  Future<CheckoutPreview> preview(int addressId, List<Map<String, int>> items) async => CheckoutPreviewModel.fromJson(await _remote.preview(addressId: addressId, items: items));
  @override
  Future<Order> submit(int addressId, List<Map<String, int>> items, String idempotencyKey, {String? paymentMethod, Map<String, dynamic>? cod, XFile? homePhoto}) async => OrderModel.fromJson(await _remote.submit(addressId: addressId, items: items, idempotencyKey: idempotencyKey, paymentMethod: paymentMethod, cod: cod, homePhoto: homePhoto));
}
