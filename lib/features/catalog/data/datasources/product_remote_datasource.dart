import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<ProductModel> getProduct(int id);
  Future<List<CategoryModel>> getCategories();
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient _dioClient;

  ProductRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _dioClient.dio.get(
        ApiEndpoints.products,
        queryParameters: const {'per_page': 100},
      );

      // Laravel API Resource returns { "data": [...] }
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! List) {
        throw const FormatException('Products response has no data list.');
      }

      return data
          .whereType<Map>()
          .map((json) => ProductModel.fromJson(Map<String, dynamic>.from(json)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<ProductModel> getProduct(int id) async {
    try {
      final response = await _dioClient.dio.get('${ApiEndpoints.products}/$id');
      final body = response.data;
      final data = body is Map ? body['data'] ?? body : null;
      if (data is! Map) {
        throw const FormatException('Product response has no product object.');
      }
      return ProductModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _dioClient.dio.get(ApiEndpoints.categories);
      final body = response.data;
      final data = body is Map ? body['data'] : null;
      if (data is! List) {
        throw const FormatException('Categories response has no data list.');
      }
      return data
          .whereType<Map>()
          .map((json) => CategoryModel.fromJson(Map<String, dynamic>.from(json)))
          .toList(growable: false);
    } on DioException catch (e) {
      throw Exception(e.message);
    }
  }
}
