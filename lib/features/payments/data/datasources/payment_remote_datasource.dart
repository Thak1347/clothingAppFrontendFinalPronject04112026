import '../../../../core/network/dio_client.dart';

class PaymentRemoteDataSource {
  PaymentRemoteDataSource(this._client);
  final DioClient _client;
  Future<dynamic> initiate(int id, String provider) async => (await _client.dio
          .post('/payments/$id/initiate', data: {'provider': provider}))
      .data;
  Future<dynamic> order(int id) async =>
      (await _client.dio.get('/orders/$id')).data;
  Future<dynamic> paymentStatus(int id) async =>
      (await _client.dio.get('/orders/$id/payment-status')).data;
}
