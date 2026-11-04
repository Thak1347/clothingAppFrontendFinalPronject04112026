import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);
  final AuthRemoteDataSource _remote;

  @override
  Future<User> login({required String email, required String password}) =>
      _remote.login(email, password);

  @override
  Future<User> register({
    required String name,
    required String email,
    String? phone,
    String? phoneCountryCode,
    required String password,
    required String passwordConfirmation,
  }) =>
      _remote.register(
        name,
        email,
        phone,
        phoneCountryCode,
        password,
        passwordConfirmation,
      );

  @override
  Future<User> getProfile() => _remote.getProfile();

  @override
  Future<void> logout() => _remote.logout();
}
