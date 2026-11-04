class AssetResolver {
  static const String fallbackProductImage = 'assets/images/placeholder_product.png';
  static const String _productPrefix = 'assets/images/products/';

  /// Resolves a backend asset identifier to a bundled image. Path traversal,
  /// remote URLs, and arbitrary server paths are never accepted.
  static String getProductImage(String? assetKey) {
    if (assetKey == null || assetKey.trim().isEmpty) {
      return fallbackProductImage;
    }

    final key = assetKey.trim();
    if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(key)) {
      return fallbackProductImage;
    }
    return '$_productPrefix$key.jpg';
  }
}
