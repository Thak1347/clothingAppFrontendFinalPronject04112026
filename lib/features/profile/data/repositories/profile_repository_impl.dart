import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._remote);
  final ProfileRemoteDataSource _remote;

  @override
  Future<UserProfile> getProfile() => _remote.getProfile();

  @override
  Future<UserProfile> updateProfile({
    required String name,
    required String email,
    String? phone,
    String? phoneCountryCode,
  }) =>
      _remote.updateProfile({
        'name': name,
        'email': email,
        'phone': phone,
        'phone_country_code': phoneCountryCode,
      });

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _remote.updatePassword({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      });

  @override
  Future<UserProfile> uploadAvatar(String path,
          {required void Function(int, int) onProgress}) =>
      _remote.uploadAvatar(path, onProgress);

  @override
  Future<void> deleteAvatar() => _remote.deleteAvatar();
}
