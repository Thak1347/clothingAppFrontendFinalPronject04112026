import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile> getProfile();
  Future<UserProfile> updateProfile(
      {required String name,
      required String email,
      String? phone,
      String? phoneCountryCode});
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<UserProfile> uploadAvatar(String path,
      {required void Function(int, int) onProgress});
  Future<void> deleteAvatar();
}
