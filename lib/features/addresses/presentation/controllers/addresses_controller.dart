import 'package:get/get.dart';

import '../../domain/entities/address.dart';
import '../../domain/repositories/address_repository.dart';

class AddressesController extends GetxController {
  AddressesController(this._repository);
  final AddressRepository _repository;
  final RxList<Address> addresses = <Address>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() { super.onInit(); load(); }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';
    try { addresses.assignAll(await _repository.getAddresses()); }
    catch (_) { errorMessage.value = 'Unable to load saved addresses.'; }
    finally { isLoading.value = false; }
  }

  Future<bool> save(Address address) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      if (address.id == null) { await _repository.createAddress(address); }
      else { await _repository.updateAddress(address); }
      await load();
      return true;
    } catch (_) { errorMessage.value = 'Unable to save the address. Check the details and retry.'; return false; }
    finally { isLoading.value = false; }
  }

  Future<void> remove(int id) async {
    try { await _repository.deleteAddress(id); await load(); }
    catch (_) { errorMessage.value = 'Unable to delete this address.'; }
  }

  Future<void> makeDefault(int id) async {
    try { await _repository.setDefault(id); await load(); }
    catch (_) { errorMessage.value = 'Unable to update the default address.'; }
  }
}
