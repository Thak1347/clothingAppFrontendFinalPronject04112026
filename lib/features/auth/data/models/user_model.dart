import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.phoneCountryCode,
    super.role,
    super.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
        phoneCountryCode: json['phone_country_code'] as String?,
        role: json['role'] as String?,
        avatarUrl: json['avatar_url'] as String?,
      );
}
