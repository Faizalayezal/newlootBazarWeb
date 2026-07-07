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

  static const List<Color> pastelColors = [
    Color(0xFFFDE69E), // 1. Warm Custard Yellow
    Color(0xFFC2E8FF), // 2. Pastel Sky Blue
    Color(0xFFD2F5D2), // 3. Pastel Mint Green
    Color(0xFFFFD3E2), // 4. Cotton Candy Pink
    Color(0xFFFED7AA), // 5. Soft Peach Apricot
    Color(0xFFE9D5FF), // 6. Orchid Lavender
    Color(0xFFCCFBF1), // 7. Light Turquoise
    Color(0xFFFCE7F3), // 8. Soft Rosebud Tint
    Color(0xFFFEF9C3), // 9. Sweet Lemon Chiffon
    Color(0xFFCFFAFE), // 10. Frozen Ice Blue
    Color(0xFFBBF7D0), // 11. Pale Sage Green
    Color(0xFFFBCFE8), // 12. Pastel Blossom Pink
    Color(0xFFFDE047), // 13. Light Sun Flower
    Color(0xFFBAE6FD), // 14. Summer Breeze Blue
    Color(0xFFDBCDF0), // 15. Soft Royal Lilac
    Color(0xFFF2E9E1), // 16. Premium Oatmeal Cream
    Color(0xFFFCE8E6), // 17. Warm Blush Coral
    Color(0xFFC5F6FA), // 18. Soft Aquamarine
    Color(0xFFD1FAE5), // 19. Fresh Celadon Green
    Color(0xFFF5E1FD), // 20. Pale Heather Purple
    Color(0xFFFFE4B5), // 21. Moccasin Peach
    Color(0xFFE0F2FE), // 22. Calm Arctic Blue
    Color(0xFFE8F5E9), // 23. Classic Tea Green
    Color(0xFFFFE4E6), // 24. Rose Mist
    Color(0xFFFFF7ED), // 25. Creamy Orange Blossom
    Color(0xFFE6F4EA), // 26. Gentle Forest Mist
    Color(0xFFECEFF1), // 27. Cool Alabaster Gray
    Color(0xFFFFF9E6), // 28. Rich Milk Cream
    Color(0xFFF0F4FF), // 29. Aero Blue Tint
    Color(0xFFFFF0F5), // 30. Lavender Blush Pink
  ];
}