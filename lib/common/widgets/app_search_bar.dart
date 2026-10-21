import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/theme/app_colors.dart';

/// Centralized common search bar widget matching Image 1 & 2 UI across Search, Exercises, Home, and Sheets.
class AppSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onClear;
  final bool readOnly;
  final bool autofocus;
  final Widget? suffix;
  final EdgeInsetsGeometry padding;

  const AppSearchBar({
    super.key,
    this.controller,
    this.hintText = 'Search workouts, plans...',
    this.onChanged,
    this.onTap,
    this.onClear,
    this.readOnly = false,
    this.autofocus = false,
    this.suffix,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final hasText = widget.controller != null && widget.controller!.text.isNotEmpty;
    final isActive = _isFocused || hasText;

    return Padding(
      padding: widget.padding,
      child: GestureDetector(
        onTap: widget.readOnly ? widget.onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            color: context.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isActive ? primaryColor : context.cardBorder,
              width: isActive ? 1.5 : 1.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: primaryColor.withAlpha(40),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: widget.readOnly
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        color: primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.hintText,
                          style: TextStyle(
                            fontSize: 14,
                            color: context.secondaryText,
                          ),
                        ),
                      ),
                      if (widget.suffix != null) widget.suffix!,
                    ],
                  ),
                )
              : TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: (val) {
                    setState(() {});
                    if (widget.onChanged != null) widget.onChanged!(val);
                  },
                  autofocus: widget.autofocus,
                  style: TextStyle(
                    color: context.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlignVertical: TextAlignVertical.center,
                  decoration: InputDecoration(
                    hintText: widget.hintText,
                    hintStyle: TextStyle(
                      color: context.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: HugeIcon(
                        icon: HugeIcons.strokeRoundedSearch01,
                        color: primaryColor,
                        size: 20,
                      ),
                    ),
                    suffixIcon: hasText
                        ? GestureDetector(
                            onTap: widget.onClear,
                            child: Icon(
                              Icons.cancel_rounded,
                              color: context.secondaryText,
                              size: 18,
                            ),
                          )
                        : widget.suffix,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
