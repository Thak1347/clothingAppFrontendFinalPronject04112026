class CheckoutPreview {
  const CheckoutPreview({required this.items, required this.subtotalMinor, required this.deliveryFeeMinor, required this.totalMinor, required this.currency});
  final List<CheckoutLine> items;
  final int subtotalMinor;
  final int deliveryFeeMinor;
  final int totalMinor;
  final String currency;
}

class CheckoutLine {
  const CheckoutLine({required this.name, required this.size, required this.color, required this.quantity, required this.unitPriceMinor, required this.lineTotalMinor});
  final String name;
  final String? size;
  final String? color;
  final int quantity;
  final int unitPriceMinor;
  final int lineTotalMinor;
}
