import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/core/theme/app_colors.dart';

/// Modal dialog for renaming a custom workout training plan.
/// Matches exact layout and design from Image 5.
class EnterNameDialog extends StatefulWidget {
  final String initialName;

  const EnterNameDialog({
    super.key,
    this.initialName = 'New Training',
  });

  static Future<String?> show(BuildContext context, {String initialName = 'New Training'}) {
    return showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => EnterNameDialog(initialName: initialName),
    );
  }

  @override
  State<EnterNameDialog> createState() => _EnterNameDialogState();
}

class _EnterNameDialogState extends State<EnterNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: context.cardBg,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Name',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: context.primaryText,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              autofocus: true,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.primaryText,
              ),
              decoration: InputDecoration(
                hintText: 'New Training',
                hintStyle: TextStyle(
                  color: context.secondaryText,
                  fontWeight: FontWeight.normal,
                ),
                filled: true,
                fillColor: context.isDarkMode
                    ? AppColors.darkCardAlt
                    : const Color(0xFFF3F3F3),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit01,
                    color: context.secondaryText,
                    size: 20,
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryColor, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: context.secondaryText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    final text = _controller.text.trim();
                    Navigator.of(context).pop(text.isNotEmpty ? text : 'New Training');
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
