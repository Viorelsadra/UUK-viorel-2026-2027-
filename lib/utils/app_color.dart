import 'package:flutter/material.dart';

class AppColor {
  static const Color primary = Color(0xFF3F19D8);
  static const Color secondary = Color(0xFF2323CE);
  static const Color accent = Color(0xFF000000);

  static const Color cardDark = Color(0xFF4F5E5F);
  static const Color Background = Color(0xFFFBFBFB);
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.grey;

  static const Color textTertiary = Color(0xFFFFFFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(255, 125, 100, 254),
      Color.fromARGB(255, 255, 255, 255),
    ],
  );
  static const LinearGradient secondGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color.fromARGB(255, 71, 2, 190),
    Color.fromARGB(255, 93, 31, 201),
    Color.fromARGB(255, 106, 61, 185),
    Color.fromARGB(255, 154, 110, 231),
  ],
);
}