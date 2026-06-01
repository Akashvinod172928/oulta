import 'package:flutter/material.dart';

final oultaTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0052D4),
    brightness: Brightness.light,
    primary: const Color(0xFF0052D4),
    onPrimary: Colors.white,
    secondary: const Color(0xFF0052D4),
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: const Color(0xFF1A1A1A),
    background: Colors.white,
    onBackground: const Color(0xFF1A1A1A),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
      color: Color(0xFF1A1A1A),
      height: 1.2,
    ),
    displayMedium: TextStyle(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
      color: Color(0xFF1A1A1A),
    ),
    displaySmall: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: Color(0xFF1A1A1A),
    ),
    headlineLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: Color(0xFF1A1A1A),
    ),
    bodyLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: Colors.black87,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: Colors.black54,
    ),
  ),
);
