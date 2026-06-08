import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/color_extensions.dart';
import '../../core/theme/glass_theme.dart';
import 'glass_container.dart';

/// Exemples d'utilisation des effets glass
class GlassExamplesScreen extends StatelessWidget {
  const GlassExamplesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: Stack(
        children: [
          // Fond avec gradient pour mieux voir l'effet glass
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1B3E),
                  Color(0xFF1B2E5E),
                  Color(0xFF2A3F6E),
                ],
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Exemples Glassmorphism',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Exemple 1: Glass Container Simple
                  const Text(
                    'Glass Container Simple',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassContainer(
                    blur: GlassTheme.mediumBlur,
                    opacity: GlassTheme.getOpacity(
                      context.isDark,
                      GlassIntensity.medium,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Carte Glass',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Effet verre dépoli avec blur',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Exemple 2: Glass Gradient Container
                  const Text(
                    'Glass Gradient Container',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassGradientContainer(
                    blur: GlassTheme.mediumBlur,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.all(20),
                    gradientColors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gradient Glass',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Effet verre avec dégradé de couleurs',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Exemple 3: Intensités différentes
                  const Text(
                    'Différentes Intensités',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Light
                  GlassContainer(
                    blur: GlassTheme.lightBlur,
                    opacity: GlassTheme.getOpacity(
                      context.isDark,
                      GlassIntensity.light,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: const Text(
                      'Light Blur (5px)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Medium
                  GlassContainer(
                    blur: GlassTheme.mediumBlur,
                    opacity: GlassTheme.getOpacity(
                      context.isDark,
                      GlassIntensity.medium,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: const Text(
                      'Medium Blur (10px)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Heavy
                  GlassContainer(
                    blur: GlassTheme.heavyBlur,
                    opacity: GlassTheme.getOpacity(
                      context.isDark,
                      GlassIntensity.heavy,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    padding: const EdgeInsets.all(16),
                    child: const Text(
                      'Heavy Blur (20px)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
