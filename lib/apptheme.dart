import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF244C66);

  static ThemeData get light => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: primary),
    useMaterial3: true,
    fontFamily: 'Arial',
  );
}
