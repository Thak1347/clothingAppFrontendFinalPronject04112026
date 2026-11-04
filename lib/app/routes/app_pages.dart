import 'package:get/get.dart';

import '../../features/catalog/presentation/catalog_binding.dart';
import '../../features/catalog/presentation/pages/catalog_page.dart';
import '../../features/home/presentation/home_binding.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/product_details/presentation/pages/product_details_page.dart';
import '../../features/product_details/presentation/product_details_binding.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/notifications/presentation/pages/notification_settings_page.dart';
import '../../features/addresses/presentation/pages/address_list_page.dart';
import '../../features/addresses/presentation/pages/address_form_page.dart';
import '../../features/addresses/presentation/pages/map_picker_page.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/checkout/presentation/pages/checkout_page.dart';
import '../../features/checkout/presentation/pages/order_confirmation_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/payments/presentation/pages/payment_page.dart';
import '../../features/receipts/presentation/pages/receipt_page.dart';
import '../../features/admin/presentation/pages/admin_dashboard_page.dart';
import 'admin_route_middleware.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage<dynamic>> routes = [
    GetPage<dynamic>(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.catalog,
      page: () => const CatalogPage(),
      binding: CatalogBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.productDetails,
      page: () => const ProductDetailsPage(),
      binding: ProductDetailsBinding(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.cart,
      page: () => const CartPage(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.checkout,
      page: () => const CheckoutPage(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.orders,
      page: () => const OrdersPage(),
    ),
    GetPage<dynamic>(
        name: AppRoutes.orderConfirmation,
        page: () => const OrderConfirmationPage()),
    GetPage<dynamic>(
        name: AppRoutes.orderDetail, page: () => const OrderDetailPage()),
    GetPage<dynamic>(name: AppRoutes.payment, page: () => const PaymentPage()),
    GetPage<dynamic>(name: AppRoutes.receipt, page: () => const ReceiptPage()),
    GetPage<dynamic>(
      name: AppRoutes.profile,
      page: () => const ProfilePage(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.admin,
      page: () => const AdminDashboardPage(),
      middlewares: [AdminRouteMiddleware()],
    ),
    GetPage<dynamic>(
      name: AppRoutes.editProfile,
      page: () => const EditProfilePage(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.changePassword,
      page: () => const ChangePasswordPage(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.notifications,
      page: () => const NotificationSettingsPage(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.addresses,
      page: () => const AddressListPage(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.addressForm,
      page: () => const AddressFormPage(),
    ),
    GetPage<dynamic>(
      name: AppRoutes.mapPicker,
      page: () => const MapPickerPage(),
    ),
  ];
}
