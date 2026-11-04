import 'package:get/get.dart';

import '../../catalog/domain/entities/product.dart';
import '../../catalog/domain/repositories/catalog_repository.dart';
import 'controllers/product_details_controller.dart';

class ProductDetailsBinding extends Bindings {
  @override
  void dependencies() {
    final product = Get.arguments;
    if (product is Product) {
      Get.put<ProductDetailsController>(ProductDetailsController(product));
      return;
    }
    if (product is! int) {
      throw ArgumentError('Product details route requires a Product or ID.');
    }
    Get.put<ProductDetailsController>(ProductDetailsController.fromId(
      Get.find<CatalogRepository>(),
      product,
    ));
  }
}
