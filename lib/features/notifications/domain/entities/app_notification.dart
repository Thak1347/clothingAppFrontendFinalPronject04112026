class AppNotification {
  const AppNotification(
      {required this.title, required this.body, this.payload});
  final String title;
  final String body;
  final Map<String, dynamic>? payload;
}
