import 'package:clothing_app/features/receipts/data/models/receipt_model.dart';
import 'package:clothing_app/features/receipts/data/services/receipt_pdf_service.dart';
import 'package:clothing_app/features/receipts/domain/entities/receipt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReceiptModel', () {
    test('maps persisted order snapshots and unpaid status', () {
      final receipt = ReceiptModel.fromResponses(
        order: {
          'data': {
            'number': 'ORD-1001',
            'payment_status': 'pending',
            'fulfillment_status': 'pending_payment',
            'subtotal_minor': 12000,
            'discount_minor': 0,
            'delivery_fee_minor': 500,
            'total_minor': 12500,
            'currency': 'USD',
            'items': [
              {
                'product_name': 'Linen trousers',
                'size': 'M',
                'color': 'Sand',
                'unit_price_minor': 6000,
                'quantity': 2,
                'line_total_minor': 12000,
              },
            ],
            'payment': {'status': 'pending', 'provider': 'khqr'},
            'address': {
              'recipient_name': 'A Customer',
              'phone': '012345678',
              'address_line': '12 Market Street',
              'province': 'Phnom Penh',
            },
          },
        },
      );

      expect(receipt.paymentStatus, 'pending');
      expect(receipt.transactionId, isEmpty);
      expect(receipt.number, 'ORD-1001');
      expect(receipt.currency, 'USD');
      expect(receipt.totalMinor, 12500);
      expect(receipt.discountMinor, 0);
      expect(receipt.items, hasLength(1));
      expect(receipt.items.single.subtotalMinor, 12000);
      expect(receipt.deliveryAddress, '12 Market Street, Phnom Penh');
    });

    test('maps verified bill reference and multiple persisted items', () {
      final receipt = ReceiptModel.fromResponses(
        order: {
          'data': {
            'number': 'ORD-1002',
            'payment_status': 'paid',
            'fulfillment_status': 'processing',
            'subtotal_minor': 15000,
            'discount_minor': 2000,
            'delivery_fee_minor': 0,
            'total_minor': 13000,
            'currency': 'USD',
            'items': [
              {
                'product_name': 'A very long product name',
                'size': 'L',
                'color': 'Black',
                'unit_price_minor': 10000,
                'quantity': 1,
                'line_total_minor': 10000,
              },
              {
                'product_name': 'Cotton shirt',
                'size': 'S',
                'color': 'White',
                'unit_price_minor': 5000,
                'quantity': 1,
                'line_total_minor': 5000,
              },
            ],
            'payment': {
              'status': 'paid',
              'provider': 'khqr',
              'paid_at': '2026-10-31T12:00:00Z',
            },
            'address': {'address_line': 'A long delivery address'},
          },
        },
        bill: {
          'data': {
            'receipt_number': 'RCP-ABC123',
            'issued_at': '2026-10-31T12:01:00Z',
            'payload': {
              'payment_breakdown': [
                {
                  'reference': 'BAKONG-TXN-456',
                  'paid_at': '2026-10-31T12:00:00Z',
                },
              ],
              'amount_minor': 1000,
            },
          },
        },
      );

      expect(receipt.paymentStatus, 'paid');
      expect(receipt.number, 'RCP-ABC123');
      expect(receipt.transactionId, 'BAKONG-TXN-456');
      expect(receipt.items, hasLength(2));
      expect(receipt.totalMinor, 13000);
      expect(receipt.discountMinor, 2000);
      expect(receipt.deliveryFeeMinor, 0);
    });

    test('does not infer paid status or optional customer data', () {
      final receipt = ReceiptModel.fromResponses(
        order: {
          'number': 'ORD-1003',
          'payment': {'status': 'failed'},
          'items': const [],
        },
      );

      expect(receipt.paymentStatus, 'failed');
      expect(receipt.customerEmail, isEmpty);
      expect(receipt.customerPhone, isEmpty);
      expect(receipt.transactionId, isEmpty);
      expect(receipt.items, isEmpty);
    });

    test('maps a COD deposit and remaining delivery balance', () {
      final receipt = ReceiptModel.fromResponses(
        order: {
          'data': {
            'number': 'ORD-COD-1',
            'payment_status': 'partially_paid',
            'payment_method': 'cash',
            'total_minor': 10001,
            'amount_paid_minor': 5001,
            'remaining_balance_minor': 5000,
            'payment': {
              'status': 'partially_paid',
              'provider': 'aba_pay',
              'amount_minor': 5001,
            },
          },
        },
        bill: {
          'data': {
            'payload': {
              'receipt_type': 'deposit',
              'payment_breakdown': [
                {'amount_minor': 5001},
              ],
            },
          },
        },
      );

      expect(receipt.isCodDeposit, isTrue);
      expect(receipt.amountPaidMinor, 5001);
      expect(receipt.remainingBalanceMinor, 5000);
    });
  });

  test('escapes customer, address, and product values in HTML', () {
    const receipt = Receipt(
      number: 'RCP-1',
      orderNumber: 'ORD-1',
      currency: 'USD',
      paymentStatus: 'pending',
      items: [
        ReceiptItem(
          name: '<img src=x onerror=alert(1)>',
          quantity: 1,
          unitPriceMinor: 1000,
          subtotalMinor: 1000,
        ),
      ],
      subtotalMinor: 1000,
      discountMinor: 0,
      deliveryFeeMinor: 0,
      totalMinor: 1000,
      fulfillmentStatus: 'pending_payment',
      customerName: '<script>alert(1)</script>',
      customerPhone: '',
      customerEmail: '',
      deliveryAddress: '12 Main & <Street>',
      paymentMethod: 'khqr',
      transactionId: '',
    );

    final html = ReceiptPdfService.renderTemplate(
      '{{CUSTOMER_NAME}}|{{DELIVERY_ADDRESS}}|{{ITEM_ROWS}}|{{PAYMENT_STATUS}}',
      receipt,
    );

    expect(html, contains('&lt;script&gt;alert(1)&lt;/script&gt;'));
    expect(html, contains('12 Main &amp; &lt;Street&gt;'));
    expect(html, contains('&lt;img src=x onerror=alert(1)&gt;'));
    expect(html, isNot(contains('<script>')));
    expect(html, isNot(contains('<img src=x')));
    expect(html, contains('Pending'));
  });

  test('includes deposit and delivery balance in deposit receipt HTML', () {
    const receipt = Receipt(
      number: 'RCP-COD-1',
      orderNumber: 'ORD-COD-1',
      currency: 'USD',
      paymentStatus: 'partially_paid',
      items: [],
      subtotalMinor: 10001,
      discountMinor: 0,
      deliveryFeeMinor: 0,
      totalMinor: 10001,
      fulfillmentStatus: 'processing',
      customerName: 'Customer',
      customerPhone: '',
      customerEmail: '',
      deliveryAddress: '',
      paymentMethod: 'cash',
      transactionId: 'ABA-123',
      isCodDeposit: true,
      amountPaidMinor: 5001,
      remainingBalanceMinor: 5000,
    );

    final html = ReceiptPdfService.renderTemplate(
      '{{DEPOSIT_ROWS}}',
      receipt,
    );

    expect(html, contains('50% deposit paid'));
    expect(html, contains('\$50.01'));
    expect(html, contains('Remaining due at delivery'));
    expect(html, contains('\$50.00'));
  });
}
