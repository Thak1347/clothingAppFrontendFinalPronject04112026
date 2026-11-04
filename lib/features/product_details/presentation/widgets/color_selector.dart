import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

class ColorSelector extends StatelessWidget {
  const ColorSelector(
      {super.key,
      required this.colors,
      required this.selected,
      required this.isAvailable,
      required this.onSelected});

  final List<String> colors;
  final String? selected;
  final bool Function(String) isAvailable;
  final ValueChanged<String> onSelected;

  Color _swatchColor(String value) {
    final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    const names = <String, Color>{
      'black': Colors.black,
      'white': Colors.white,
      'navy': Color(0xFF1D2D50),
      'blue': Colors.blue,
      'red': Colors.red,
      'green': Colors.green,
      'olive': Color(0xFF777744),
      'beige': Color(0xFFD9C8A5),
      'cream': Color(0xFFF2E9D8),
      'brown': Colors.brown,
      'pink': Colors.pink,
      'grey': Colors.grey,
      'gray': Colors.grey,
    };
    return names[normalized] ?? AppColors.terracotta;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: colors.map((color) {
        final available = isAvailable(color);
        final chosen = selected == color;
        return Tooltip(
          message: color,
          child: InkWell(
            onTap: available ? () => onSelected(color) : null,
            customBorder: const CircleBorder(),
            child: Container(
              width: AppSpacing.minTouchTarget,
              height: AppSpacing.minTouchTarget,
              alignment: Alignment.center,
              child: Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: chosen ? AppColors.ink : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _swatchColor(color),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: !available
                      ? const Center(
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: AppColors.inkMuted,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
