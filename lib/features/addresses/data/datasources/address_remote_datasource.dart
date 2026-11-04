import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/address.dart';
import '../models/address_model.dart';

class AddressRemoteDataSource {
  AddressRemoteDataSource(this._client);
  final DioClient _client;

  List<AddressModel> _list(Object? response) {
    final body = Map<String, dynamic>.from(response as Map);
    final data = body['data'];
    if (data is! List) throw const FormatException('Invalid addresses response.');
    return data.whereType<Map>().map((item) => AddressModel.fromJson(Map<String, dynamic>.from(item))).toList();
  }

  AddressModel _item(Object? response) {
    final body = Map<String, dynamic>.from(response as Map);
    return AddressModel.fromJson(Map<String, dynamic>.from(body['data'] ?? body));
  }

  Future<List<AddressModel>> getAll() async => _list((await _client.dio.get(ApiEndpoints.addresses)).data);
  Future<AddressModel> create(Address address) async => _item((await _client.dio.post(ApiEndpoints.addresses, data: _toMap(address))).data);
  Future<AddressModel> update(Address address) async => _item((await _client.dio.put(ApiEndpoints.address(address.id!), data: _toMap(address))).data);
  Future<void> delete(int id) async { await _client.dio.delete(ApiEndpoints.address(id)); }
  Future<AddressModel> setDefault(int id) async => _item((await _client.dio.post(ApiEndpoints.setDefaultAddress(id))).data);

  Map<String, dynamic> _toMap(Address address) => AddressModel(
        id: address.id, label: address.label, recipientName: address.recipientName,
        phone: address.phone, addressLine: address.addressLine,
        province: address.province, isDefault: address.isDefault,
      ).toJson();
}
