import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

import '../../../../core/network/dio_client.dart';
import '../../../orders/data/models/order_list_model.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../notifications/presentation/controllers/notification_controller.dart';

class AdminController extends GetxController {
  AdminController(this._client);

  final DioClient _client;
  final orders = <Order>[].obs;
  final dashboard = <String, dynamic>{}.obs;
  final dashboardLoading = false.obs;
  final dashboardPeriod = 'today'.obs;
  final payments = <Map<String, dynamic>>[].obs;
  final categories = <Map<String, dynamic>>[].obs;
  final products = <Map<String, dynamic>>[].obs;
  final loadingOrders = false.obs;
  final loadingPayments = false.obs;
  final loadingCategories = false.obs;
  final loadingProducts = false.obs;
  final error = ''.obs;
  final updatingOrderIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    await Future.wait([
      loadDashboard(dashboardPeriod.value),
      loadOrders(),
      loadPayments(),
      loadCategories(),
      loadProducts(),
    ]);
  }

  Future<void> loadDashboard([String? period]) async {
    if (period != null) dashboardPeriod.value = period;
    dashboardLoading.value = true;
    try {
      final response = await _client.dio.get(
        '/admin/dashboard',
        queryParameters: {'period': dashboardPeriod.value},
      );
      final data = response.data;
      dashboard.assignAll(data is Map ? Map<String, dynamic>.from(data) : {});
    } on DioException catch (exception) {
      error.value = _message(exception);
    } catch (_) {
      error.value = 'Unable to load dashboard metrics.';
    } finally {
      dashboardLoading.value = false;
    }
  }

  Future<void> loadOrders() async {
    loadingOrders.value = true;
    error.value = '';
    try {
      final response = await _client.dio.get('/admin/orders');
      orders.assignAll(OrderListModel.parse(response.data));
    } on DioException catch (exception) {
      error.value = _message(exception);
    } catch (_) {
      error.value = 'Unable to load admin orders.';
    } finally {
      loadingOrders.value = false;
    }
  }

  Future<void> loadPayments() =>
      _loadMapList('/admin/payments', payments, loadingPayments);
  Future<void> loadCategories() =>
      _loadMapList('/admin/categories', categories, loadingCategories);
  Future<void> loadProducts() =>
      _loadMapList('/admin/products', products, loadingProducts);

  Future<void> _loadMapList(
    String path,
    RxList<Map<String, dynamic>> target,
    RxBool loading,
  ) async {
    loading.value = true;
    error.value = '';
    try {
      final response = await _client.dio.get(path);
      target.assignAll(_list(response.data));
    } on DioException catch (exception) {
      error.value = _message(exception);
    } catch (_) {
      error.value = 'Unable to load admin data.';
    } finally {
      loading.value = false;
    }
  }

  Future<void> saveCategory(Map<String, dynamic> data, {int? id}) async {
    try {
      final response = id == null
          ? await _client.dio.post('/admin/categories', data: data)
          : await _client.dio.put('/admin/categories/$id', data: data);
      final value = _unwrap(response.data);
      if (id == null) {
        categories.add(value);
      } else {
        _replace(categories, id, value);
      }
      await _notifyLocal(
        id == null ? 'Category created' : 'Category updated',
        '${value['name'] ?? 'Category'} was saved successfully.',
      );
    } on DioException catch (exception) {
      _showError(exception);
      rethrow;
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await _client.dio.delete('/admin/categories/$id');
      categories.removeWhere((item) => _int(item['id']) == id);
      await _notifyLocal('Category deleted', 'The category was deleted.');
    } on DioException catch (exception) {
      _showError(exception);
    }
  }

  Future<void> saveProduct(Map<String, dynamic> data, {int? id}) async {
    try {
      final fields = Map<String, dynamic>.from(data);
      final images = (fields.remove('images') as List? ?? const [])
          .whereType<XFile>()
          .toList(growable: false);
      final removedImageIds =
          (fields.remove('remove_image_ids') as List? ?? const [])
              .whereType<int>()
              .toList(growable: false);

      late Map<String, dynamic> value;
      if (id == null) {
        final response = await _client.dio.post(
          '/admin/products',
          data: await _productFormData(
            fields,
            images: images,
            removedImageIds: removedImageIds,
          ),
        );
        value = _unwrap(response.data);
      } else {
        final response = await _client.dio.put('/admin/products/$id', data: fields);
        value = _unwrap(response.data);
        if (images.isNotEmpty || removedImageIds.isNotEmpty) {
          final imageResponse = await _client.dio.post(
            '/admin/products/$id/images',
            data: await _productFormData(
              const <String, dynamic>{},
              images: images,
              removedImageIds: removedImageIds,
            ),
          );
          value = _unwrap(imageResponse.data);
        }
      }

      if (id == null) {
        products.add(value);
      } else {
        _replace(products, id, value);
      }
      await _notifyLocal(
        id == null ? 'Product created' : 'Product updated',
        '${value['name'] ?? 'Product'} was saved successfully.',
      );
    } on DioException catch (exception) {
      _showError(exception);
      rethrow;
    }
  }

  Future<FormData> _productFormData(
    Map<String, dynamic> data, {
    required List<XFile> images,
    required List<int> removedImageIds,
  }) async {
    // Multipart values are sent as strings. Laravel's `boolean` validator
    // accepts 0/1, but may reject the strings "true" and "false".
    final fields = <String, dynamic>{
      for (final entry in data.entries)
        if (entry.value != null)
          entry.key: entry.value is bool
              ? (entry.value as bool ? 1 : 0)
              : entry.value,
    };
    for (var index = 0; index < removedImageIds.length; index++) {
      fields['remove_image_ids[$index]'] = removedImageIds[index];
    }
    for (var index = 0; index < images.length; index++) {
      final image = images[index];
      fields['images[$index]'] = await MultipartFile.fromFile(
        image.path,
        filename: image.name,
      );
    }
    return FormData.fromMap(fields);
  }

  Future<void> deleteProduct(int id) async {
    try {
      await _client.dio.delete('/admin/products/$id');
      final deletedProduct = products.firstWhereOrNull((item) => _int(item['id']) == id);
      products.removeWhere((item) => _int(item['id']) == id);
      await _notifyLocal(
        'Product deleted',
        '${deletedProduct?['name'] ?? 'Product'} was deleted.',
      );
    } on DioException catch (exception) {
      _showError(exception);
    }
  }

  Future<void> saveVariant(int productId, Map<String, dynamic> data, {int? id}) async {
    try {
      final path = '/admin/products/$productId/variants';
      final response = id == null
          ? await _client.dio.post(path, data: data)
          : await _client.dio.put('$path/$id', data: data);
      final value = _unwrap(response.data);
      final productIndex = products.indexWhere((item) => _int(item['id']) == productId);
      if (productIndex >= 0) {
        final product = Map<String, dynamic>.from(products[productIndex]);
        final variants = (product['variants'] as List? ?? const [])
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
        if (id == null) {
          variants.add(value);
        } else {
          final variantIndex = variants.indexWhere((item) => _int(item['id']) == id);
          if (variantIndex >= 0) variants[variantIndex] = value;
        }
        product['variants'] = variants;
        products[productIndex] = product;
      }
      await _notifyLocal(
        id == null ? 'Variant created' : 'Variant updated',
        'Product variant was saved successfully.',
      );
    } on DioException catch (exception) {
      _showError(exception);
      rethrow;
    }
  }

  Future<void> deleteVariant(int productId, int id) async {
    try {
      await _client.dio.delete('/admin/products/$productId/variants/$id');
      final index = products.indexWhere((item) => _int(item['id']) == productId);
      if (index >= 0) {
        final product = Map<String, dynamic>.from(products[index]);
        product['variants'] = (product['variants'] as List? ?? const [])
            .where((item) => item is Map && _int(item['id']) != id)
            .toList();
        products[index] = product;
      }
      await _notifyLocal('Variant deleted', 'The product variant was deleted.');
    } on DioException catch (exception) {
      _showError(exception);
    }
  }

  List<Map<String, dynamic>> _list(dynamic response) {
    final data = response is Map ? response['data'] : response;
    if (data is! List) return [];
    return data
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Map<String, dynamic> _unwrap(dynamic response) {
    final value = response is Map && response['data'] is Map
        ? response['data']
        : response;
    return value is Map ? Map<String, dynamic>.from(value) : {};
  }

  void _replace(RxList<Map<String, dynamic>> target, int id, Map<String, dynamic> value) {
    final index = target.indexWhere((item) => _int(item['id']) == id);
    if (index >= 0) target[index] = value;
  }

  int _int(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;

  void _showError(DioException exception) =>
      Get.snackbar('Admin request failed', _message(exception));

  Future<void> updateFulfillment(int orderId, String status) async {
    updatingOrderIds.add(orderId);
    try {
      final response = await _client.dio.patch(
        '/admin/orders/$orderId/fulfillment',
        data: {'status': status},
      );
      final body = response.data;
      final value = body is Map && body['data'] is Map ? body['data'] : body;
      if (value is Map) {
        final updated = OrderListModel.parse([value]).firstOrNull;
        if (updated != null) {
          final index = orders.indexWhere((order) => order.id == orderId);
          if (index >= 0) orders[index] = updated;
          await _notifyLocal(
            'Order updated',
            'Order ${updated.number} status is now ${updated.fulfillmentStatus}.',
          );
        }
      }
    } on DioException catch (exception) {
      Get.snackbar('Could not update order', _message(exception));
    } catch (_) {
      Get.snackbar('Could not update order', 'Please try again.');
    } finally {
      updatingOrderIds.remove(orderId);
    }
  }

  Future<void> reviewCod(int orderId, String decision, {String? reason}) async {
    updatingOrderIds.add(orderId);
    try {
      final response = await _client.dio.patch('/admin/orders/$orderId/cod-review', data: {'decision': decision, if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim()});
      final body = response.data;
      final updated = OrderListModel.parse([body is Map && body['data'] is Map ? body['data'] : body]).firstOrNull;
      if (updated != null) {
        final index = orders.indexWhere((order) => order.id == orderId);
        if (index >= 0) orders[index] = updated;
      }
    } on DioException catch (exception) {
      Get.snackbar('COD review failed', _message(exception));
    } finally {
      updatingOrderIds.remove(orderId);
    }
  }

  Future<void> reviewCancellation(int orderId, String decision, {String? reason}) async {
    updatingOrderIds.add(orderId);
    try {
      final response = await _client.dio.patch('/admin/orders/$orderId/cancellation-review', data: {'decision': decision, if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim()});
      final body = response.data;
      final updated = OrderListModel.parse([body is Map && body['data'] is Map ? body['data'] : body]).firstOrNull;
      if (updated != null) {
        final index = orders.indexWhere((order) => order.id == orderId);
        if (index >= 0) orders[index] = updated;
      }
    } on DioException catch (exception) {
      Get.snackbar('Cancellation review failed', _message(exception));
    } finally {
      updatingOrderIds.remove(orderId);
    }
  }

  Future<void> approveCodOrder(int orderId) async {
    updatingOrderIds.add(orderId);
    try {
      final response = await _client.dio.patch('/admin/orders/$orderId/cod-approval');
      final body = response.data;
      final updated = OrderListModel.parse([body is Map && body['data'] is Map ? body['data'] : body]).firstOrNull;
      if (updated != null) {
        final index = orders.indexWhere((order) => order.id == orderId);
        if (index >= 0) orders[index] = updated;
      }
    } on DioException catch (exception) {
      Get.snackbar('COD approval failed', _message(exception));
    } finally {
      updatingOrderIds.remove(orderId);
    }
  }

  Future<void> recordCodBalance(int orderId) async {
    updatingOrderIds.add(orderId);
    try {
      final response = await _client.dio.post('/admin/orders/$orderId/cod-balance');
      final body = response.data;
      final updated = OrderListModel.parse([body is Map && body['data'] is Map ? body['data'] : body]).firstOrNull;
      if (updated != null) {
        final index = orders.indexWhere((order) => order.id == orderId);
        if (index >= 0) orders[index] = updated;
      }
    } on DioException catch (exception) {
      Get.snackbar('Could not record COD cash', _message(exception));
    } finally {
      updatingOrderIds.remove(orderId);
    }
  }

  Future<void> recordRefund(int orderId, String action, {int? amountMinor, required String reason}) async {
    updatingOrderIds.add(orderId);
    try {
      final response = await _client.dio.post('/admin/orders/$orderId/refund', data: {'action': action, if (amountMinor != null) 'amount_minor': amountMinor, 'reason': reason});
      final body = response.data;
      final updated = OrderListModel.parse([body is Map && body['data'] is Map ? body['data'] : body]).firstOrNull;
      if (updated != null) {
        final index = orders.indexWhere((order) => order.id == orderId);
        if (index >= 0) orders[index] = updated;
      }
    } on DioException catch (exception) {
      Get.snackbar('Could not record refund', _message(exception));
    } finally {
      updatingOrderIds.remove(orderId);
    }
  }

  Future<Uint8List?> loadCodDocument(int orderId) async {
    try {
      final response = await _client.dio.get('/admin/orders/$orderId/cod-document', options: Options(responseType: ResponseType.bytes));
      return Uint8List.fromList(response.data as List<int>);
    } catch (_) {
      Get.snackbar('Document unavailable', 'Could not load the customer home photo.');
      return null;
    }
  }

  String _message(DioException exception) {
    final message = exception.response?.data;
    if (message is Map && message['message'] is String) {
      return message['message'] as String;
    }
    if (exception.response?.statusCode == 403) {
      return 'This account is not allowed to access admin tools.';
    }
    return 'Please check your connection and retry.';
  }

  Future<void> _notifyLocal(String title, String body) async {
    try {
      await Get.find<NotificationController>().showLocal(title, body);
    } catch (_) {
      // Admin CRUD remains successful even if local notifications are disabled.
    }
  }
}
