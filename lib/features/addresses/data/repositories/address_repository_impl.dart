import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';

class AddressRepositoryImpl implements AddressRepository {
  AddressRepositoryImpl(this._remote);
  final AddressRemoteDataSource _remote;
  @override Future<List<Address>> getAddresses() => _remote.getAll();
  @override Future<Address> createAddress(Address address) => _remote.create(address);
  @override Future<Address> updateAddress(Address address) => _remote.update(address);
  @override Future<void> deleteAddress(int id) => _remote.delete(id);
  @override Future<Address> setDefault(int id) => _remote.setDefault(id);
}
