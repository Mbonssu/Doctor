import 'package:flutter/material.dart';

/// DoctoPing — Palette premium médicale moderne
class AppColors {
  // === LIGHT MODE ===

  // Primary — Bleu électrique profond
  static const Color primary        = Color(0xFF1B54F8);
  static const Color primaryDim     = Color(0xFF1440CC);
  static const Color primaryLight   = Color(0xFFECF1FF);
  static const Color primary50      = Color(0xFFECF1FF);
  static const Color primary100     = Color(0xFFD5E0FF);
  static const Color primary600     = Color(0xFF1B54F8);
  static const Color primary700     = Color(0xFF1440CC);

  // Accent — Émeraude vibrant
  static const Color accent         = Color(0xFF00C48C);
  static const Color accentLight    = Color(0xFFE6FAF4);

  // Status
  static const Color success        = Color(0xFF00C48C);
  static const Color successLight   = Color(0xFFE6FAF4);
  static const Color successBg      = Color(0xFFE6FAF4);
  static const Color successText    = Color(0xFF006D4E);

  static const Color warning        = Color(0xFFFFB800);
  static const Color warningLight   = Color(0xFFFFF8E1);
  static const Color warningBg      = Color(0xFFFFF8E1);
  static const Color warningText    = Color(0xFF7A5500);

  static const Color danger         = Color(0xFFFF4D4F);
  static const Color dangerLight    = Color(0xFFFFF0F0);
  static const Color dangerBg       = Color(0xFFFFF0F0);
  static const Color dangerText     = Color(0xFF8B0000);

  // Backgrounds
  static const Color background     = Color(0xFFF4F7FF);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color cardBg         = Color(0xFFF4F7FF);
  static const Color surfaceVariant = Color(0xFFF8FAFF);

  // Text
  static const Color textPrimary    = Color(0xFF0A1128);
  static const Color textSecondary  = Color(0xFF64748B);
  static const Color textMuted      = Color(0xFFA0AEC0);

  // Borders
  static const Color border         = Color(0xFFE4EAFF);
  static const Color borderMid      = Color(0xFFCDD5F0);

  // Grays
  static const Color gray50         = Color(0xFFF4F7FF);
  static const Color gray100        = Color(0xFFECF1FF);
  static const Color gray200        = Color(0xFFE4EAFF);
  static const Color gray400        = Color(0xFFA0AEC0);
  static const Color gray600        = Color(0xFF64748B);
  static const Color gray900        = Color(0xFF0A1128);

  // Specialty colors
  static const Color cardio         = Color(0xFFFF4D6D);
  static const Color neuro          = Color(0xFF845EF7);
  static const Color pediatrie      = Color(0xFF00C48C);
  static const Color ophtalmo       = Color(0xFF1B54F8);
  static const Color dermato        = Color(0xFFFF9A3C);
  static const Color ortho          = Color(0xFF00B4D8);
  static const Color gyneco         = Color(0xFFE64980);
  static const Color generale       = Color(0xFF51CF66);

  // === DARK MODE ===
  static const Color primaryDark        = Color(0xFF4D7FFF);
  static const Color primaryLightDark   = Color(0xFF1A2A5E);
  static const Color primary50Dark      = Color(0xFF111D40);
  static const Color primary100Dark     = Color(0xFF1A2A5E);

  static const Color successDark        = Color(0xFF2DD4A4);
  static const Color successLightDark   = Color(0xFF053D2A);
  static const Color successBgDark      = Color(0xFF053D2A);
  static const Color successTextDark    = Color(0xFF6EFFD9);

  static const Color warningDark        = Color(0xFFFFCC4D);
  static const Color warningLightDark   = Color(0xFF4A3000);
  static const Color warningBgDark      = Color(0xFF4A3000);
  static const Color warningTextDark    = Color(0xFFFFE599);

  static const Color dangerDark         = Color(0xFFFF7875);
  static const Color dangerLightDark    = Color(0xFF4A0000);
  static const Color dangerBgDark       = Color(0xFF4A0000);
  static const Color dangerTextDark     = Color(0xFFFFB3B3);

  static const Color backgroundDark     = Color(0xFF070E21);
  static const Color surfaceDark        = Color(0xFF0D1730);
  static const Color cardBgDark         = Color(0xFF131F3A);

  static const Color textPrimaryDark    = Color(0xFFEDF2FF);
  static const Color textSecondaryDark  = Color(0xFFCBD5E1);
  static const Color textMutedDark      = Color(0xFF718096);

  static const Color borderDark         = Color(0xFF1E2D52);
  static const Color borderMidDark      = Color(0xFF2A3C65);

  static const Color gray50Dark         = Color(0xFF070E21);
  static const Color gray100Dark        = Color(0xFF0D1730);
  static const Color gray200Dark        = Color(0xFF131F3A);
  static const Color gray400Dark        = Color(0xFF718096);
  static const Color gray600Dark        = Color(0xFFCBD5E1);
  static const Color gray900Dark        = Color(0xFFEDF2FF);

  // Utilities
  static const Color white              = Color(0xFFFFFFFF);
  static const Color black              = Color(0xFF000000);
  static const Color transparent        = Colors.transparent;

  static const Color shadowLight        = Color(0x121B54F8);
  static const Color shadow             = Color(0x0F0A1128);
  static const Color shadowMd           = Color(0x1A0A1128);

  static const Color shadowLightDark    = Color(0x45000000);
  static const Color shadowDark         = Color(0x45000000);
  static const Color shadowMdDark       = Color(0x45000000);

  // Gradient helpers
  static const List<Color> primaryGradient = [Color(0xFF1B54F8), Color(0xFF6B8EFF)];
  static const List<Color> accentGradient  = [Color(0xFF00C48C), Color(0xFF00E5A0)];
  static const List<Color> darkGradient    = [Color(0xFF0A1128), Color(0xFF1B2E5E)];
}
