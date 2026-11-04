import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: '\$', // Change to '៛' for Khmer Riel or your local currency
    decimalDigits: 2,
  );

  static String format(double amount) {
    return _formatter.format(amount);
  }
}