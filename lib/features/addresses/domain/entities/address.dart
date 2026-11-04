class Address {
  const Address({this.id, this.label, required this.recipientName, required this.phone, required this.addressLine, required this.province, this.isDefault = false});
  final int? id;
  final String? label;
  final String recipientName;
  final String phone;
  final String addressLine;
  final String province;
  final bool isDefault;
}
