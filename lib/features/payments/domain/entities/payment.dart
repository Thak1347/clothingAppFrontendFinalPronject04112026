class PaymentInitiation {
  const PaymentInitiation({
    required this.provider,
    this.qrString,
    this.qrUrl,
    this.qrImageUrl,
    this.qrImageBase64,
    this.deepLink,
    this.bankDeepLinks = const {},
    this.reference,
    this.amount,
    this.currency,
  });

  final String provider;
  final String? qrString;
  final String? qrUrl;
  final String? qrImageUrl;
  final String? qrImageBase64;
  final String? deepLink;
  final Map<String, String> bankDeepLinks;
  final String? reference;
  final String? amount;
  final String? currency;

  bool get hasQr =>
      _hasValue(qrImageUrl) ||
      _hasValue(qrImageBase64) ||
      _hasValue(qrString) ||
      _hasValue(qrUrl);

  static bool _hasValue(String? value) => value?.trim().isNotEmpty ?? false;
}
