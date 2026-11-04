import '../../domain/entities/address.dart';

class AddressModel extends Address {
  const AddressModel({super.id, super.label, required super.recipientName, required super.phone, required super.addressLine, required super.province, super.isDefault});
  factory AddressModel.fromJson(Map<String, dynamic> json) => AddressModel(
        id: json['id'] == null ? null : (json['id'] as num).toInt(),
        label: json['label'] as String?,
        recipientName: json['recipient_name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        addressLine: json['address_line'] as String? ?? '',
        province: json['province'] as String? ?? '',
        isDefault: json['is_default'] as bool? ?? false,
      );
  Map<String, dynamic> toJson() => {
        if (label != null && label!.isNotEmpty) 'label': label,
        'recipient_name': recipientName,
        'phone': phone,
        'address_line': addressLine,
        'province': province,
        'is_default': isDefault,
      };
}
