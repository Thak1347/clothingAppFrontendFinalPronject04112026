import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/env.dart';
import 'auth_interceptor.dart';
import '../storage/secure_storage.dart';

class DioClient {
  late final Dio dio;
  final SecureStorage _secureStorage;

  DioClient(this._secureStorage) {
    dio = Dio(
      BaseOptions(
        baseUrl: Env.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );

    dio.interceptors.add(AuthInterceptor(_secureStorage));
    // Never log request or response bodies; they can contain sensitive data.
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestHeader: false,
          requestBody: false,
          responseHeader: false,
          responseBody: false,
          error: false,
        ),
      );
    }
  }
}
