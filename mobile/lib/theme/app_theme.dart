import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Palet Latar & Permukaan (Deep Obsidian & Charcoal)
  static const Color charcoalBg = Color(0xFF0F0F12);         // Background utama
  static const Color charcoalSurface = Color(0xFF18181D);    // Card container
  static const Color charcoalElevated = Color(0xFF22222A);   // Surface elevated
  static const Color charcoalBorder = Color(0xFF2A2A33);     // Garis halus alami
  static const Color charcoalDivider = Color(0xFF222228);

  // Palet Aksen: Hijau Bayam (Athletic Spinach Green)
  static const Color spinachGreen = Color(0xFF43A047);       // Aksen utama
  static const Color spinachGreenLight = Color(0xFF66BB6A);  // Aksen terang / aktif
  static const Color spinachGreenDark = Color(0xFF2E7D32);   // Aksen pekat
  static const Color spinachGreenBg = Color(0x1F43A047);     // Tint transparan lembut

  // Palet Peringatan: Merah (Warning Red)
  static const Color warningRed = Color(0xFFE53935);         // Merah peringatan
  static const Color warningRedLight = Color(0xFFEF5350);    // Merah terang
  static const Color warningRedDark = Color(0xFFC62828);     // Merah pekat
  static const Color warningRedBg = Color(0x24E53935);       // Tint peringatan

  // Teks & Netral
  static const Color textWhite = Color(0xFFF4F4F6);          // Teks utama kontras
  static const Color textMuted = Color(0xFFA1A1AA);          // Teks sekunder (Zinc 400)
  static const Color textDim = Color(0xFF71717A);            // Teks tersier (Zinc 500)
}

class AppTypography {
  // Font Bebas Neue: Khusus untuk Metrik, Angka Repetisi, Skor, dan Timer (Athletic Numbers)
  static TextStyle bebasNeue({
    double fontSize = 48,
    Color color = AppColors.textWhite,
    double letterSpacing = 1.0,
  }) {
    try {
      return GoogleFonts.bebasNeue(
        fontSize: fontSize,
        color: color,
        letterSpacing: letterSpacing,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Bebas Neue',
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
        letterSpacing: letterSpacing,
      );
    }
  }

  // Font Roboto: Teks Antarmuka Alami (Judul, Deskripsi, Tombol, dan Umpan Balik)
  static TextStyle roboto({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = AppColors.textWhite,
    double height = 1.4,
    double letterSpacing = 0.1,
  }) {
    try {
      return GoogleFonts.roboto(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'Roboto',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    }
  }

  // Header alami (Title / Headings)
  static TextStyle heading({
    double fontSize = 20,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textWhite,
    double? height,
    double letterSpacing = -0.2,
  }) {
    return roboto(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height ?? 1.25,
    );
  }

  // Subheading alami
  static TextStyle subhead({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.textMuted,
    double? height,
  }) {
    return roboto(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height ?? 1.35,
    );
  }
}
