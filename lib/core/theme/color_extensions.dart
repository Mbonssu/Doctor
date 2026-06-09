// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'app_colors.dart';


// extension ColorExtensions on BuildContext {
//   bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
//   Color get primaryColor => AppColors.primary;
//   Color get accentColor => AppColors.accent;
//   Color get dangerColor => AppColors.danger;
//   Color get successColor => AppColors.success;
//   Color get warningColor => AppColors.warning;
  
//   Color get inputFillColor => isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade50;
  
 
// }

extension ColorExtensions on BuildContext {
  // Background colors
  Color get bgColor => Theme.of(this).brightness == Brightness.dark 
      ? AppColors.backgroundDark 
      : AppColors.background;
  
  Color get surfaceColor => Theme.of(this).brightness == Brightness.dark 
      ? AppColors.surfaceDark 
      : AppColors.surface;
  
  Color get cardColor => Theme.of(this).brightness == Brightness.dark 
      ? AppColors.cardBgDark 
      : AppColors.cardBg;
  
  // Text colors
  Color get textPrimary => Theme.of(this).brightness == Brightness.dark 
      ? AppColors.textPrimaryDark 
      : AppColors.textPrimary;
  
  Color get textSecondary => Theme.of(this).brightness == Brightness.dark 
      ? AppColors.textSecondaryDark 
      : AppColors.textSecondary;
  
  Color get textSecondaryColor => textSecondary;
  
  Color get textMuted => Theme.of(this).brightness == Brightness.dark 
      ? AppColors.textSecondaryDark 
      : AppColors.textMuted;
  
  Color get textMutedColor => textMuted;
  Color get mutedText => textMuted;
  Color get textColor => textPrimary;
  
  // Border colors
  Color get borderColor => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white24 
      : Colors.grey.shade200;
  
  Color get borderMid => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white12 
      : Colors.grey.shade300;
  
  Color get borderDark => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white10 
      : Colors.grey.shade400;
  
  Color get dividerColor => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white12 
      : Colors.grey.shade100;
  
  Color get inputFillColor => Theme.of(this).brightness == Brightness.dark 
      ? AppColors.surfaceDark 
      : Colors.grey.shade50;
  
  // Primary colors
  Color get primaryLightColor => AppColors.primary.withOpacity(0.1);
  Color get primary100Color => AppColors.primary.withOpacity(0.15);
  Color get primaryLight => AppColors.primary.withOpacity(0.12);
  Color get primary100 => AppColors.primary.withOpacity(0.15);
  Color get accentLight => AppColors.accent.withOpacity(0.1);
  
  // Gradient
  // LinearGradient get bgGradient => AppColors.primaryGradient;
   LinearGradient get bgGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D1B3E), Color(0xFF1B2E5E)],
  );
  
  // Status background colors
  Color get successBgColor => AppColors.successLight;
  Color get successTextColor => AppColors.success;
  Color get warningBgColor => AppColors.warningLight;
  Color get warningTextColor => AppColors.warning;
  Color get dangerBgColor => AppColors.dangerLight;
  Color get dangerTextColor => AppColors.danger;
  
  // Status colors
  Color get dangerColor => AppColors.danger;
  Color get successColor => AppColors.success;
  Color get warningColor => AppColors.warning;
  
  // Gray colors
  Color get gray100 => Colors.grey.shade100;
  Color get gray200 => Colors.grey.shade200;
  
  // Shadow
  Color get shadow => Colors.black.withOpacity(0.1);
  
  // Helper
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
