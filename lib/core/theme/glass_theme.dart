
/// Configuration des effets glass pour l'application
class GlassTheme {
  // Paramètres de blur
  static const double lightBlur = 5.0;
  static const double mediumBlur = 10.0;
  static const double heavyBlur = 20.0;

  // Opacités pour mode clair
  static const double lightOpacityLight = 0.7;
  static const double mediumOpacityLight = 0.5;
  static const double heavyOpacityLight = 0.3;

  // Opacités pour mode sombre
  static const double lightOpacityDark = 0.15;
  static const double mediumOpacityDark = 0.1;
  static const double heavyOpacityDark = 0.05;

  /// Retourne l'opacité appropriée selon le mode et l'intensité
  static double getOpacity(bool isDark, GlassIntensity intensity) {
    switch (intensity) {
      case GlassIntensity.light:
        return context.isDark ? lightOpacityDark : lightOpacityLight;
      case GlassIntensity.medium:
        return context.isDark ? mediumOpacityDark : mediumOpacityLight;
      case GlassIntensity.heavy:
        return context.isDark ? heavyOpacityDark : heavyOpacityLight;
    }
  }

  /// Retourne le blur approprié selon l'intensité
  static double getBlur(GlassIntensity intensity) {
    switch (intensity) {
      case GlassIntensity.light:
        return lightBlur;
      case GlassIntensity.medium:
        return mediumBlur;
      case GlassIntensity.heavy:
        return heavyBlur;
    }
  }
}

enum GlassIntensity {
  light,
  medium,
  heavy,
}
