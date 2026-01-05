import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlack = Color(0xFF000000);
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color neutralGrey = Color(0xFF757575);
  static const Color lightGreyBorder = Color(0xFFE0E0E0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      dialogTheme: DialogThemeData(barrierColor: Colors.black.withAlpha(51)),

      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryBlack,
        onPrimary: surfaceWhite,
        secondary: accentGreen,
        onSecondary: surfaceWhite,
        error: Colors.red,
        onError: surfaceWhite,
        surface: surfaceWhite,
        onSurface: primaryBlack,
        outline: lightGreyBorder,
      ),

      scaffoldBackgroundColor: surfaceWhite,

      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryBlack,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          fontFamily: 'Roboto',
          shadows: [Shadow(color: Color(0xFFE2C8A3), offset: Offset(1, 1))],
        ),
        iconTheme: IconThemeData(color: primaryBlack),
      ),

      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryBlack,
        selectionColor: Color(0x33000000),
        selectionHandleColor: primaryBlack,
      ),

      inputDecorationTheme: _inputTheme(),
      elevatedButtonTheme: _buttonTheme(),
    );
  }

  static InputDecorationTheme _inputTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: surfaceWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lightGreyBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlack),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlack, width: 1.5),
      ),
    );
  }

  static ElevatedButtonThemeData _buttonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlack,
        foregroundColor: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      ),
    );
  }
}
