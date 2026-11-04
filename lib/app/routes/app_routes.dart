abstract class AppRoutes {
  // Customer storefront and account screens.
  static const String home = '/';
  static const String catalog = '/catalog';
  static const String productDetails = '/product-details';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderConfirmation = '/order-confirmation';
  static const String orderDetail = '/orders/detail';
  static const String payment = '/payment';
  static const String receipt = '/receipt';
  static const String profile = '/profile';
  static const String login = '/login';
  static const String register = '/register';
  static const String addresses = '/addresses';
  static const String addressForm = '/addresses/form';
  static const String mapPicker = '/addresses/map-picker';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';
  static const String notifications = '/profile/notifications';

  // Admin dashboard. Its modules are tabs inside this route.
  static const String admin = '/admin';
}
