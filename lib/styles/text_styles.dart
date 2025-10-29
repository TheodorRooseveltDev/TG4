import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Western/Vintage text styles for Casino Clash
class WesternTextStyles {
  // Title - Old West Wanted Poster Style
  static TextStyle title({
    double fontSize = 48,
    Color color = const Color(0xFFD32F2F),
    double letterSpacing = 4,
  }) {
    return GoogleFonts.rye(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
      letterSpacing: letterSpacing,
      shadows: [
        Shadow(
          color: Colors.red.shade900,
          blurRadius: 20,
        ),
      ],
    );
  }

  // Subtitle - Victorian elegance
  static TextStyle subtitle({
    double fontSize = 20,
    Color? color,
  }) {
    return GoogleFonts.oldStandardTt(
      fontSize: fontSize,
      color: color ?? Colors.grey.shade400,
      letterSpacing: 2,
      fontStyle: FontStyle.italic,
    );
  }

  // Dialogue - Readable vintage typewriter
  static TextStyle dialogue({
    double fontSize = 16,
    Color color = Colors.white,
  }) {
    return GoogleFonts.crimsonText(
      fontSize: fontSize,
      color: color,
      height: 1.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );
  }

  // Narration - Old book style
  static TextStyle narration({
    double fontSize = 18,
    Color color = Colors.white,
  }) {
    return GoogleFonts.crimsonText(
      fontSize: fontSize,
      color: color,
      height: 1.6,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );
  }

  // Character name - Bold Western
  static TextStyle characterName({
    double fontSize = 12,
    Color? color,
  }) {
    return GoogleFonts.bebasNeue(
      fontSize: fontSize,
      color: color ?? const Color(0xFFFF8A80),
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.3),
          offset: const Offset(1, 1),
          blurRadius: 1,
        ),
      ],
    );
  }

  // Button text - Saloon sign style
  static TextStyle button({
    double fontSize = 20,
    Color color = Colors.white,
  }) {
    return GoogleFonts.bebasNeue(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.5),
          offset: const Offset(1, 1),
          blurRadius: 2,
        ),
      ],
    );
  }

  // Location/Casino name - Weathered stencil
  static TextStyle location({
    double fontSize = 20,
    Color? color,
  }) {
    return GoogleFonts.permanentMarker(
      fontSize: fontSize,
      color: color ?? const Color(0xFFFF8A80),
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    );
  }

  // Stats/UI elements - Clean readable
  static TextStyle uiText({
    double fontSize = 12,
    Color color = Colors.white,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.robotoCondensed(
      fontSize: fontSize,
      color: color,
      fontWeight: fontWeight ?? FontWeight.bold,
    );
  }

  // Horror/Spooky moments - Creepy Western
  static TextStyle horror({
    double fontSize = 16,
    Color? color,
  }) {
    return GoogleFonts.creepster(
      fontSize: fontSize,
      color: color ?? Colors.red.shade300,
      letterSpacing: 1,
    );
  }

  // Description - Clean paragraph text
  static TextStyle description({
    double fontSize = 16,
    Color? color,
  }) {
    return GoogleFonts.ebGaramond(
      fontSize: fontSize,
      color: color ?? Colors.grey.shade300,
      height: 1.6,
    );
  }

  // Menu items - Bold display
  static TextStyle menuItem({
    double fontSize = 18,
    Color color = Colors.white,
  }) {
    return GoogleFonts.bebasNeue(
      fontSize: fontSize,
      color: color,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.5,
    );
  }
}

/// Pre-defined color palette for Western theme
class WesternColors {
  static const Color bloodRed = Color(0xFFD32F2F);
  static const Color dustyGold = Color(0xFFFFD54F);
  static const Color weatheredBrown = Color(0xFF5D4037);
  static const Color oldPaper = Color(0xFFF5E6D3);
  static const Color inkBlack = Color(0xFF1A1A1A);
  static const Color copperGreen = Color(0xFF4A7C59);
  static const Color saloonWood = Color(0xFF8D6E63);
  static const Color gunmetal = Color(0xFF424242);
}
