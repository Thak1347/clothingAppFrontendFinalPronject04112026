import 'package:get/get.dart';

import '../../core/network/dio_client.dart';
import '../../core/storage/prefs_storage.dart';
import '../../core/storage/secure_storage.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/cart/data/datasources/cart_local_datasource.dart';
import '../../features/cart/data/repositories/cart_repository_impl.dart';
import '../../features/cart/presentation/controllers/cart_controller.dart';
import '../../features/addresses/data/datasources/address_remote_datasource.dart';
import '../../features/addresses/data/repositories/address_repository_impl.dart';
import '../../features/addresses/domain/repositories/address_repository.dart';
import '../../features/addresses/presentation/controllers/addresses_controller.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/presentation/controllers/profile_controller.dart';
import '../../features/checkout/data/datasources/checkout_remote_datasource.dart';
import '../../features/checkout/data/repositories/checkout_repository_impl.dart';
import '../../features/checkout/domain/repositories/checkout_repository.dart';
import '../../features/checkout/presentation/controllers/checkout_controller.dart';
import '../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/presentation/controllers/orders_controller.dart';
import '../../features/orders/presentation/controllers/order_detail_controller.dart';
import '../../features/payments/data/datasources/payment_remote_datasource.dart';
import '../../features/payments/data/repositories/payment_repository_impl.dart';
import '../../features/payments/domain/repositories/payment_repository.dart';
import '../../features/payments/presentation/controllers/payment_controller.dart';
import '../../features/receipts/data/datasources/receipt_remote_datasource.dart';
import '../../features/receipts/data/repositories/receipt_repository_impl.dart';
import '../../features/receipts/data/services/receipt_pdf_service.dart';
import '../../features/receipts/domain/repositories/receipt_repository.dart';
import '../../features/receipts/presentation/controllers/receipt_controller.dart';
import '../../features/notifications/data/datasources/fcm_datasource.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/services/local_notification_service.dart';
import '../../features/notifications/presentation/services/push_service.dart';
import '../../features/notifications/presentation/controllers/notification_controller.dart';
import '../../features/admin/presentation/controllers/admin_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<PrefsStorage>()) {
      throw StateError(
          'Initialize PrefsStorage before runApp in each flavor entry point.');
    }
    Get.put<SecureStorage>(SecureStorage(), permanent: true);
    Get.put<DioClient>(DioClient(Get.find<SecureStorage>()), permanent: true);

    Get.lazyPut<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
          Get.find<DioClient>(), Get.find<SecureStorage>()),
      fenix: true,
    );
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find<AuthRemoteDataSource>()),
      fenix: true,
    );
    Get.put<AuthController>(
        AuthController(Get.find<AuthRepository>(), Get.find<DioClient>(),
            Get.find<SecureStorage>()),
        permanent: true);

    Get.lazyPut<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(Get.find<DioClient>()),
      fenix: true,
    );
    Get.lazyPut<ProfileRepository>(
      () => ProfileRepositoryImpl(Get.find<ProfileRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<ProfileController>(
      () => ProfileController(
          Get.find<ProfileRepository>(), Get.find<AuthController>()),
      fenix: true,
    );

    Get.put<CartController>(
      CartController(
          CartRepositoryImpl(CartLocalDataSource(Get.find<PrefsStorage>()))),
      permanent: true,
    );
    Get.lazyPut<AddressRemoteDataSource>(
      () => AddressRemoteDataSource(Get.find<DioClient>()),
      fenix: true,
    );
    Get.lazyPut<AddressRepository>(
      () => AddressRepositoryImpl(Get.find<AddressRemoteDataSource>()),
      fenix: true,
    );
    Get.lazyPut<AddressesController>(
      () => AddressesController(Get.find<AddressRepository>()),
      fenix: true,
    );
    Get.lazyPut<CheckoutRemoteDataSource>(
        () => CheckoutRemoteDataSource(Get.find<DioClient>()),
        fenix: true);
    Get.lazyPut<CheckoutRepository>(
        () => CheckoutRepositoryImpl(Get.find<CheckoutRemoteDataSource>()),
        fenix: true);
    Get.lazyPut<CheckoutController>(
        () => CheckoutController(Get.find<CheckoutRepository>(),
            Get.find<CartController>(), Get.find<AddressesController>()),
        fenix: true);
    Get.lazyPut<OrdersRemoteDataSource>(
        () => OrdersRemoteDataSource(Get.find<DioClient>()),
        fenix: true);
    Get.lazyPut<OrdersRepository>(
        () => OrdersRepositoryImpl(Get.find<OrdersRemoteDataSource>()),
        fenix: true);
    Get.lazyPut<OrdersController>(
        () => OrdersController(Get.find<OrdersRepository>()),
        fenix: true);
    Get.lazyPut<OrderDetailController>(
        () => OrderDetailController(Get.find<OrdersRepository>()),
        fenix: true);
    Get.lazyPut<PaymentRemoteDataSource>(
        () => PaymentRemoteDataSource(Get.find<DioClient>()),
        fenix: true);
    Get.lazyPut<PaymentRepository>(
        () => PaymentRepositoryImpl(Get.find<PaymentRemoteDataSource>()),
        fenix: true);
    Get.lazyPut<PaymentController>(
        () => PaymentController(Get.find<PaymentRepository>()),
        fenix: true);
    Get.lazyPut<ReceiptRemoteDataSource>(
        () => ReceiptRemoteDataSource(Get.find<DioClient>()),
        fenix: true);
    Get.lazyPut<ReceiptRepository>(
        () => ReceiptRepositoryImpl(Get.find<ReceiptRemoteDataSource>()),
        fenix: true);
    Get.lazyPut<ReceiptPdfService>(() => ReceiptPdfService(), fenix: true);
    Get.lazyPut<ReceiptController>(
      () => ReceiptController(
        Get.find<ReceiptRepository>(),
        Get.find<ReceiptPdfService>(),
      ),
      fenix: true,
    );
    Get.lazyPut<FcmDataSource>(() => FcmDataSource(Get.find<DioClient>()),
        fenix: true);
    Get.lazyPut<NotificationRepository>(
        () => NotificationRepositoryImpl(Get.find<FcmDataSource>()),
        fenix: true);
    Get.lazyPut<LocalNotificationService>(() => LocalNotificationService(),
        fenix: true);
    Get.lazyPut<PushService>(
        () => PushService(Get.find<NotificationRepository>(),
            Get.find<LocalNotificationService>()),
        fenix: true);
    Get.lazyPut<NotificationController>(
        () => NotificationController(Get.find<PushService>()),
        fenix: true);
    Get.lazyPut<AdminController>(() => AdminController(Get.find<DioClient>()),
        fenix: true);
  }
}
