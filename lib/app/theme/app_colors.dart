import 'package:flutter/material.dart';

/// The ÉTOFFE Atelier Color Palette
/// Based on the Editorial Warm Minimalism design system.
abstract class AppColors {
  // Canvas & Surfaces
  static const Color canvas = Color(0xFFF7F5F0); // Warm Ivory
  static const Color surfaceWhite = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceDim = Color(0xFFDBDAD5);

  // Ink & Core Actions
  static const Color ink = Color(0xFF222222); // Deep Charcoal
  static const Color inkMuted = Color(0xFF666666); // Charcoal Muted
  static const Color onInk = Color(0xFFFFFFFF); // White text on Charcoal

  // Accents
  static const Color terracotta = Color(0xFFE9B9A8); // Soft Terracotta

  // Dividers & Structural Neutrals
  static const Color divider = Color(0xFFE8E6E1); // Light warm gray
  static const Color border = Color(0xFFDDDAD3); // Pale stone

  // Semantic Feedback
  static const Color success = Color(0xFF2D6A4F); // Forest Emerald
  static const Color warning = Color(0xFFC47C2B); // Warm Amber
  static const Color error = Color(0xFFB93838); // Editorial Crimson

  // Shadows
  static const Color shadowLevel2 = Color(0x0D222222); // 5% Opacity Charcoal
  static const Color shadowLevel3 = Color(0x1F222222); // 12% Opacity Charcoal
}
