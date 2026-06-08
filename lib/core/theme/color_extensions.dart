import 'package:flutter/material.dart';
import 'app_colors.dart';

extension ColorExtensions on BuildContext {
  // Background colors
  Color get bgColor => Theme.of(this).brightness == Brightness.dark 
      ? AppColors.darkBackground 
      : AppColors.lightBackground;
  
  Color get surfaceColor => Theme.of(this).brightness == Brightness.dark 
      ? AppColors.darkSurface 
      : AppColors.lightSurface;
  
  Color get cardColor => Theme.of(this).brightness == Brightness.dark 
      ? AppColors.darkCard 
      : AppColors.lightCard;
  
  // Text colors
  Color get textPrimary => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white 
      : AppColors.darkText;
  
  Color get textSecondary => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white70 
      : AppColors.lightTextSecondary;
  
  Color get textMuted => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white54 
      : AppColors.lightTextMuted;
  
  Color get textMutedColor => textMuted;
  
  // Border colors
  Color get borderColor => Theme.of(this).brightness == Brightness.dark 
      ? Colors.white24 
      : Colors.grey.shade200;
  
  Color get primaryLightColor => AppColors.primary.withValues(alpha: 0.1);
  
  // Status colors
  Color get dangerColor => AppColors.danger;
  Color get successColor => AppColors.success;
  Color get warningColor => AppColors.warning;
  
  // Helper
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
