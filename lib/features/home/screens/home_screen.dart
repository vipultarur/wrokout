import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/data/providers/exercise_provider.dart';
import 'package:workout/data/providers/user_profile_provider.dart';
import 'package:workout/features/home/widgets/body_focus_widgets.dart';
import 'package:workout/features/home/widgets/challenge_carousel_widget.dart';
import 'package:workout/features/home/widgets/create_custom_banner_widget.dart';
import 'package:workout/features/home/widgets/explore_more_banner_widget.dart';
import 'package:workout/features/home/widgets/just_for_you_cards_widget.dart';
import 'package:workout/features/home/widgets/popular_goals_widgets.dart';
import 'package:workout/features/home/widgets/recommended_banner_widget.dart';
import 'package:workout/features/home/widgets/search_bar_widget.dart';
import 'package:workout/features/home/widgets/section_title_widget.dart';
import 'package:workout/features/home/widgets/stretch_cards_widget.dart';
import 'package:workout/features/home/widgets/weekly_goal_header_card.dart';

/// Main Training Dashboard Screen with complete Double Theme support.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'HOME WORKOUT',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: context.primaryText,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.water_drop_rounded, color: Colors.redAccent),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Hydration tracker: 1.5L logged today! 💧'),
                  backgroundColor: context.cardBg,
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB703), Color(0xFFFB8500)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      size: 14, color: Colors.black),
                  SizedBox(width: 4),
                  Text(
                    'PRO+',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userProfileProvider);
          ref.invalidate(allExercisesProvider);
        },
        color: theme.colorScheme.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            // ─── 1. Search Bar ───
            const SearchBarWidget(),

            const SizedBox(height: 20),

            // ─── 2. Weekly Goal Calendar ───
            const RepaintBoundary(child: WeeklyGoalHeaderCard()),

            const SizedBox(height: 24),

            // ─── 3. Challenge Carousel ───
            SectionTitleWidget(
              title: 'Challenge',
              onMore: () => context.push(AppRoutes.challenge),
            ),
            const SizedBox(height: 12),
            const RepaintBoundary(child: ChallengeCarouselWidget()),

            const SizedBox(height: 24),

            // ─── 4. Body Focus Section ───
            const SectionTitleWidget(title: 'Body Focus'),
            const SizedBox(height: 12),
            const BodyFocusTabsWidget(),
            const SizedBox(height: 14),
            const RepaintBoundary(child: BodyFocusListWidget()),

            const SizedBox(height: 24),

            // ─── 5. Custom Workout Banner ───
            const RepaintBoundary(child: CreateCustomBannerWidget()),

            const SizedBox(height: 24),

            // ─── 7. Recommended Section ───
            const SectionTitleWidget(title: 'Recommended'),
            const SizedBox(height: 12),
            const RepaintBoundary(child: RecommendedBannerWidget()),

            const SizedBox(height: 24),

            // ─── 8. Just For You ───
            SectionTitleWidget(
              title: 'Just For You',
              onMore: () => context.go(AppRoutes.exercises),
            ),
            const SizedBox(height: 12),
            const RepaintBoundary(child: JustForYouCardsWidget()),

            const SizedBox(height: 24),

            // ─── 9. Stretch & Warm Up ───
            SectionTitleWidget(
              title: 'Stretch & Warm Up',
              onMore: () => context.go(AppRoutes.exercises),
            ),
            const SizedBox(height: 12),
            const RepaintBoundary(child: StretchCardsWidget()),

            const SizedBox(height: 24),

            // ─── 10. Popular Goals ───
            const SectionTitleWidget(title: 'Popular Goals'),
            const SizedBox(height: 12),
            const PopularGoalsTabsWidget(),
            const SizedBox(height: 14),
            const RepaintBoundary(child: PopularGoalsListWidget()),

            const SizedBox(height: 24),

            // ─── 11. Bottom Explore Banner & Feedback Link ───
            const RepaintBoundary(child: ExploreMoreBannerWidget()),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

