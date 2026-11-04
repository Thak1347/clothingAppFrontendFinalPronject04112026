import '../../../../core/network/dio_client.dart';

class FcmDataSource {
  FcmDataSource(this._client);
  final DioClient _client;
  Future<void> register(String token, String platform) async {
    await _client.dio
        .post('/device-tokens', data: {'token': token, 'platform': platform});
  }

  Future<void> unregister(String token) async {
    await _client.dio.delete('/device-tokens', data: {'token': token});
  }
}
