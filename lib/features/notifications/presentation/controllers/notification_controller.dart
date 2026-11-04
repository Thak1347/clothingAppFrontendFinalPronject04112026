import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../services/push_service.dart';

class NotificationController extends GetxController {
  NotificationController(this._service);

  final PushService _service;

  final RxBool isCheckingPermission = false.obs;
  final RxString permissionStatus = 'unknown'.obs;
  final RxString errorMessage = ''.obs;
  StreamSubscription<String>? _errorSubscription;

  @override
  void onInit() {
    super.onInit();
    _errorSubscription = _service.errors.listen((_) {
      errorMessage.value =
          'Push notifications could not be set up. Please try again or check your device settings.';
    });
    refreshPermissionStatus();
  }

  Future<void> start() async {
    errorMessage.value = '';
    await _service.start();
  }

  Future<void> stop() => _service.stop();

  Future<void> enableNotifications() async {
    isCheckingPermission.value = true;
    errorMessage.value = '';
    try {
      await _service.start();
      await refreshPermissionStatus();
    } finally {
      isCheckingPermission.value = false;
    }
  }

  Future<void> refreshPermissionStatus() async {
    isCheckingPermission.value = true;
    try {
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      permissionStatus.value = switch (settings.authorizationStatus) {
        AuthorizationStatus.authorized => 'enabled',
        AuthorizationStatus.provisional => 'provisional',
        AuthorizationStatus.denied => 'denied',
        AuthorizationStatus.notDetermined => 'not_requested',
      };
    } catch (error, stackTrace) {
      debugPrint(
          'Could not check notification permissions: $error\n$stackTrace');
      permissionStatus.value = 'unavailable';
      errorMessage.value =
          'Could not check notification access. Please try again.';
    } finally {
      isCheckingPermission.value = false;
    }
  }

  @override
  void onClose() {
    unawaited(_errorSubscription?.cancel());
    super.onClose();
  }

  Future<void> showLocal(String title, String body) =>
      _service.showLocal(title, body);
}
