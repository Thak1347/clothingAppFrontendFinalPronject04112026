import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(
    String name,
    String email,
    String? phone,
    String? phoneCountryCode,
    String password,
    String passwordConfirmation,
  );
  Future<UserModel> getProfile();
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client, this._storage);

  final DioClient _client;
  final SecureStorage _storage;

  Map<String, dynamic> _map(Object? value) =>
      Map<String, dynamic>.from(value as Map);

  Future<UserModel> _authenticate(String path, Map<String, dynamic> body) async {
    final response = await _client.dio.post(path, data: body);
    final data = _map(response.data);
    await _storage.write(StorageKeys.authToken, data['token'] as String);
    return UserModel.fromJson(_map(data['user']));
  }

  @override
  Future<UserModel> login(String email, String password) => _authenticate(
        ApiEndpoints.login,
        {'email': email, 'password': password},
      );

  @override
  Future<UserModel> register(
    String name,
    String email,
    String? phone,
    String? phoneCountryCode,
    String password,
    String passwordConfirmation,
  ) =>
      _authenticate(ApiEndpoints.register, {
        'name': name,
        'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (phone != null && phone.isNotEmpty && phoneCountryCode != null)
          'phone_country_code': phoneCountryCode,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

  @override
  Future<UserModel> getProfile() async {
    final response = await _client.dio.get(ApiEndpoints.me);
    final body = _map(response.data);
    return UserModel.fromJson(_map(body['data'] ?? body));
  }

  @override
  Future<void> logout() async {
    try {
      await _client.dio.post(ApiEndpoints.logout);
    } finally {
      await _storage.delete(StorageKeys.authToken);
    }
  }
}
