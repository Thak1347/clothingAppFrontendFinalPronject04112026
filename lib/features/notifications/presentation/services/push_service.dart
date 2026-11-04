import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/notification_repository.dart';
import 'local_notification_service.dart';

class PushService {
  PushService(this._repository, this._local);

  final NotificationRepository _repository;
  final LocalNotificationService _local;
  final StreamController<String> _errors = StreamController<String>.broadcast();
  StreamSubscription<String>? _tokenSub;
  StreamSubscription<RemoteMessage>? _messageSub;
  String? _registeredToken;
  bool _starting = false;
  final Map<String, DateTime> _recentLocalMessages = {};

  Stream<String> get errors => _errors.stream;

  Future<void> start() async {
    if (_starting || kIsWeb || !_supportsPush) return;
    _starting = true;
    try {
      try {
        await _local.initialize();
      } catch (error, stackTrace) {
        _reportError(
            'Could not initialize local notifications', error, stackTrace);
      }
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      final token = await messaging.getToken();
      if (token != null) await _register(token);

      _tokenSub ??= messaging.onTokenRefresh.listen(
        (value) => unawaited(_register(value)),
        onError: (Object error, StackTrace stackTrace) {
          _reportError('Could not refresh the push notification token', error,
              stackTrace);
        },
      );
      _messageSub ??= FirebaseMessaging.onMessage.listen((message) {
        final title = message.notification?.title ?? 'Store update';
        final body = message.notification?.body ?? '';
        if (body.isNotEmpty && !_wasShownRecently(title, body)) {
          unawaited(_showForegroundMessage(title, body));
        }
      });
    } catch (error, stackTrace) {
      _reportError('Could not start push notifications', error, stackTrace);
    } finally {
      _starting = false;
    }
  }

  Future<void> showLocal(String title, String body) async {
    final key = _messageKey(title, body);
    if (_wasShownRecently(title, body)) return;
    _recentLocalMessages[key] = DateTime.now();
    _recentLocalMessages.removeWhere(
      (_, at) => DateTime.now().difference(at) > const Duration(seconds: 20),
    );
    try {
      await _local.show(title, body);
    } catch (_) {
      _recentLocalMessages.remove(key);
      rethrow;
    }
  }

  Future<void> stop() async {
    final token = _registeredToken;
    if (token != null) {
      try {
        await _repository.unregister(token);
      } catch (error, stackTrace) {
        _reportError('Could not unregister the push notification token', error,
            stackTrace);
      }
    }
    _registeredToken = null;
    await _tokenSub?.cancel();
    await _messageSub?.cancel();
    _tokenSub = null;
    _messageSub = null;
  }

  bool get _supportsPush =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> _register(String token) async {
    final platform =
        defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android';
    try {
      await _repository.register(token, platform);
      _registeredToken = token;
    } catch (error, stackTrace) {
      _reportError(
          'Could not register the push notification token', error, stackTrace);
    }
  }

  Future<void> _showForegroundMessage(String title, String body) async {
    try {
      await showLocal(title, body);
    } catch (error, stackTrace) {
      _reportError('Could not display a push notification', error, stackTrace);
    }
  }

  void _reportError(String context, Object error, StackTrace stackTrace) {
    debugPrint('$context: $error\n$stackTrace');
    _errors.add(context);
  }

  bool _wasShownRecently(String title, String body) {
    final at = _recentLocalMessages[_messageKey(title, body)];
    if (at == null) return false;
    if (DateTime.now().difference(at) > const Duration(seconds: 20)) {
      _recentLocalMessages.remove(_messageKey(title, body));
      return false;
    }
    return true;
  }

  String _messageKey(String title, String body) => '$title\n$body';
}
