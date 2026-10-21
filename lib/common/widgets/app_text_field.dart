import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/theme/app_colors.dart';

enum AppTextFieldVariant { regular, password, search, multiline }

/// Standardized input field widget supporting multiple variants (Regular, Password, Search, Multiline).
class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final AppTextFieldVariant variant;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final bool autofocus;

  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.variant = AppTextFieldVariant.regular,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.autofocus = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.variant == AppTextFieldVariant.password;
    final isSearch = widget.variant == AppTextFieldVariant.search;
    final isMultiline = widget.variant == AppTextFieldVariant.multiline;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.primaryText,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          validator: widget.validator,
          obscureText: isPassword && _obscureText,
          autofocus: widget.autofocus,
          maxLines: isMultiline ? 4 : 1,
          minLines: isMultiline ? 3 : 1,
          keyboardType: widget.keyboardType ??
              (isMultiline
                  ? TextInputType.multiline
                  : isSearch
                      ? TextInputType.text
                      : TextInputType.text),
          style: TextStyle(color: context.primaryText, fontSize: 14),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: TextStyle(color: context.secondaryText, fontSize: 14),
            prefixIcon: isSearch
                ? HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    color: context.isDarkMode ? AppColors.lime400 : AppColors.black,
                    size: 20,
                  )
                : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: HugeIcon(
                      icon: _obscureText
                          ? HugeIcons.strokeRoundedViewOffSlash
                          : HugeIcons.strokeRoundedView,
                      color: context.secondaryText,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: context.cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: context.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: primaryColor, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
