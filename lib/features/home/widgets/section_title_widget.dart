import 'package:flutter/material.dart';
import 'package:workout/core/theme/app_colors.dart';

class SectionTitleWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onMore;

  const SectionTitleWidget({
    super.key,
    required this.title,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: context.primaryText,
            ),
          ),
          if (onMore != null)
            GestureDetector(
              onTap: onMore,
              child: Row(
                children: [
                  Text(
                    'More',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: context.isDarkMode ? AppColors.paleLime : AppColors.raisinBlack,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 16, color: context.isDarkMode ? AppColors.paleLime : AppColors.raisinBlack),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
