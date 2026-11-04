import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileController extends GetxController {
  ProfileController(this._repository, this._auth);
  final ProfileRepository _repository;
  final AuthController _auth;
  final _picker = ImagePicker();
  final Rxn<UserProfile> profile = Rxn<UserProfile>();
  final RxBool isLoading = false.obs;
  final RxBool isUploading = false.obs;
  final RxDouble uploadProgress = 0.0.obs;
  final Rxn<Uint8List> pendingAvatarBytes = Rxn<Uint8List>();
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final user = _auth.user.value;
    if (user != null) {
      profile.value = UserProfile(
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        phoneCountryCode: user.phoneCountryCode,
        role: user.role,
        avatarUrl: user.avatarUrl,
      );
    }
    loadProfile();
  }

  Future<void> loadProfile() async {
    final signedInUser = _auth.user.value;
    if (signedInUser == null) return;
    isLoading.value = true;
    errorMessage.value = '';
    try {
      profile.value = await _repository.getProfile();
    } catch (_) {
      errorMessage.value = 'Unable to load your profile.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveProfile(
      {required String name,
      required String email,
      required String phone,
      required String phoneCountryCode}) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      profile.value = await _repository.updateProfile(
          name: name.trim(),
          email: email.trim(),
          phone: phone.trim().isEmpty ? null : phone.trim(),
          phoneCountryCode:
              phone.trim().isEmpty ? null : phoneCountryCode.trim());
      _auth.user.value = User(
        id: profile.value!.id,
        name: profile.value!.name,
        email: profile.value!.email,
        phone: profile.value!.phone,
        phoneCountryCode: profile.value!.phoneCountryCode,
        role: profile.value!.role,
        avatarUrl: profile.value!.avatarUrl,
      );
      try {
        await Get.find<NotificationController>().showLocal(
          'Profile updated',
          'Your account details were saved successfully.',
        );
      } catch (_) {
        // Keep the profile save successful if notification delivery fails.
      }
      Get.back(result: true);
    } catch (_) {
      errorMessage.value =
          'Unable to save your profile. Check your details and retry.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await _repository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } on DioException catch (error) {
      errorMessage.value = _passwordUpdateError(error);
      return false;
    } catch (_) {
      errorMessage.value = 'Unable to update your password. Please try again.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _passwordUpdateError(DioException error) {
    final response = error.response?.data;
    if (response is Map) {
      final errors = response['errors'];
      if (errors is Map) {
        for (final messages in errors.values) {
          if (messages is List && messages.isNotEmpty) {
            return messages.first.toString();
          }
        }
      }
      final message = response['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return 'Unable to update your password. Please try again.';
  }

  Future<void> pickAndUploadAvatar() async {
    final file = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 88, maxWidth: 1200);
    if (file == null) return;
    if (await file.length() > 2 * 1024 * 1024) {
      errorMessage.value = 'Choose an image smaller than 2 MB.';
      return;
    }
    pendingAvatarBytes.value = await file.readAsBytes();
    isUploading.value = true;
    errorMessage.value = '';
    try {
      profile.value =
          await _repository.uploadAvatar(file.path, onProgress: (sent, total) {
        if (total > 0) uploadProgress.value = sent / total;
      });
      _syncAuthUser();
      pendingAvatarBytes.value = null;
    } catch (_) {
      errorMessage.value =
          'Avatar upload failed. Use a JPG, PNG, or WebP image under 2 MB.';
    } finally {
      isUploading.value = false;
      uploadProgress.value = 0;
    }
  }

  Future<void> removeAvatar() async {
    try {
      await _repository.deleteAvatar();
      await loadProfile();
      _syncAuthUser();
      pendingAvatarBytes.value = null;
    } catch (_) {
      errorMessage.value = 'Could not remove the avatar.';
    }
  }

  Future<void> signIn() async => Get.toNamed(AppRoutes.login);

  Future<void> logout() => _auth.logout();

  void _syncAuthUser() {
    final value = profile.value;
    if (value == null) return;
    _auth.user.value = User(
      id: value.id,
      name: value.name,
      email: value.email,
      phone: value.phone,
      phoneCountryCode: value.phoneCountryCode,
      role: value.role,
      avatarUrl: value.avatarUrl,
    );
  }
}
