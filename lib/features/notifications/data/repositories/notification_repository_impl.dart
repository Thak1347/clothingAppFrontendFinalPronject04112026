import '../../domain/repositories/notification_repository.dart';
import '../datasources/fcm_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  NotificationRepositoryImpl(this._remote);
  final FcmDataSource _remote;
  @override
  Future<void> register(String token, String platform) =>
      _remote.register(token, platform);
  @override
  Future<void> unregister(String token) => _remote.unregister(token);
}
