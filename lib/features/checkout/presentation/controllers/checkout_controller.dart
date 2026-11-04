import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';
import '../../../addresses/domain/entities/address.dart';
import '../../../addresses/presentation/controllers/addresses_controller.dart';
import '../../../cart/presentation/controllers/cart_controller.dart';
import '../../domain/entities/checkout_preview.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/checkout_repository.dart';

class CheckoutController extends GetxController {
  CheckoutController(this._repository, this._cart, this._addresses);
  final CheckoutRepository _repository;
  final CartController _cart;
  final AddressesController _addresses;
  final Rxn<CheckoutPreview> preview = Rxn<CheckoutPreview>();
  final Rxn<Address> selectedAddress = Rxn<Address>();
  final RxBool isLoading = false.obs, isSubmitting = false.obs;
  final RxString error = ''.obs;
  String? _pendingKey;
  String? _pendingFingerprint;
  final paymentMethod = 'aba_pay'.obs;
  final codFormKey = GlobalKey<FormState>();
  final codName = ''.obs, codPhone = ''.obs, codEmail = ''.obs, codTelegram = ''.obs, codAddress = ''.obs;
  final Rxn<XFile> codHomePhoto = Rxn<XFile>();
  final codPolicyAccepted = false.obs;
  @override
  void onInit() { super.onInit(); reloadAddresses(); }
  Future<void> reloadAddresses() async {
    final selectedId = selectedAddress.value?.id;
    await _addresses.load();
    // The repository returns fresh model instances after each load. Rebind by
    // stable database ID so dropdown selection never points at an old object.
    selectedAddress.value = _addresses.addresses.firstWhereOrNull(
          (address) => address.id == selectedId,
        ) ??
        _addresses.addresses.firstWhereOrNull((address) => address.isDefault) ??
        _addresses.addresses.firstOrNull;
    await refreshPreview();
  }

  void selectAddress(Address address) {
    selectedAddress.value = _addresses.addresses.firstWhereOrNull(
          (item) => item.id == address.id,
        ) ??
        address;
    refreshPreview();
  }
  Future<void> refreshPreview() async {
    final address = selectedAddress.value;
    if (address?.id == null || _cart.items.isEmpty) { preview.value = null; return; }
    if (_cart.items.any((item) => item.variant == null)) { preview.value = null; error.value = 'Select a size and color for each item before checkout.'; return; }
    isLoading.value = true; error.value = '';
    try { preview.value = await _repository.preview(address!.id!, _requestItems()); }
    catch (_) { error.value = 'Unable to calculate checkout. Please retry.'; }
    finally { isLoading.value = false; }
  }
  Future<Order?> submit() async {
    final address = selectedAddress.value;
    if (address?.id == null || preview.value == null || isSubmitting.value || _cart.items.isEmpty) return null;
    isSubmitting.value = true; error.value = '';
    try {
      final fingerprint = '${address!.id}:${_requestItems().map((item) => '${item['product_variant_id']}:${item['quantity']}').join(',')}';
      if (_pendingFingerprint != fingerprint || _pendingKey == null) {
        _pendingFingerprint = fingerprint;
        _pendingKey = 'mobile-${DateTime.now().microsecondsSinceEpoch}-${Random.secure().nextInt(1 << 32)}';
      }
      final order = await _repository.submit(address.id!, _requestItems(), _pendingKey!, paymentMethod: paymentMethod.value, cod: paymentMethod.value == 'cash' ? {'name': codName.value.trim(), 'phone': codPhone.value.trim(), 'email': codEmail.value.trim(), 'telegram': codTelegram.value.trim(), 'address': codAddress.value.trim(), 'terms_accepted': codPolicyAccepted.value} : null, homePhoto: paymentMethod.value == 'cash' ? codHomePhoto.value : null);
      await _cart.clear();
      _pendingKey = null;
      _pendingFingerprint = null;
      try {
        await Get.find<NotificationController>().showLocal(
          'Order placed',
          'Order ${order.number} was placed successfully.',
        );
      } catch (_) {
        // A notification failure must not undo the successful order.
      }
      return order;
    } catch (_) { error.value = 'Order could not be placed. Please retry.'; return null; }
    finally { isSubmitting.value = false; }
  }
  List<Map<String, int>> _requestItems() => _cart.items.map((item) => {'product_variant_id': item.variant?.id ?? 0, 'quantity': item.quantity}).toList();
}
