import 'package:clothing_app/core/utils/currency_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats currency with two decimal places', () {
    expect(CurrencyFormatter.format(12), r'$12.00');
  });
}
