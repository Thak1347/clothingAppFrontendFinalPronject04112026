class Order {
  const Order({required this.id, required this.number, required this.fulfillmentStatus, required this.subtotalMinor, required this.deliveryFeeMinor, required this.totalMinor, required this.currency, required this.items, required this.payment, this.paymentStatus, this.paymentMethod, this.codVerificationStatus, this.codCustomer, this.codReviewReason, this.codTermsAcceptedAt, this.cancellationReviewReason, this.amountPaidMinor = 0, this.remainingBalanceMinor = 0, this.codBalancePaidMinor = 0, this.refundedMinor = 0, this.refundPendingMinor = 0, this.activities = const [], this.createdAt});
  final int id;
  final String number;
  final String fulfillmentStatus;
  final int subtotalMinor;
  final int deliveryFeeMinor;
  final int totalMinor;
  final String currency;
  final List<OrderItem> items;
  final OrderPayment? payment;
  final String? paymentStatus;
  final String? paymentMethod, codVerificationStatus;
  final Map<String, dynamic>? codCustomer;
  final String? codReviewReason;
  final String? codTermsAcceptedAt;
  final String? cancellationReviewReason;
  final int amountPaidMinor, remainingBalanceMinor, codBalancePaidMinor;
  final int refundedMinor, refundPendingMinor;
  final List<Map<String, dynamic>> activities;
  final DateTime? createdAt;
}

class OrderItem {
  const OrderItem({required this.name, required this.quantity, required this.unitPriceMinor, required this.lineTotalMinor, this.size, this.color});
  final String name;
  final int quantity;
  final int unitPriceMinor;
  final int lineTotalMinor;
  final String? size;
  final String? color;
}

class OrderPayment {
  const OrderPayment({required this.id, required this.status, required this.provider, this.reference, this.amountMinor, this.currency, this.metadata});
  final int id;
  final String status;
  final String provider;
  final String? reference;
  final int? amountMinor;
  final String? currency;
  final Map<String, dynamic>? metadata;
}
