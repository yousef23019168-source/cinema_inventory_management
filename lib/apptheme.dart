import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color seed = Color(0xFF244C66);

  // Brand and status colors (same in light and dark)
  static const Color accent = Color(0xFFF2B84B);
  static const Color onAccent = Color(0xFF1A1203);
  static const Color success = Color(0xFF3DD68C);
  static const Color info = Color(0xFF5AA9E6);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color purple = Color(0xFFB58CFF);

  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    var scheme = ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    if (brightness == Brightness.dark) {
      scheme = scheme.copyWith(
        surface: const Color(0xFF0D141C),
        surfaceContainerLowest: const Color(0xFF0A1017),
        surfaceContainerLow: const Color(0xFF162130),
        surfaceContainer: const Color(0xFF162130),
        surfaceContainerHigh: const Color(0xFF1E2C3D),
        surfaceContainerHighest: const Color(0xFF243447),
        outlineVariant: const Color(0xFF2A3A4E),
        onSurfaceVariant: const Color(0xFF93A4B8),
      );
    }

    final radius14 = BorderRadius.circular(14);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: radius14),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius14),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: onAccent,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
