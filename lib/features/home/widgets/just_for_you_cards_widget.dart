import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/features/home/providers/home_providers.dart';

class JustForYouCardsWidget extends ConsumerWidget {
  const JustForYouCardsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final justForYou = ref.watch(justForYouPresetsProvider);

    if (justForYou.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: justForYou.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final preset = justForYou[index];
          final img = preset.exercises.first;

          return GestureDetector(
            onTap: () => context.push(AppRoutes.workoutSession, extra: preset.title),
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.cardBorder),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      img.assetImagePath,
                      width: 70,
                      height: 70,
                      cacheWidth: 160,
                      cacheHeight: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 70,
                        color: Theme.of(context).colorScheme.primary.withAlpha(40),
                        child: const Icon(Icons.fitness_center),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          preset.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.primaryText,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          preset.subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: context.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
