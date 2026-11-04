import 'package:dio/dio.dart';
import 'failures.dart';

class ErrorMapper {
  static Failure mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure();
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message =
            error.response?.data?['message'] ?? 'Server error occurred';

        if (statusCode == 401 || statusCode == 403) {
          return AuthFailure(message);
        }
        return ServerFailure(message);
      case DioExceptionType.connectionError:
        return const NetworkFailure();
      default:
        return const ServerFailure('Something went wrong. Please try again.');
    }
  }
}
