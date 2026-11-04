import 'package:get/get.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import 'package:image_picker/image_picker.dart';
class OrderDetailController extends GetxController {
  OrderDetailController(this._repository); final OrdersRepository _repository;
  final Rxn<Order> order = Rxn<Order>(); final isLoading = false.obs; final error = ''.obs;
  Future<void> load(int id) async { isLoading.value = true; error.value = ''; try { order.value = await _repository.getOrder(id); } catch (_) { error.value = 'Unable to refresh order status.'; } finally { isLoading.value = false; } }
  Future<void> cancel(int id) async { try { order.value = await _repository.cancelOrder(id); } catch (_) { error.value = 'This order cannot be cancelled.'; } }
  Future<void> updateCodDetails(int id, Map<String, String> details, XFile? photo) async { try { order.value = await _repository.updateCodDetails(id, details, photo); } catch (_) { error.value = 'Could not resubmit COD information. Please check the form and retry.'; } }
  Future<void> switchCodToAba(int id) async { error.value = ''; try { order.value = await _repository.switchCodToAba(id); } catch (_) { error.value = 'This order cannot be switched to ABA Pay.'; } }
}
