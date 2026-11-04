import 'package:flutter/material.dart';

import '../controllers/catalog_controller.dart';

class SortDropdown extends StatelessWidget {
  const SortDropdown({super.key, required this.value, required this.onChanged});

  final ProductSort value;
  final ValueChanged<ProductSort> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<ProductSort>(
        value: value,
        isDense: true,
        isExpanded: true,
        icon: const Icon(Icons.swap_vert, size: 18),
        selectedItemBuilder: (context) => const [
          Align(alignment: Alignment.centerLeft, child: Text('Featured')),
          Align(alignment: Alignment.centerLeft, child: Text('Price UP')),
          Align(alignment: Alignment.centerLeft, child: Text('Price Down')),
          Align(alignment: Alignment.centerLeft, child: Text('Name')),
        ],
        onChanged: (next) {
          if (next != null) onChanged(next);
        },
        items: const [
          DropdownMenuItem(
              value: ProductSort.featured, child: Text('Featured')),
          DropdownMenuItem(
              value: ProductSort.priceLowToHigh,
              child: Text('Price: low to high')),
          DropdownMenuItem(
              value: ProductSort.priceHighToLow,
              child: Text('Price: high to low')),
          DropdownMenuItem(value: ProductSort.name, child: Text('Name')),
        ],
      ),
    );
  }
}
