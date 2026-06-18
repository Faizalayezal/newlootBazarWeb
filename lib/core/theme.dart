import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primary = Color(0xFFFF5500);
  static const secondary = Color(0xFFFFC4A7);
  static const background = Color(0xFFFBD6C4);
  static const card = Color(0xFFFFE8DD);
  static const category = Color(0xFF5F2B4B);
  static const product = Color(0xFFFFEAB8);
  static const subtext = Color(0xFF18100F);
  //static const product = Color(0x80FFEAB8);
  //rendom color list show
  static const rColor1 = Color(0xFFFFCA48);
  static const rColor2 = Color(0xFFB8D9C5);
  static const rColor3 = Color(0xFFFFC4A7);
  static const rColor4 = Color(0x635F2B4B);



  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFF6DED1),
    useMaterial3: true,
    textTheme: GoogleFonts.poppinsTextTheme(),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
    ),
  );
}