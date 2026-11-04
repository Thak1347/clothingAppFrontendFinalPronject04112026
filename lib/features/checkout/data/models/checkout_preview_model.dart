import '../../domain/entities/checkout_preview.dart';

class CheckoutPreviewModel extends CheckoutPreview {
  const CheckoutPreviewModel({required super.items, required super.subtotalMinor, required super.deliveryFeeMinor, required super.totalMinor, required super.currency});

  factory CheckoutPreviewModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List? ?? const []);
    return CheckoutPreviewModel(
      items: rawItems.whereType<Map>().map((e) {
        final item = Map<String, dynamic>.from(e);
        return CheckoutLine(
          name: '${item['product_name'] ?? item['name'] ?? 'Product'}',
          size: item['size']?.toString(), color: item['color']?.toString(),
          quantity: _int(item['quantity']), unitPriceMinor: _int(item['unit_price_minor']),
          lineTotalMinor: _int(item['line_total_minor']),
        );
      }).toList(),
      subtotalMinor: _int(json['subtotal_minor']),
      deliveryFeeMinor: _int(json['delivery_fee_minor']),
      totalMinor: _int(json['total_minor']),
      currency: '${json['currency'] ?? 'USD'}',
    );
  }
}

int _int(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
