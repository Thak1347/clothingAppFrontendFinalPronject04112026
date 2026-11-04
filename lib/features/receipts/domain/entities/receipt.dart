class Receipt {
  const Receipt({
    required this.number,
    required this.orderNumber,
    required this.currency,
    required this.paymentStatus,
    required this.items,
    required this.subtotalMinor,
    required this.discountMinor,
    required this.deliveryFeeMinor,
    required this.totalMinor,
    required this.fulfillmentStatus,
    required this.customerName,
    required this.customerPhone,
    required this.customerEmail,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.transactionId,
    this.isCodDeposit = false,
    this.amountPaidMinor = 0,
    this.remainingBalanceMinor = 0,
    this.orderDate,
    this.paymentDate,
    this.issuedAt,
  });

  final String number;
  final String orderNumber;
  final String currency;
  final String paymentStatus;
  final List<ReceiptItem> items;
  final int subtotalMinor;
  final int discountMinor;
  final int deliveryFeeMinor;
  final int totalMinor;
  final String fulfillmentStatus;
  final String customerName;
  final String customerPhone;
  final String customerEmail;
  final String deliveryAddress;
  final String paymentMethod;
  final String transactionId;
  final bool isCodDeposit;
  final int amountPaidMinor;
  final int remainingBalanceMinor;
  final DateTime? orderDate;
  final DateTime? paymentDate;
  final DateTime? issuedAt;
}

class ReceiptItem {
  const ReceiptItem({
    required this.name,
    required this.quantity,
    required this.unitPriceMinor,
    required this.subtotalMinor,
    this.size,
    this.color,
  });

  final String name;
  final int quantity;
  final int unitPriceMinor;
  final int subtotalMinor;
  final String? size;
  final String? color;
}
