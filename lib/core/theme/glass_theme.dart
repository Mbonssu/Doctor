/// Configuration des effets glass pour DoctoPing
class GlassTheme {
  GlassTheme._();

  // Valeurs de blur
  static const double lightBlur  = 5.0;
  static const double mediumBlur = 10.0;
  static const double heavyBlur  = 20.0;

  // Opacités mode clair
  static const double lightOpacityLight  = 0.7;
  static const double mediumOpacityLight = 0.5;
  static const double heavyOpacityLight  = 0.3;

  // Opacités mode sombre
  static const double lightOpacityDark  = 0.15;
  static const double mediumOpacityDark = 0.10;
  static const double heavyOpacityDark  = 0.05;

  /// Opacité selon mode et intensité. Passe [isDark] explicitement
  /// car cette méthode est statique (pas accès à BuildContext).
  static double getOpacity(bool isDark, GlassIntensity intensity) {
    switch (intensity) {
      case GlassIntensity.light:
        return isDark ? lightOpacityDark  : lightOpacityLight;
      case GlassIntensity.medium:
        return isDark ? mediumOpacityDark : mediumOpacityLight;
      case GlassIntensity.heavy:
        return isDark ? heavyOpacityDark  : heavyOpacityLight;
    }
  }

  /// Blur selon intensité
  static double getBlur(GlassIntensity intensity) {
    switch (intensity) {
      case GlassIntensity.light:  return lightBlur;
      case GlassIntensity.medium: return mediumBlur;
      case GlassIntensity.heavy:  return heavyBlur;
    }
  }
}

enum GlassIntensity { light, medium, heavy }
