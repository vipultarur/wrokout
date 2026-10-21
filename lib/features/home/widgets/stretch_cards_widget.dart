import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/models/exercise.dart';
import 'package:workout/features/home/providers/home_providers.dart';

class StretchCardsWidget extends ConsumerWidget {
  const StretchCardsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stretchMap = ref.watch(stretchExercisesProvider);
    final backRelief = stretchMap['backRelief'] ?? [];
    final lowerBody = stretchMap['lowerBody'] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStretchCard(
              context,
              title: 'Lower Back Pain Relief',
              subtitle: '5 min · ${backRelief.length} stretches',
              exercise: backRelief.isNotEmpty ? backRelief.first : null,
              onTap: () => context.push(AppRoutes.workoutSession, extra: 'Lower Back Pain Relief'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStretchCard(
              context,
              title: 'Lower Body Stretching',
              subtitle: '7 min · ${lowerBody.length} stretches',
              exercise: lowerBody.isNotEmpty ? lowerBody.first : null,
              onTap: () => context.push(AppRoutes.workoutSession, extra: 'Lower Body Stretching'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStretchCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Exercise? exercise,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (exercise != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  exercise.assetImagePath,
                  width: double.infinity,
                  height: 80,
                  cacheWidth: 300,
                  cacheHeight: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: double.infinity,
                    height: 80,
                    color: Colors.cyanAccent.withAlpha(30),
                    child: const Center(
                      child: Icon(Icons.self_improvement_rounded, size: 30),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: context.secondaryText, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
