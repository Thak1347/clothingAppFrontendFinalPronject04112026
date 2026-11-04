import 'package:get/get.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';

enum ProductSort { featured, priceLowToHigh, priceHighToLow, name }

class CatalogController extends GetxController {
  CatalogController(this._repository);

  final CatalogRepository _repository;
  final RxBool isLoading = true.obs;
  final RxList<Product> products = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxnInt selectedCategoryId = RxnInt();
  final Rxn<int> minPriceMinor = Rxn<int>();
  final Rxn<int> maxPriceMinor = Rxn<int>();
  final Rx<ProductSort> sort = ProductSort.featured.obs;

  List<Product> get visibleProducts {
    final query = searchQuery.value.trim().toLowerCase();
    final result = products.where((product) {
      final matchesText = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);
      final matchesCategory = selectedCategoryId.value == null ||
          product.categoryId == selectedCategoryId.value;
      final matchesMin = minPriceMinor.value == null ||
          product.priceMinor >= minPriceMinor.value!;
      final matchesMax = maxPriceMinor.value == null ||
          product.priceMinor <= maxPriceMinor.value!;
      return matchesText && matchesCategory && matchesMin && matchesMax;
    }).toList();

    switch (sort.value) {
      case ProductSort.featured:
        break;
      case ProductSort.priceLowToHigh:
        result.sort((a, b) => a.priceMinor.compareTo(b.priceMinor));
        break;
      case ProductSort.priceHighToLow:
        result.sort((a, b) => b.priceMinor.compareTo(a.priceMinor));
        break;
      case ProductSort.name:
        result.sort((a, b) => a.name.compareTo(b.name));
        break;
    }
    return result;
  }

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final productResults = await _repository.getProducts();
      products.assignAll(productResults);
      try {
        categories.assignAll(await _repository.getCategories());
      } catch (_) {
        // Catalog browsing remains available if category service is unavailable.
        categories.clear();
      }
    } catch (_) {
      errorMessage.value = 'Could not load products. Check your connection and try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void setSearch(String value) => searchQuery.value = value;

  void setCategory(int? id) => selectedCategoryId.value = id;

  void setSort(ProductSort value) => sort.value = value;

  void setPriceRange(int? min, int? max) {
    minPriceMinor.value = min;
    maxPriceMinor.value = max;
  }

  void clearFilters() {
    selectedCategoryId.value = null;
    minPriceMinor.value = null;
    maxPriceMinor.value = null;
    sort.value = ProductSort.featured;
  }

}
