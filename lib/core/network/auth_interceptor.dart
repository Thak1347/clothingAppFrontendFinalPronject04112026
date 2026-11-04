import 'package:dio/dio.dart';
import '../storage/secure_storage.dart';
import '../constants/storage_keys.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.read(StorageKeys.authToken);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Ensure we accept JSON
    options.headers['Accept'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Do not reuse an expired or invalid session on subsequent requests.
    if (err.response?.statusCode == 401) {
      _secureStorage.delete(StorageKeys.authToken).catchError((Object _) {});
    }
    return handler.next(err);
  }
}
