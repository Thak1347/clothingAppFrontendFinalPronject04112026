import '../entities/product.dart';
import '../entities/category.dart';

abstract class CatalogRepository {
  Future<List<Product>> getProducts();
  Future<Product> getProduct(int id);
  Future<List<Category>> getCategories();
}
