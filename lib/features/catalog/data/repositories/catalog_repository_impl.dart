import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/product_remote_datasource.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final ProductRemoteDataSource _remoteDataSource;

  CatalogRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Product>> getProducts() async {
    return await _remoteDataSource.getProducts();
  }

  @override
  Future<Product> getProduct(int id) async {
    return _remoteDataSource.getProduct(id);
  }

  @override
  Future<List<Category>> getCategories() async {
    return _remoteDataSource.getCategories();
  }
}
