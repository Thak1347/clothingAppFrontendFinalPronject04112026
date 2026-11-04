import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';

/// Home uses the catalog data source contract and shapes it into landing-page data.
class HomeRepositoryImpl {
  const HomeRepositoryImpl(this._catalogRepository);

  final CatalogRepository _catalogRepository;

  Future<List<Category>> getCategories() => _catalogRepository.getCategories();

  Future<List<Product>> getNewArrivals() => _catalogRepository.getProducts();
}
