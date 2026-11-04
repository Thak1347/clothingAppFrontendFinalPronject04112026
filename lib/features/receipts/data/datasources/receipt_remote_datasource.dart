import '../../../../core/network/dio_client.dart';

class ReceiptRemoteDataSource {
  ReceiptRemoteDataSource(this._client);

  final DioClient _client;

  Future<dynamic> getOrder(int orderId) async =>
      (await _client.dio.get('/orders/$orderId')).data;

  Future<dynamic> get(int orderId) async =>
      (await _client.dio.get('/orders/$orderId/receipt')).data;
}
