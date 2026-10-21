import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:workout/common/widgets/app_icon.dart';
import 'package:workout/core/constants/app_routes.dart';
import 'package:workout/core/theme/app_colors.dart';
import 'package:workout/core/theme/theme_provider.dart';
import 'package:workout/data/models/user_profile.dart';
import 'package:workout/data/providers/user_profile_provider.dart';

/// Profile & Settings Screen with full Double Theme support.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: context.scaffoldBg,
      appBar: AppBar(
        backgroundColor: context.scaffoldBg,
        elevation: 0,
        title: Text(
          'My Profile & Settings',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: context.primaryText,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ─── 1. Avatar & Profile Header ───
            ProfileHeaderWidget(profile: profile),

            const SizedBox(height: 28),

            // ─── 2. Double Theme Switcher Card ───
            const SettingsSectionHeaderWidget(title: 'App Appearance & Theme'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        context.isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: context.isDarkMode ? AppColors.paleLime : AppColors.raisinBlack,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Double Theme Selector',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.primaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ThemeModeOptionWidget(
                          title: 'Dark',
                          icon: HugeIcons.strokeRoundedMoon02,
                          mode: ThemeMode.dark,
                          currentMode: themeMode,
                          onSelect: (m) => ref.read(themeModeProvider.notifier).setThemeMode(m),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ThemeModeOptionWidget(
                          title: 'Light',
                          icon: HugeIcons.strokeRoundedSun01,
                          mode: ThemeMode.light,
                          currentMode: themeMode,
                          onSelect: (m) => ref.read(themeModeProvider.notifier).setThemeMode(m),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ThemeModeOptionWidget(
                          title: 'System',
                          icon: HugeIcons.strokeRoundedComputer,
                          mode: ThemeMode.system,
                          currentMode: themeMode,
                          onSelect: (m) => ref.read(themeModeProvider.notifier).setThemeMode(m),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── 3. Profile Details Group ───
            const SettingsSectionHeaderWidget(title: 'My Fitness Profile'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.cardBorder),
              ),
              child: Column(
                children: [
                  ProfileRowWidget(label: 'Gender', value: profile.gender?.toUpperCase() ?? 'MALE'),
                  Divider(color: context.cardBorder, height: 1),
                  ProfileRowWidget(label: 'Weight', value: profile.displayWeight),
                  Divider(color: context.cardBorder, height: 1),
                  ProfileRowWidget(label: 'Height', value: profile.displayHeight),
                  Divider(color: context.cardBorder, height: 1),
                  ProfileRowWidget(label: 'Activity Level', value: profile.activityLevel ?? 'Light'),
                  Divider(color: context.cardBorder, height: 1),
                  ProfileRowWidget(label: 'Weekly Goal', value: '${profile.weeklyGoalDays} days / week'),
                  Divider(color: context.cardBorder, height: 1),
                  ProfileRowWidget(label: 'First Day of Week', value: profile.firstDayOfWeek),
                  Divider(color: context.cardBorder, height: 1),
                  ProfileRowWidget(
                    label: 'Focus Areas',
                    value: profile.focusAreas.isEmpty
                        ? 'Full Body'
                        : profile.focusAreas.join(', '),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── 4. Preferences & App Settings ───
            const SettingsSectionHeaderWidget(title: 'Preferences'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.cardBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Sound Effects & Voice Cues',
                      style: TextStyle(color: context.primaryText, fontSize: 14),
                    ),
                    subtitle: Text(
                      'Play countdown and rest timers sound',
                      style: TextStyle(color: context.secondaryText, fontSize: 11),
                    ),
                    value: profile.soundEnabled,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) {
                      ref
                          .read(userProfileProvider.notifier)
                          .updateSettings(soundEnabled: val);
                    },
                  ),
                  Divider(color: context.cardBorder, height: 1),
                  SwitchListTile(
                    title: Text(
                      'Vibration Cues',
                      style: TextStyle(color: context.primaryText, fontSize: 14),
                    ),
                    value: profile.vibrationEnabled,
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                    onChanged: (val) {
                      ref
                          .read(userProfileProvider.notifier)
                          .updateSettings(vibrationEnabled: val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── 5. Account & Data ───
            const SettingsSectionHeaderWidget(title: 'Account & Data'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: context.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.cardBorder),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: HugeIcon(
                      icon: HugeIcons.strokeRoundedRefresh,
                      color: context.isDarkMode ? AppColors.paleLime : AppColors.raisinBlack,
                    ),
                    title: Text(
                      'Re-take Fitness Onboarding',
                      style: TextStyle(color: context.primaryText, fontSize: 14),
                    ),
                    subtitle: Text(
                      'Re-calculate your recommended workouts',
                      style: TextStyle(color: context.secondaryText, fontSize: 11),
                    ),
                    trailing: HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: context.secondaryText,
                    ),
                    onTap: () {
                      context.go(AppRoutes.onboarding);
                    },
                  ),
                  Divider(color: context.cardBorder, height: 1),
                  ListTile(
                    leading: const HugeIcon(
                      icon: HugeIcons.strokeRoundedWaste,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      'Reset All App Data',
                      style: TextStyle(color: AppColors.error, fontSize: 14),
                    ),
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor: context.cardBg,
                          title: Text(
                            'Reset All Data?',
                            style: TextStyle(color: context.primaryText),
                          ),
                          content: Text(
                            'This will clear all onboarding answers and workout history.',
                            style: TextStyle(color: context.secondaryText),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('CANCEL'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text(
                                'RESET',
                                style: TextStyle(color: AppColors.error),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true && context.mounted) {
                        ref.read(userProfileProvider.notifier).resetProfile();
                        context.go(AppRoutes.onboarding);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }
}

class ProfileHeaderWidget extends StatelessWidget {
  final UserProfile profile;

  const ProfileHeaderWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(40),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2.5,
              ),
            ),
            child: Center(
              child: Text(
                profile.gender == 'female' ? '👩' : '👨',
                style: const TextStyle(fontSize: 42),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            profile.gender == 'female' ? 'Female Athlete' : 'Male Athlete',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: context.primaryText,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.paleLime,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'LEVEL: ${profile.fitnessLevel?.toUpperCase() ?? 'BEGINNER'}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: AppColors.raisinBlack,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThemeModeOptionWidget extends StatelessWidget {
  final String title;
  final dynamic icon;
  final ThemeMode mode;
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onSelect;

  const ThemeModeOptionWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.mode,
    required this.currentMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentMode == mode;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => onSelect(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (context.isDarkMode ? AppColors.raisinBlack : AppColors.cottonSeedLight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : context.cardBorder,
          ),
        ),
        child: Column(
          children: [
            AppIcon(
              icon: icon,
              size: 20,
              color: isSelected
                  ? AppColors.raisinBlack
                  : context.primaryText,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? AppColors.raisinBlack
                    : context.primaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsSectionHeaderWidget extends StatelessWidget {
  final String title;

  const SettingsSectionHeaderWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: context.secondaryText,
        ),
      ),
    );
  }
}

class ProfileRowWidget extends StatelessWidget {
  final String label;
  final String value;

  const ProfileRowWidget({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: context.secondaryText,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
