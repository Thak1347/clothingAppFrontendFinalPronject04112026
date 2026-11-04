import '../config/env.dart';

/// Resolves image paths returned by the Laravel public storage disk.
class ImageUrlResolver {
  const ImageUrlResolver._();

  static String resolve(String value) {
    final imageUri = Uri.tryParse(value);
    if (imageUri == null) return value;

    final apiUri = Uri.parse(Env.baseUrl);
    if (!imageUri.hasScheme) return apiUri.resolve(value).toString();

    // Laravel may return APP_URL=http://localhost while the app reaches it
    // through the emulator's host alias or a LAN address.
    if ((imageUri.host == 'localhost' || imageUri.host == '127.0.0.1') &&
        apiUri.host != 'localhost' &&
        apiUri.host != '127.0.0.1') {
      return imageUri
          .replace(
            host: apiUri.host,
            port: apiUri.hasPort
                ? apiUri.port
                : (imageUri.hasPort ? imageUri.port : null),
          )
          .toString();
    }
    return value;
  }
}
