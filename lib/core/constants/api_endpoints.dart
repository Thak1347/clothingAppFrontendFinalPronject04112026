abstract class ApiEndpoints {
  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String me = '/me';
  static const String updatePassword = '/me/password';
  static const String avatar = '/me/avatar';

  // Catalog
  static const String categories = '/categories';
  static const String products = '/products';

  // Addresses
  static const String addresses = '/addresses';

  // Checkout & Orders
  static const String checkoutPreview = '/checkout/preview';
  static const String orders = '/orders';

  // Notifications
  static const String deviceTokens = '/device-tokens';

  static String address(int id) => '$addresses/$id';
  static String setDefaultAddress(int id) => '$addresses/$id/set-default';
}
