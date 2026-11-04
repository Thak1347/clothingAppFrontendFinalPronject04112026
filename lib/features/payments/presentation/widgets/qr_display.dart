import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

enum PaymentQrType {
  payload,
  imageUrl,
}

class QrDisplay extends StatelessWidget {
  const QrDisplay({
    super.key,
    this.value = '',
    this.qrImageUrl,
    this.qrImageBase64,
    this.fallbackUrl,
    this.type = PaymentQrType.payload,
    this.size = 260,
  });

  final String value;
  final String? qrImageUrl;
  final String? qrImageBase64;
  final String? fallbackUrl;
  final PaymentQrType type;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: _renderQr(context),
    );
  }

  Widget _renderQr(BuildContext context) {
    final imageUrl = _validImageUrl(qrImageUrl);
    if (imageUrl != null) {
      return _networkImage(imageUrl, () => _renderPayloadOrFallback(context));
    }

    final imageBytes = _decodeImage(qrImageBase64);
    if (imageBytes != null) {
      return Image.memory(
        imageBytes,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _renderPayloadOrFallback(context),
      );
    }

    if (type == PaymentQrType.imageUrl) {
      final legacyImageUrl = _validImageUrl(value);
      if (legacyImageUrl != null) {
        return _networkImage(
          legacyImageUrl,
          () => _renderFallbackUrlOrUnavailable(legacyImageUrl),
        );
      }
    }

    if (value.trim().isNotEmpty) {
      return _payloadView(value);
    }

    final fallback = _validImageUrl(fallbackUrl);
    if (fallback != null) {
      return _networkImage(fallback, _unavailableView);
    }
    return _unavailableView();
  }

  Widget _renderPayloadOrFallback(BuildContext context) {
    if (value.trim().isNotEmpty) return _payloadView(value);
    return _renderFallbackUrlOrUnavailable(qrImageUrl);
  }

  Widget _renderFallbackUrlOrUnavailable(String? excludedUrl) {
    final fallback = _validImageUrl(fallbackUrl);
    if (fallback != null && fallback != excludedUrl) {
      return _networkImage(fallback, _unavailableView);
    }
    return _unavailableView();
  }

  Widget _payloadView(String payload) => QrImageView(
        data: payload,
        version: QrVersions.auto,
        size: size,
        backgroundColor: AppColors.surfaceWhite,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
      );

  Widget _networkImage(String url, Widget Function() onError) => Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => onError(),
      );

  Widget _unavailableView() => SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: Text(
            'Payment QR is unavailable',
            textAlign: TextAlign.center,
          ),
        ),
      );

  static String? _validImageUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        !uri.hasAuthority ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return uri.toString();
  }

  static Uint8List? _decodeImage(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    var encoded = value.trim();
    if (encoded.startsWith('data:image/')) {
      final separator = encoded.indexOf(',');
      if (separator < 0) return null;
      encoded = encoded.substring(separator + 1);
    }
    try {
      return base64Decode(base64.normalize(encoded));
    } on FormatException {
      return null;
    }
  }
}
