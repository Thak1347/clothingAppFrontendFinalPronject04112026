import 'package:get/get.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
class OrdersController extends GetxController {
  OrdersController(this._repository); final OrdersRepository _repository;
  final orders = <Order>[].obs; final isLoading = false.obs; final error = ''.obs;
  @override void onInit() { super.onInit(); load(); }
  Future<void> load() async { isLoading.value = true; error.value = ''; try { orders.assignAll(await _repository.getOrders()); } catch (_) { error.value = 'Unable to load orders. Please retry.'; } finally { isLoading.value = false; } }
}
