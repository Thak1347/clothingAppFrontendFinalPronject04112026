import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography system pairing Playfair Display (Editorial)
/// with Plus Jakarta Sans (Functional).
abstract class AppTextStyles {
  // ── Editorial Headings (Playfair Display) ──
  static final TextStyle displayLg = GoogleFonts.playfairDisplay(
    fontSize: 48,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.02 * 48,
    height: 56 / 48,
    color: AppColors.ink,
  );
  static final TextStyle displayLgMobile = GoogleFonts.playfairDisplay(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.02 * 36,
    height: 44 / 36,
    color: AppColors.ink,
  );
  static final TextStyle displayMd = GoogleFonts.playfairDisplay(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.01 * 36,
    height: 44 / 36,
    color: AppColors.ink,
  );
  static final TextStyle displayMdMobile = GoogleFonts.playfairDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.01 * 28,
    height: 36 / 28,
    color: AppColors.ink,
  );
  static final TextStyle headlineLg = GoogleFonts.playfairDisplay(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 32 / 24,
    color: AppColors.ink,
  );
  static final TextStyle headlineSm = GoogleFonts.playfairDisplay(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 28 / 20,
    color: AppColors.ink,
  );

  // ── Functional Interface & Metrics (Plus Jakarta Sans) ──
  static final TextStyle bodyLg = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.01 * 16,
    height: 26 / 16,
    color: AppColors.ink,
  );
  static final TextStyle bodyMd = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 22 / 14,
    color: AppColors.ink,
  );
  static final TextStyle bodySm = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.01 * 12,
    height: 18 / 12,
    color: AppColors.ink,
  );

  // ── Labels & Micro-copy (Uppercase) ──
  static final TextStyle labelLg = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.04 * 14,
    height: 20 / 14,
    color: AppColors.ink,
  );
  static final TextStyle labelMd = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.06 * 12,
    height: 16 / 12,
    color: AppColors.ink,
  );
  static final TextStyle labelSm = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.08 * 10,
    height: 14 / 10,
    color: AppColors.ink,
  );

  // ── Price Metrics (Sans-serif for legibility) ──
  static final TextStyle priceLg = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.01 * 18,
    height: 24 / 18,
    color: AppColors.ink,
  );
  static final TextStyle priceMd = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 20 / 14,
    color: AppColors.ink,
  );
}
