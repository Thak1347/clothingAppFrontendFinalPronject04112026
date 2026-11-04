import 'package:dio/dio.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data);
  Future<void> updatePassword(Map<String, dynamic> data);
  Future<UserProfileModel> uploadAvatar(
      String path, void Function(int, int) onProgress);
  Future<void> deleteAvatar();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._client);
  final DioClient _client;

  Map<String, dynamic> _data(Object? response) {
    final map = Map<String, dynamic>.from(response as Map);
    return Map<String, dynamic>.from(map['data'] ?? map);
  }

  @override
  Future<UserProfileModel> getProfile() async => UserProfileModel.fromJson(
        _data((await _client.dio.get(ApiEndpoints.me)).data),
      );

  @override
  Future<UserProfileModel> updateProfile(Map<String, dynamic> data) async =>
      UserProfileModel.fromJson(
        _data((await _client.dio.patch(ApiEndpoints.me, data: data)).data),
      );

  @override
  Future<void> updatePassword(Map<String, dynamic> data) async {
    await _client.dio.patch(ApiEndpoints.updatePassword, data: data);
  }

  @override
  Future<UserProfileModel> uploadAvatar(
      String path, void Function(int, int) onProgress) async {
    final form =
        FormData.fromMap({'avatar': await MultipartFile.fromFile(path)});
    final response = await _client.dio.post(
      ApiEndpoints.avatar,
      data: form,
      onSendProgress: onProgress,
      options: Options(contentType: 'multipart/form-data'),
    );
    return UserProfileModel.fromJson(_data(response.data));
  }

  @override
  Future<void> deleteAvatar() async {
    await _client.dio.delete(ApiEndpoints.avatar);
  }
}
