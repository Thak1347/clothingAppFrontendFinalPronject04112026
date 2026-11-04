import '../entities/address.dart';

abstract class AddressRepository {
  Future<List<Address>> getAddresses();
  Future<Address> createAddress(Address address);
  Future<Address> updateAddress(Address address);
  Future<void> deleteAddress(int id);
  Future<Address> setDefault(int id);
}
