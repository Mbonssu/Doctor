import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extension centralisée — toutes les propriétés contextuelles de couleur
/// pour DoctoPing. Un seul endroit de vérité, zero duplication dans les screens.
extension ColorExtensions on BuildContext {
  // ─── Helper ──────────────────────────────────────────────────────────────
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ─── Backgrounds ─────────────────────────────────────────────────────────
  Color get bgColor =>
      isDark ? AppColors.backgroundDark : AppColors.background;

  Color get surfaceColor =>
      isDark ? AppColors.surfaceDark : AppColors.surface;

  Color get cardColor =>
      isDark ? AppColors.cardBgDark : AppColors.surface;

  // ─── Text ─────────────────────────────────────────────────────────────────
  Color get textColor =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

  Color get textPrimary =>
      isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

  Color get textSecondary =>
      isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

  Color get mutedText =>
      isDark ? AppColors.textMutedDark : AppColors.textMuted;

  // ─── Borders / Dividers ───────────────────────────────────────────────────
  Color get dividerColor =>
      isDark ? AppColors.borderDark : AppColors.border;

  Color get borderColor =>
      isDark ? AppColors.borderDark : AppColors.border;

  Color get borderMid =>
      isDark ? AppColors.borderMidDark : AppColors.borderMid;

  // ─── Brand ───────────────────────────────────────────────────────────────
  Color get primaryColor =>
      isDark ? AppColors.primaryDark : AppColors.primary;

  Color get primaryLight =>
      isDark ? AppColors.primaryLightDark : AppColors.primaryLight;

  Color get primaryLightColor =>
      isDark ? AppColors.primaryLightDark : AppColors.primaryLight;

  // ─── Status ───────────────────────────────────────────────────────────────
  Color get successColor =>
      isDark ? AppColors.successDark : AppColors.success;

  Color get warningColor =>
      isDark ? AppColors.warningDark : AppColors.warning;

  Color get dangerColor =>
      isDark ? AppColors.dangerDark : AppColors.danger;

  // ─── Gradient background (dark mode mesh) ────────────────────────────────
  Gradient get bgGradient => isDark
      ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF070E21),
            Color(0xFF0D1730),
            Color(0xFF111D40),
          ],
        )
      : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.background,
            AppColors.surfaceVariant,
          ],
        );
}
