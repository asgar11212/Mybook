import 'package:flutter/material.dart';

class AppTheme {
  // 🌞 Light Theme
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    useMaterial3: true,
  );

  // 🌙 Dark Theme
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    useMaterial3: true,
  );
}
