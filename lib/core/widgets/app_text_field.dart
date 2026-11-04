import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_colors.dart';

/// Shared form field using the application's input theme.
///
/// `obscureText` fields include an accessible visibility toggle by default.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.showPasswordToggle = true,
    this.validator,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.prefixIcon,
    this.suffixIcon,
    this.prefixText,
    this.helperText,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.focusNode,
    this.onChanged,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool showPasswordToggle;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? prefixText;
  final String? helperText;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _isObscured = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showToggle = widget.obscureText && widget.showPasswordToggle;
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      keyboardType: widget.keyboardType ??
          (widget.obscureText ? TextInputType.visiblePassword : null),
      textInputAction: widget.textInputAction ??
          (widget.maxLines > 1
              ? TextInputAction.newline
              : TextInputAction.next),
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      autofillHints: widget.autofillHints,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: _isObscured,
      validator: widget.validator,
      minLines: widget.maxLines == 1 ? null : widget.minLines,
      maxLines: _isObscured ? 1 : widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        fillColor:
            widget.enabled ? null : AppColors.surfaceDim.withValues(alpha: .28),
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon,
        prefixText: widget.prefixText,
        suffixIcon: widget.suffixIcon ??
            (showToggle
                ? IconButton(
                    tooltip: _isObscured ? 'Show password' : 'Hide password',
                    onPressed: widget.enabled
                        ? () => setState(() => _isObscured = !_isObscured)
                        : null,
                    icon: Icon(_isObscured
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                  )
                : null),
        alignLabelWithHint: widget.maxLines > 1,
        errorMaxLines: 2,
      ),
    );
  }
}
