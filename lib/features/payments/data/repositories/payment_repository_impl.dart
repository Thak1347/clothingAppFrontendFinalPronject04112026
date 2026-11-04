import '../../../checkout/data/models/order_model.dart';
import '../../../checkout/domain/entities/order.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_datasource.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  PaymentRepositoryImpl(this._remote);
  final PaymentRemoteDataSource _remote;
  @override
  Future<PaymentInitiation> initiate(int id, String provider) async {
    final value = await _remote.initiate(id, provider);
    final map = value is Map && value['data'] is Map
        ? Map<String, dynamic>.from(value['data'] as Map)
        : value is Map
            ? Map<String, dynamic>.from(value)
            : <String, dynamic>{};
    return PaymentInitiation(
        provider: '${map['provider'] ?? ''}',
        qrString: map['qr_string']?.toString(),
        qrUrl: map['qr_url']?.toString(),
        qrImageUrl: _firstString(map, const [
          'qr_image_url',
          'image_url',
          'qr_image',
        ], onlyUrl: true),
        qrImageBase64: _firstString(map, const [
          'qr_image_base64',
          'qr_base64',
          'image_base64',
          'qr_image',
        ], onlyUrl: false),
        deepLink: (map['checkout_url'] ?? map['deep_link'])?.toString(),
        bankDeepLinks: _bankDeepLinks(map),
        reference: (map['reference'] ?? map['transaction_id'])?.toString(),
        amount: map['amount']?.toString(), currency: map['currency']?.toString());
  }

  static String? _firstString(
    Map<String, dynamic> source,
    List<String> keys, {
    required bool onlyUrl,
  }) {
    for (final key in keys) {
      final value = source[key]?.toString().trim();
      if (value == null || value.isEmpty) continue;
      final uri = Uri.tryParse(value);
      final isUrl = uri?.hasAuthority == true &&
          (uri?.scheme == 'https' || uri?.scheme == 'http');
      if (isUrl == onlyUrl) return value;
    }
    return null;
  }

  static Map<String, String> _bankDeepLinks(Map<String, dynamic> source) {
    final links = <String, String>{};
    final rawLinks = source['banking_apps'] ??
        source['banking_links'] ??
        source['bank_links'] ??
        source['deep_links'];
    if (rawLinks is! Map) return links;

    for (final entry in rawLinks.entries) {
      final key = entry.key
          .toString()
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z]'), '');
      final bank = switch (key) {
        'aba' || 'abamobile' => 'aba',
        'wing' || 'wingbank' => 'wing',
        'acleda' || 'acledamobile' || 'acledatonchet' => 'acleda',
        'bakong' => 'bakong',
        _ => null,
      };
      final value = entry.value;
      final url = value is Map
          ? (value['deep_link'] ?? value['url'])?.toString()
          : value?.toString();
      if (bank != null && url != null && url.trim().isNotEmpty) {
        links[bank] = url.trim();
      }
    }
    return links;
  }

  @override
  Future<Order> refreshOrder(int id) async {
    final value = await _remote.order(id);
    return OrderModel.fromJson(
        value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{});
  }

  @override
  Future<Order> pollOrder(int id) async {
    final value = await _remote.paymentStatus(id);
    final response = value is Map && value['data'] is Map
        ? Map<String, dynamic>.from(value['data'] as Map)
        : Map<String, dynamic>.from(value as Map);
    final rawOrder = response['order'];
    return OrderModel.fromJson(rawOrder is Map
        ? Map<String, dynamic>.from(rawOrder)
        : response);
  }
}
