import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/receipt.dart';

class ReceiptPdfService {
  ReceiptPdfService({HtmlToPdfConverter? converter})
      : _converter = converter ?? HtmlToPdfConverter();

  static const _templateAsset = 'assets/templates/receipt.html';
  final HtmlToPdfConverter _converter;

  Future<File> generate(Receipt receipt) async {
    final template = await rootBundle.loadString(_templateAsset);
    final html = renderTemplate(template, receipt);
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final outputDirectory = Directory(
      '${documentsDirectory.path}${Platform.pathSeparator}receipts',
    );
    await outputDirectory.create(recursive: true);

    final safeNumber = receipt.number
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '-')
        .replaceAll(RegExp('-+'), '-');
    final file = await _converter.convertHtmlToPdf(
      html: html,
      targetDirectory: outputDirectory.path,
      targetName: 'receipt-${safeNumber.isEmpty ? 'order' : safeNumber}',
      pageSize: PdfPageSize.a4,
    );
    if (!await file.exists() || await file.length() == 0) {
      throw StateError('The PDF converter returned an empty receipt file.');
    }
    return file;
  }

  static String renderTemplate(String template, Receipt receipt) {
    final items =
        receipt.items.map((item) => _renderItem(item, receipt.currency)).join();
    final values = <String, String>{
      'STORE_NAME': 'ÉTOFFE Atelier',
      'STORE_ADDRESS': '',
      'STORE_CONTACT': '',
      'RECEIPT_TITLE':
          receipt.isCodDeposit ? 'Deposit receipt' : 'Order receipt',
      'ORDER_NUMBER': receipt.orderNumber,
      'ORDER_DATE': _formatDate(receipt.orderDate),
      'FULFILLMENT_STATUS': _formatStatus(receipt.fulfillmentStatus),
      'PAYMENT_STATUS': _formatStatus(receipt.paymentStatus),
      'PAYMENT_STATUS_CLASS': _statusClass(receipt.paymentStatus),
      'CUSTOMER_NAME': _displayValue(receipt.customerName),
      'CUSTOMER_PHONE': _displayValue(receipt.customerPhone),
      'CUSTOMER_EMAIL': _displayValue(receipt.customerEmail),
      'DELIVERY_ADDRESS': _displayValue(receipt.deliveryAddress),
      'DELIVERY_PHONE': _displayValue(receipt.customerPhone),
      'SUBTOTAL': _formatMoney(receipt.subtotalMinor, receipt.currency),
      'DISCOUNT': _formatMoney(receipt.discountMinor, receipt.currency),
      'DELIVERY_FEE': _formatMoney(receipt.deliveryFeeMinor, receipt.currency),
      'GRAND_TOTAL': _formatMoney(receipt.totalMinor, receipt.currency),
      'DEPOSIT_ROWS': receipt.isCodDeposit
          ? '''
            <div class="total-row">
              <span class="muted">50% deposit paid</span>
              <span>${_escapeHtml(_formatMoney(receipt.amountPaidMinor, receipt.currency))}</span>
            </div>
            <div class="total-row">
              <span class="muted">Remaining due at delivery</span>
              <span>${_escapeHtml(_formatMoney(receipt.remainingBalanceMinor, receipt.currency))}</span>
            </div>
          '''
          : '',
      'PAYMENT_METHOD': receipt.isCodDeposit
          ? 'Cash on delivery · ABA Pay deposit'
          : _formatStatus(receipt.paymentMethod),
      'TRANSACTION_ID': _displayValue(receipt.transactionId),
      'PAYMENT_DATE': _formatDate(receipt.paymentDate),
      'RECEIPT_REFERENCE': _displayValue(receipt.number),
      'ITEM_ROWS': items.isEmpty
          ? '<tr><td class="empty-row" colspan="4">No product details available.</td></tr>'
          : items,
    };

    return template.replaceAllMapped(
      RegExp(r'\{\{([A-Z_]+)\}\}'),
      (match) {
        final key = match.group(1)!;
        final value = values[key] ?? '';
        return key == 'ITEM_ROWS' ||
                key == 'PAYMENT_STATUS_CLASS' ||
                key == 'DEPOSIT_ROWS'
            ? value
            : _escapeHtml(value);
      },
    );
  }

  static String _renderItem(ReceiptItem item, String currency) {
    final variants = [
      if (item.size?.isNotEmpty ?? false) 'Size ${item.size}',
      if (item.color?.isNotEmpty ?? false) 'Color ${item.color}',
    ].join(' · ');
    final variantHtml = variants.isEmpty
        ? ''
        : '<div class="product-variant">${_escapeHtml(variants)}</div>';
    return '''
      <tr>
        <td class="product-cell">
          <div class="product-name">${_escapeHtml(item.name)}</div>
          $variantHtml
        </td>
        <td class="right amount">${_escapeHtml(_formatMoney(item.unitPriceMinor, currency))}</td>
        <td class="right quantity">${item.quantity}</td>
        <td class="right amount">${_escapeHtml(_formatMoney(item.subtotalMinor, currency))}</td>
      </tr>
    ''';
  }

  static String _formatMoney(int minor, String currency) {
    final amount = NumberFormat('#,##0.00').format(minor / 100);
    return currency.toUpperCase() == 'USD' ? '\$$amount' : '$currency $amount';
  }

  static String _formatDate(DateTime? date) => date == null
      ? 'Not available'
      : DateFormat('MMM d, yyyy · h:mm a').format(date.toLocal());

  static String _displayValue(String value) =>
      value.trim().isEmpty ? 'Not provided' : value;

  static String _formatStatus(String value) {
    if (value.trim().isEmpty) return 'Pending';
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  static String _statusClass(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'partially_paid':
        return 'status-paid';
      case 'failed':
        return 'status-failed';
      case 'expired':
        return 'status-expired';
      case 'refunded':
      case 'partially_refunded':
      case 'refund_pending':
        return 'status-refunded';
      default:
        return 'status-pending';
    }
  }

  static String _escapeHtml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
