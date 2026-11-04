
import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../addresses/presentation/controllers/addresses_controller.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';

class AuthController extends GetxController {
  AuthController(this._repository, this._dioClient, this._secureStorage);

  final AuthRepository _repository;
  final DioClient _dioClient;
  final SecureStorage _secureStorage;
  final Rxn<User> user = Rxn<User>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isGuest = true.obs;

  @override
  void onInit() {
    super.onInit();
    _restoreIfTokenExists();
  }

  Future<void> _restoreIfTokenExists() async {
    try {
      final token = await _secureStorage.read(StorageKeys.authToken);
      if (token != null && token.isNotEmpty) await restoreSession();
    } catch (_) {
      user.value = null;
      isGuest.value = true;
    }
  }

  Future<void> login(String email, String password) => _run(() async {
        user.value = await _repository.login(email: email.trim(), password: password);
        isGuest.value = false;
        await _startNotifications();
        await _notifyLocal(
          'Login successful',
          'Welcome back, ${user.value?.name ?? 'to Etoffe'}!',
        );
        if (Get.isRegistered<AddressesController>()) Get.find<AddressesController>().load();
        Get.offAllNamed(_landingRouteFor(user.value?.role));
      });

  Future<void> register({
    required String name,
    required String email,
    String? phone,
    String? phoneCountryCode,
    required String password,
    required String passwordConfirmation,
  }) =>
      _run(() async {
        user.value = await _repository.register(
          name: name.trim(),
          email: email.trim(),
          phone: phone?.trim(),
          phoneCountryCode: phoneCountryCode,
          password: password, passwordConfirmation: passwordConfirmation,
        );
        isGuest.value = false;
        await _startNotifications();
        await _notifyLocal(
          'Registration successful',
          'Welcome to Etoffe, ${user.value?.name ?? ''}!'.trim(),
        );
        if (Get.isRegistered<AddressesController>()) Get.find<AddressesController>().load();
        Get.offAllNamed(AppRoutes.home);
      });

  Future<void> restoreSession() async {
    try {
      user.value = await _repository.getProfile();
      isGuest.value = false;
      await _startNotifications();
    } catch (_) {
      user.value = null;
      isGuest.value = true;
    }
  }

  String _landingRouteFor(String? role) =>
      role == 'admin' ? AppRoutes.admin : AppRoutes.home;

  Future<void> logout() async {
    try {
      if (Get.isRegistered<NotificationController>()) {
        await Get.find<NotificationController>().stop();
      }
      await _repository.logout();
    } finally {
      await _secureStorage.delete(StorageKeys.userProfile);
      _dioClient.dio.options.headers.remove('Authorization');
      user.value = null;
      isGuest.value = true;
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> _startNotifications() async {
    if (Get.isRegistered<NotificationController>()) {
      await Get.find<NotificationController>().start();
    }
  }

  Future<void> _notifyLocal(String title, String body) async {
    try {
      await Get.find<NotificationController>().showLocal(title, body);
    } catch (_) {
      // Local notifications must not undo a successful authentication.
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await action();
    } catch (error) {
      errorMessage.value = error is DioException
          ? ErrorMapper.mapDioError(error).message
          : 'Something went wrong. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
}
