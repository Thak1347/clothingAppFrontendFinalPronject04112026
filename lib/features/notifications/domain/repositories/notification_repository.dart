abstract interface class NotificationRepository {
  Future<void> register(String token, String platform);
  Future<void> unregister(String token);
}
