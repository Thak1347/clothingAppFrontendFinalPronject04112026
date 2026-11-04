import 'package:get/get.dart';

import '../../catalog/domain/repositories/catalog_repository.dart';
import '../../catalog/presentation/catalog_binding.dart';
import '../data/repositories/home_repository_impl.dart';
import 'controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    CatalogBinding().dependencies();
    Get.lazyPut<HomeRepositoryImpl>(
      () => HomeRepositoryImpl(Get.find<CatalogRepository>()),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(Get.find<HomeRepositoryImpl>()),
    );
  }
}
