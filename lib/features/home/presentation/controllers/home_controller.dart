import 'package:get/get.dart';

import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../data/repositories/home_repository_impl.dart';

class HomeController extends GetxController {
  HomeController(this._repository);

  final HomeRepositoryImpl _repository;
  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final categories = <Category>[].obs;
  final newArrivals = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHome();
  }

  Future<void> loadHome() async {
    isLoading.value = true;
    errorMessage.value = '';
    var categoriesFailed = false;
    var productsFailed = false;
    try {
      categories.assignAll(await _repository.getCategories());
    } catch (_) {
      categoriesFailed = true;
    }
    try {
      newArrivals.assignAll((await _repository.getNewArrivals()).take(8));
    } catch (_) {
      productsFailed = true;
    }
    if (categoriesFailed && productsFailed) {
      errorMessage.value =
          'Could not load the storefront. Check your connection and try again.';
    }
    isLoading.value = false;
  }
}
