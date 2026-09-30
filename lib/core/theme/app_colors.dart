import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ───────────────────────────────────────────────────────
  static const Color background   = Color(0xFFFFFFFF); // pure white
  static const Color surface      = Color(0xFFF5F6FA); // light card bg
  static const Color surfaceLight = Color(0xFFEAECF2); // subtle chip bg

  // ── Borders ───────────────────────────────────────────────────────────
  static const Color border       = Color(0xFFDDE0EA); // light divider

  // ── Brand accent (lime-green kept for identity) ───────────────────────
  static const Color primary      = Color(0xFF7AC143); // fitness green
  static const Color onPrimary    = Color(0xFFFFFFFF); // white on green

  // ── Text ──────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF111827); // near-black
  static const Color textSecondary = Color(0xFF6B7280); // medium grey
}
