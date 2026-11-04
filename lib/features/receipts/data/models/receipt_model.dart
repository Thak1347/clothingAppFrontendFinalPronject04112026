import '../../domain/entities/receipt.dart';

class ReceiptModel extends Receipt {
  const ReceiptModel({
    required super.number,
    required super.orderNumber,
    required super.currency,
    required super.paymentStatus,
    required super.items,
    required super.subtotalMinor,
    required super.discountMinor,
    required super.deliveryFeeMinor,
    required super.totalMinor,
    required super.fulfillmentStatus,
    required super.customerName,
    required super.customerPhone,
    required super.customerEmail,
    required super.deliveryAddress,
    required super.paymentMethod,
    required super.transactionId,
    super.isCodDeposit,
    super.amountPaidMinor,
    super.remainingBalanceMinor,
    super.orderDate,
    super.paymentDate,
    super.issuedAt,
  });

  factory ReceiptModel.fromResponses({
    required dynamic order,
    dynamic bill,
  }) {
    final orderData = _unwrap(order);
    final payment = _asMap(orderData['payment']);
    final billData = bill == null ? <String, dynamic>{} : _unwrap(bill);
    final payload = _asMap(billData['payload']);
    final address = _asMap(orderData['address']);
    final codCustomer = _asMap(orderData['cod_customer']);
    final rawOrderItems = orderData['items'] is List
        ? orderData['items'] as List
        : const <dynamic>[];
    final rawBillItems =
        payload['items'] is List ? payload['items'] as List : const <dynamic>[];
    final itemSource = rawOrderItems.isNotEmpty ? rawOrderItems : rawBillItems;
    final rawBreakdown = payload['payment_breakdown'] is List
        ? payload['payment_breakdown'] as List
        : const <dynamic>[];
    final paymentBreakdown = rawBreakdown
        .whereType<Map>()
        .map((entry) => Map<String, dynamic>.from(entry))
        .toList();
    final transactionId = paymentBreakdown
        .map((entry) => _string(entry['reference']))
        .firstWhere((value) => value.isNotEmpty, orElse: () => '');

    final orderStatus = _string(orderData['payment_status']);
    final paymentStatus = _string(payment['status']);
    final status = orderStatus.isNotEmpty ? orderStatus : paymentStatus;
    final orderPaymentMethod = _string(orderData['payment_method']);
    final paymentMethod = orderPaymentMethod.isNotEmpty
        ? orderPaymentMethod
        : _string(payment['provider']);
    final isCodDeposit = _string(payload['receipt_type']) == 'deposit' ||
        (paymentMethod == 'cash' && status == 'partially_paid');
    final amountPaidMinor = orderData['amount_paid_minor'] is num
        ? _integer(orderData['amount_paid_minor'])
        : paymentBreakdown.isNotEmpty
            ? paymentBreakdown.fold<int>(
                0,
                (sum, entry) => sum + _integer(entry['amount_minor']),
              )
            : _integer(payment['amount_minor']);
    final calculatedBalance =
        _integer(orderData['total_minor']) - amountPaidMinor;
    final remainingBalanceMinor = orderData['remaining_balance_minor'] is num
        ? _integer(orderData['remaining_balance_minor'])
        : calculatedBalance > 0
            ? calculatedBalance
            : 0;
    final addressParts = [
      _string(address['address_line']),
      _string(address['province']),
    ].where((part) => part.isNotEmpty).toList();
    final codAddress = _string(codCustomer['address']);

    return ReceiptModel(
      number: _string(billData['receipt_number']).isNotEmpty
          ? _string(billData['receipt_number'])
          : _string(orderData['number']),
      orderNumber: _string(orderData['number']),
      currency: _string(orderData['currency']).isNotEmpty
          ? _string(orderData['currency'])
          : _string(payment['currency']).isNotEmpty
              ? _string(payment['currency'])
              : 'USD',
      paymentStatus: status.isEmpty ? 'pending' : status,
      items: itemSource.whereType<Map>().map((rawItem) {
        final item = Map<String, dynamic>.from(rawItem);
        final quantity = _integer(item['quantity'] ?? item['qty']);
        final priceMinor = item['unit_price_minor'] is num
            ? _integer(item['unit_price_minor'])
            : _minor(item['price']);
        return ReceiptItem(
          name: _string(item['product_name'] ?? item['name']),
          quantity: quantity,
          unitPriceMinor: priceMinor,
          subtotalMinor: item['line_total_minor'] is num
              ? _integer(item['line_total_minor'])
              : priceMinor * quantity,
          size: _optionalString(item['size']),
          color: _optionalString(item['color']),
        );
      }).toList(),
      subtotalMinor: _integer(orderData['subtotal_minor']),
      discountMinor: _integer(orderData['discount_minor']),
      deliveryFeeMinor: _integer(orderData['delivery_fee_minor']),
      totalMinor: _integer(orderData['total_minor']),
      fulfillmentStatus: _string(orderData['fulfillment_status']),
      customerName: _firstNonEmpty([
        _string(address['recipient_name']),
        _string(codCustomer['name']),
      ]),
      customerPhone: _firstNonEmpty([
        _string(address['phone']),
        _string(codCustomer['phone']),
      ]),
      customerEmail: _string(codCustomer['email']),
      deliveryAddress:
          codAddress.isNotEmpty ? codAddress : addressParts.join(', '),
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      isCodDeposit: isCodDeposit,
      amountPaidMinor: amountPaidMinor,
      remainingBalanceMinor: remainingBalanceMinor,
      orderDate: DateTime.tryParse(_string(orderData['created_at'])),
      paymentDate: DateTime.tryParse(
        _firstNonEmpty([
          _string(payload['paid_at']),
          _string(payment['paid_at']),
        ]),
      ),
      issuedAt: DateTime.tryParse(_string(billData['issued_at'])),
    );
  }
}

Map<String, dynamic> _unwrap(dynamic value) {
  final root = _asMap(value);
  return root['data'] is Map ? _asMap(root['data']) : root;
}

Map<String, dynamic> _asMap(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};

String _string(dynamic value) => value?.toString().trim() ?? '';

String? _optionalString(dynamic value) {
  final result = _string(value);
  return result.isEmpty ? null : result;
}

String _firstNonEmpty(Iterable<String> values) =>
    values.firstWhere((value) => value.isNotEmpty, orElse: () => '');

int _integer(dynamic value) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? 0;

int _minor(dynamic value) {
  final amount = value is num ? value.toDouble() : double.tryParse('$value');
  return amount == null ? 0 : (amount * 100).round();
}
