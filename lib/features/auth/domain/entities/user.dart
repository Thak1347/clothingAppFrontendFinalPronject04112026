class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? phoneCountryCode;
  final String? role;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.phoneCountryCode,
    this.role,
    this.avatarUrl,
  });
}
