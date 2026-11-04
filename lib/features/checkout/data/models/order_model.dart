import '../../domain/entities/order.dart';

class OrderModel extends Order {
  const OrderModel({required super.id, required super.number, required super.fulfillmentStatus, required super.subtotalMinor, required super.deliveryFeeMinor, required super.totalMinor, required super.currency, required super.items, required super.payment, super.paymentStatus, super.paymentMethod, super.codVerificationStatus, super.codCustomer, super.codReviewReason, super.codTermsAcceptedAt, super.cancellationReviewReason, super.amountPaidMinor, super.remainingBalanceMinor, super.codBalancePaidMinor, super.refundedMinor, super.refundPendingMinor, super.activities, super.createdAt});

  factory OrderModel.fromJson(Map<String, dynamic> source) {
    final json = source['data'] is Map ? Map<String, dynamic>.from(source['data'] as Map) : source;
    final rawPayment = json['payment'];
    final rawItems = (json['items'] as List? ?? const []);
    final payment = rawPayment is Map ? Map<String, dynamic>.from(rawPayment) : null;
    return OrderModel(
      id: _int(json['id']), number: '${json['number'] ?? json['id'] ?? ''}',
      fulfillmentStatus: '${json['fulfillment_status'] ?? 'processing'}',
      paymentStatus: json['payment_status']?.toString(),
      paymentMethod: json['payment_method']?.toString(), codVerificationStatus: json['cod_verification_status']?.toString(),
      codCustomer: json['cod_customer'] is Map ? Map<String, dynamic>.from(json['cod_customer'] as Map) : null,
      codReviewReason: json['cod_review_reason']?.toString(), amountPaidMinor: _int(json['amount_paid_minor']), remainingBalanceMinor: _int(json['remaining_balance_minor']), codBalancePaidMinor: _int(json['cod_balance_paid_minor']),
      codTermsAcceptedAt: json['cod_terms_accepted_at']?.toString(),
      cancellationReviewReason: json['cancellation_review_reason']?.toString(),
      refundedMinor: _int(json['refunded_minor']), refundPendingMinor: _int(json['refund_pending_minor']),
      activities: (json['activities'] as List? ?? const []).whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList(),
      subtotalMinor: _int(json['subtotal_minor']), deliveryFeeMinor: _int(json['delivery_fee_minor']),
      totalMinor: _int(json['total_minor']), currency: '${json['currency'] ?? 'USD'}',
      items: rawItems.whereType<Map>().map((value) {
        final item = Map<String, dynamic>.from(value);
        return OrderItem(name: '${item['product_name'] ?? 'Product'}', quantity: _int(item['quantity']), unitPriceMinor: _int(item['unit_price_minor']), lineTotalMinor: _int(item['line_total_minor']), size: item['size']?.toString(), color: item['color']?.toString());
      }).toList(),
      payment: payment == null ? null : OrderPayment(
        id: _int(payment['id']), status: '${payment['status'] ?? 'pending'}', provider: '${payment['provider'] ?? ''}',
        reference: payment['reference']?.toString(), amountMinor: _int(payment['amount_minor']), currency: payment['currency']?.toString(),
        metadata: payment['provider_metadata'] is Map ? Map<String, dynamic>.from(payment['provider_metadata'] as Map) : null,
      ),
      createdAt: DateTime.tryParse('${json['created_at'] ?? ''}'),
    );
  }
}

int _int(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
