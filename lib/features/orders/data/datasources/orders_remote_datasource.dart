import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/dio_client.dart';

class OrdersRemoteDataSource {
  OrdersRemoteDataSource(this._client);
  final DioClient _client;
  Future<dynamic> list() async => (await _client.dio.get('/orders')).data;
  Future<dynamic> detail(int id) async => (await _client.dio.get('/orders/$id')).data;
  Future<dynamic> cancel(int id) async => (await _client.dio.post('/orders/$id/cancel')).data;
  Future<dynamic> updateCodDetails(int id, Map<String, String> details, XFile? photo) async {
    final fields = <String, dynamic>{...details};
    if (photo != null) fields['home_photo'] = await MultipartFile.fromFile(photo.path, filename: photo.name);
    return (await _client.dio.post('/orders/$id/cod-details', data: FormData.fromMap(fields))).data;
  }
  Future<dynamic> switchCodToAba(int id) async => (await _client.dio.post('/orders/$id/switch-to-aba')).data;
}
