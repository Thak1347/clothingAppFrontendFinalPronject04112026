import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel(
      {required super.id,
      required super.name,
      required super.email,
      super.phone,
      super.phoneCountryCode,
      super.role,
      super.avatarUrl,
      super.createdAt});

  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        id: (json['id'] as num).toInt(),
        name: json['name'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String?,
        phoneCountryCode: json['phone_country_code'] as String?,
        role: json['role'] as String?,
        avatarUrl: json['avatar_url'] as String?,
        createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
      );
}
