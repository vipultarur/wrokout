import 'package:flutter/material.dart';

/// App color tokens extracted from KREW Color Palette.
/// Designed for full double-theme (Dark Theme & Light Theme) support.
class AppColors {
  AppColors._();

  // ─── KREW Official Brand Palette ───
  /// Lime 300 - Soft vibrant accent (#D8F759)
  static const Color lime300 = Color(0xFFD8F759);

  /// Lime 400 - Electric primary brand lime (#C4F013)
  static const Color lime400 = Color(0xFFC4F013);

  /// Gray 50 - Light theme warm scaffold background (#F2F2ED)
  static const Color gray50 = Color(0xFFF2F2ED);

  /// White - Pure white for card surfaces (#FFFFFF)
  static const Color white = Color(0xFFFFFFFF);

  /// Gray 900 - Dark theme elevated card surface (#141411)
  static const Color gray900 = Color(0xFF141411);

  /// Black - Dark theme OLED background (#030302)
  static const Color black = Color(0xFF030302);

  // ─── Primary Accent & Brand ───
  static const Color paleLime = lime300;
  static const Color primary = lime400;
  static const Color primaryLight = lime300;
  static const Color primaryDark = Color(0xFFA6CC0C);
  static const Color primaryTextOnAccent = black;

  // ─── Legacy compatibility aliases ───
  static const Color raisinBlack = black;
  static const Color cottonSeedLight = gray50;
  static const Color cottonSeedDark = Color(0xFFA0A098);
  static const Color midGrey = Color(0xFF6B6B64);
  static const Color outerSpace = gray900;

  // ─── Dark Theme Surfaces (Black & Gray 900) ───
  static const Color darkBg = black;
  static const Color darkBackground = black;
  static const Color darkSurface = gray900;
  static const Color darkCard = gray900;
  static const Color darkCardAlt = Color(0xFF1B1B18);
  static const Color darkBorder = Color(0xFF2A2A24);

  // ─── Light Theme Surfaces (Gray 50 & White) ───
  static const Color lightBg = gray50;
  static const Color lightBackground = gray50;
  static const Color lightSurface = white;
  static const Color lightCard = white;
  static const Color lightCardAlt = Color(0xFFF7F7F2);
  static const Color lightBorder = Color(0xFFE2E2DC);

  // ─── Text Tokens ───
  static const Color textPrimaryDark = gray50;
  static const Color textSecondaryDark = Color(0xFFA0A098);
  static const Color textTertiaryDark = Color(0xFF707068);

  static const Color textPrimaryLight = black;
  static const Color textSecondaryLight = Color(0xFF666660);
  static const Color textTertiaryLight = Color(0xFF999990);

  // ─── Semantic Colors ───
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF29B6F6);

  // ─── Gradients ───
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [lime300, lime400],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [gray900, Color(0xFF1B1B18)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [white, Color(0xFFF7F7F2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Body Map Muscle Colors (Adaptive) ───
  static const Color muscleActive = lime400;
  static const Color muscleInactiveDark = gray900;
  static const Color muscleInactiveLight = Color(0xFFE2E2DC);
}

/// Extension helper on BuildContext for quick theme-adaptive styling.
extension BuildContextThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get scaffoldBg => isDarkMode ? AppColors.black : AppColors.gray50;
  Color get surfaceBg => isDarkMode ? AppColors.gray900 : AppColors.white;
  Color get cardBg => isDarkMode ? AppColors.gray900 : AppColors.white;
  Color get cardBorder => isDarkMode ? AppColors.darkBorder : AppColors.lightBorder;
  Color get primaryText => colorScheme.onSurface;
  Color get secondaryText => colorScheme.onSurfaceVariant;
  Color get tertiaryText => isDarkMode ? AppColors.textTertiaryDark : AppColors.textTertiaryLight;
  Color get accentColor => AppColors.lime400;
  Color get iconColor => colorScheme.onSurface;
}
