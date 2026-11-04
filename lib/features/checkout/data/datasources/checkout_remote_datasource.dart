import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/dio_client.dart';

class CheckoutRemoteDataSource {
  CheckoutRemoteDataSource(this._client);
  final DioClient _client;

  Future<Map<String, dynamic>> preview({required int addressId, required List<Map<String, int>> items}) async {
    final response = await _client.dio.post('/checkout/preview', data: {'address_id': addressId, 'items': items});
    return _map(response.data);
  }

  Future<Map<String, dynamic>> submit({required int addressId, required List<Map<String, int>> items, required String idempotencyKey, String? paymentMethod, Map<String, dynamic>? cod, XFile? homePhoto}) async {
    final data = <String, dynamic>{'address_id': addressId, 'items': items, 'idempotency_key': idempotencyKey, if (paymentMethod != null) 'payment_method': paymentMethod, if (cod != null) 'cod': Map<String, dynamic>.from(cod)};
    if (homePhoto != null) {
      final codFields = Map<String, dynamic>.from(data['cod'] as Map);
      codFields['home_photo'] = await MultipartFile.fromFile(homePhoto.path, filename: homePhoto.name);
      data['cod'] = codFields;
    }
    final response = await _client.dio.post('/orders', data: homePhoto == null ? data : FormData.fromMap(data), options: Options(headers: {'Idempotency-Key': idempotencyKey}));
    return _map(response.data);
  }
}

Map<String, dynamic> _map(dynamic value) => value is Map<String, dynamic> ? value : value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
