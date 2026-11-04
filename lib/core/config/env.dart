import '../../flavors.dart';

class Env {
  Env._();

  /// Returns the base URL based on the active Flavor (dev, staging, prod).
  static String get baseUrl {
    switch (F.appFlavor) {
      case Flavor.dev:
        // 10.0.2.2 is the Android emulator's alias for localhost.
        // If using a physical device, replace with your PC's LAN IP (e.g., 192.168.1.42)
        return 'http://10.0.2.2:8000/api/v1';
      case Flavor.staging:
        return 'https://staging-api.clothingapp.com/api/v1';
      case Flavor.prod:
        return 'https://api.clothingapp.com/api/v1';
    }
  }

  /// Only allow mock payments in development.
  static bool get allowMockPayment => F.appFlavor == Flavor.dev;
}
