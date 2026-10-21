import 'package:flutter/material.dart';

/// Centralized layout spacing design system for consistent padding, margins, and gaps.
abstract class AppSpacing {
  // Numeric Values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // SizedBox Heights
  static const SizedBox h4 = SizedBox(height: xs);
  static const SizedBox h8 = SizedBox(height: sm);
  static const SizedBox h12 = SizedBox(height: md);
  static const SizedBox h16 = SizedBox(height: lg);
  static const SizedBox h20 = SizedBox(height: 20.0);
  static const SizedBox h24 = SizedBox(height: xl);
  static const SizedBox h32 = SizedBox(height: xxl);

  // SizedBox Widths
  static const SizedBox w4 = SizedBox(width: xs);
  static const SizedBox w8 = SizedBox(width: sm);
  static const SizedBox w12 = SizedBox(width: md);
  static const SizedBox w16 = SizedBox(width: lg);
  static const SizedBox w24 = SizedBox(width: xl);

  // Padding Insets
  static const EdgeInsets paddingZero = EdgeInsets.zero;
  static const EdgeInsets paddingAllSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingAllMd = EdgeInsets.all(md);
  static const EdgeInsets paddingAllLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingAllXl = EdgeInsets.all(xl);

  static const EdgeInsets paddingHorizLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingHorizXl = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets paddingScreen = EdgeInsets.symmetric(horizontal: xl, vertical: lg);
}
