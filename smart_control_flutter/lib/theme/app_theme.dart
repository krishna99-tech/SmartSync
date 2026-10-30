import 'package:flutter/material.dart';

class AppColors {
  // Modern Smart Tech Blue Palette (Eliminated Orange)
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primarySoft = Color(0xFFEFF6FF);
  static const Color primaryBorder = Color(0xFFBFDBFE);

  // Backward-compatible alias for any residual references
  static const Color coral = Color(0xFF2563EB);
  static const Color coralLight = Color(0xFF3B82F6);
  static const Color coralDark = Color(0xFF1D4ED8);
  static const Color coralBg = Color(0xFF2563EB);
  static const Color coralSoft = Color(0xFFEFF6FF);
  static const Color coralBorder = Color(0xFFBFDBFE);

  // Status Colors
  static const Color online = Color(0xFF10B981);
  static const Color offline = Color(0xFFEF4444);

  // Classic Accents
  static const Color accent = Color(0xFF2563EB);
  static const Color accentDark = Color(0xFF1D4ED8);
  static const Color electricBlue = Color(0xFF2563EB);

  // Background Gradients
  static const List<Color> authDarkBg = [
    Color(0xFF0B0F19),
    Color(0xFF111827),
    Color(0xFF1E293B),
  ];

  static const List<Color> authLightBg = [
    Color(0xFFF8FAFC),
    Color(0xFFEFF6FF),
  ];

  static const List<Color> controlDarkBg = [
    Color(0xFF0A0A14),
    Color(0xFF131322),
  ];

  static const List<Color> controlLightBg = [
    Color(0xFFF8FAFC),
    Color(0xFFEFF6FF),
  ];

  static const List<Color> buttonGradient = [
    Color(0xFF2563EB),
    Color(0xFF1D4ED8),
  ];

  // Active Device Card Gradient (Clean, Professional Royal Blue - Non-Neon)
  static const List<Color> activeCardGradient = [
    Color(0xFF2563EB),
    Color(0xFF1D4ED8),
  ];

  static List<Color> cardInactive(bool isDark) => isDark
      ? [const Color(0xFF1B1B2C), const Color(0xFF141422)]
      : [Colors.white, const Color(0xFFFDFDFE)];

  static Color glass(bool isDark) => isDark
      ? const Color.fromRGBO(27, 27, 44, 0.85)
      : const Color.fromRGBO(255, 255, 255, 0.95);

  static Color glassNav(bool isDark) => isDark
      ? const Color.fromRGBO(18, 18, 30, 0.95)
      : const Color.fromRGBO(255, 255, 255, 0.98);

  static Color border(bool isDark) => isDark
      ? const Color.fromRGBO(255, 255, 255, 0.12)
      : const Color.fromRGBO(0, 0, 0, 0.07);

  static Color textMain(bool isDark) =>
      isDark ? const Color(0xFFF8FAFC) : const Color(0xFF1E293B);

  static Color textSub(bool isDark) =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  static Color inputBg(bool isDark) => isDark
      ? const Color(0xFF222233)
      : const Color(0xFFF5F6F8);

  static Color iconInactive(bool isDark) =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        brightness: Brightness.light,
        surface: Colors.white,
      ),
      fontFamily: null,
      cardColor: Colors.white,
      dividerColor: const Color(0xFFE2E8F0),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A14),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        brightness: Brightness.dark,
        surface: const Color(0xFF131322),
      ),
      fontFamily: null,
      cardColor: const Color(0xFF16162D),
      dividerColor: const Color(0xFF1E293B),
    );
  }
}
