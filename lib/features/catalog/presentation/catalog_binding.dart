import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../data/datasources/product_remote_datasource.dart';
import '../data/repositories/catalog_repository_impl.dart';
import '../domain/repositories/catalog_repository.dart';
import 'controllers/catalog_controller.dart';

class CatalogBinding extends Bindings {
  @override
  void dependencies() {
    // Data Source
    if (!Get.isRegistered<ProductRemoteDataSource>()) {
      Get.lazyPut<ProductRemoteDataSource>(
        () => ProductRemoteDataSourceImpl(Get.find<DioClient>()),
        fenix: true,
      );
    }

    // Repository
    if (!Get.isRegistered<CatalogRepository>()) {
      Get.lazyPut<CatalogRepository>(
        () => CatalogRepositoryImpl(Get.find<ProductRemoteDataSource>()),
        fenix: true,
      );
    }

    // Controller
    if (!Get.isRegistered<CatalogController>()) {
      Get.lazyPut<CatalogController>(
        () => CatalogController(Get.find<CatalogRepository>()),
        fenix: true,
      );
    }
  }
}
