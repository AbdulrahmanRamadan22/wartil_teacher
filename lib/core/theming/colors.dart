import 'package:flutter/material.dart';

/// Single source of truth for all app colors.
/// The old `AppColors` alias class has been removed — use `ColorsManager` directly.
class ColorsManager {
  ColorsManager._();

  // ─── Primary Palette ────────────────────────────────────────────────────
  /// Rich teal — main brand color
  static const Color primaryColor = Color(0xFF0D8A74);

  /// Darker teal — used for gradients, dark surfaces
  static const Color primaryDark = Color(0xFF066B5A);

  /// Lighter teal — gradient end
  static const Color primaryLight = Color(0xFF2BB89A);

  /// Secondary — muted navy/slate
  static const Color secondaryColor = Color(0xFF3D4B6B);

  /// Accent — warm saffron orange (replaces generic "orange")
  static const Color accentColor = Color(0xFFFF8C42);

  // ─── Status Colors ───────────────────────────────────────────────────────
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color infoColor = Color(0xFF3B82F6);

  // ─── Green Scale (gradient helpers) ─────────────────────────────────────
  static const Color greenExtraLight = Color(0xFFE0F7F4);
  static const Color greenLight = Color(0xFF4ECBA6);
  static const Color greenMedium = primaryColor;
  static const Color greenDark = primaryDark;

  // ─── Surface & Background ────────────────────────────────────────────────
  static const Color backgroundColor = Color(0xFFF6FAF9);
  static const Color surfaceColor = Colors.white;
  static const Color borderColor = Color(0xFFE0E7E5);
  static const Color dividerColor = Color(0xFFEBF1EF);

  // ─── Card tints ──────────────────────────────────────────────────────────
  static const Color lightMint = Color(0xFFDFF6F1);
  static const Color lightYellow = Color(0xFFFFF8E8);
  static const Color lightBlue = Color(0xFFE3F2FD);
  static const Color lightPink = Color(0xFFFFEBEE);
  static const Color darkGreen = Color(0xFF064E3B);

  // ─── Text ────────────────────────────────────────────────────────────────
  static const Color textPrimaryColor = Color(0xFF1A2E2B);
  static const Color textSecondaryColor = Color(0xFF607D78);
  static const Color textHintColor = Color(0xFFB0C4C0);
  static const Color textOnPrimary = Colors.white;

  // ─── Icons ───────────────────────────────────────────────────────────────
  static const Color iconPrimary = primaryColor;
  static const Color iconSecondary = textSecondaryColor;
  static const Color iconOnPrimary = Colors.white;

  // ─── Gradients ───────────────────────────────────────────────────────────
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryLight],
  );

  static const Gradient headerGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [primaryColor, primaryDark],
  );

  static const Gradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentColor, Color(0xFFFF6B1A)],
  );

  // ─── Shadows ─────────────────────────────────────────────────────────────
  static Color get cardShadow => primaryColor.withValues(alpha: 0.08);
  static const Color shadowColor = Colors.transparent;
}
