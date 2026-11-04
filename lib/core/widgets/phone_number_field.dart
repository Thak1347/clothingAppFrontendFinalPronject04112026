import 'package:country_code_picker_plus/country_code_picker_plus.dart';
import 'package:flutter/material.dart';

import 'app_text_field.dart';

class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.controller,
    required this.countryCode,
    required this.onCountryCodeChanged,
    required this.label,
  });

  final TextEditingController controller;
  final String countryCode;
  final ValueChanged<String> onCountryCodeChanged;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CountryCodePicker(
            initialSelection: countryCode,
            favorite: const ['+855'],
            showDropDownButton: true,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
            onChanged: (country) {
              onCountryCodeChanged(country.dialCode);
            },
          ),
          Expanded(
            child: AppTextField(
              controller: controller,
              label: label,
              keyboardType: TextInputType.phone,
            ),
          ),
        ],
      );
}
