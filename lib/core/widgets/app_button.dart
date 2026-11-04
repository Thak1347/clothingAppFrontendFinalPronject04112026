import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.text, required this.onPressed, this.isLoading = false});
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: AppSpacing.minTouchTarget + 4,
        child: FilledButton(
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : Text(text),
        ),
      );
}
