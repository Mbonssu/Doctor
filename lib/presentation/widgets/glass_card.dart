import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/color_extensions.dart';

/// Widget pour créer des cards avec effet glassmorphism en mode sombre
/// En mode clair, affiche une card normale
class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? color;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final Gradient? gradient;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.color,
    this.border,
    this.boxShadow,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(16);

    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      child: isDark
          ? ClipRRect(
              borderRadius: effectiveBorderRadius,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: padding,
                  decoration: BoxDecoration(
                    color: color ?? Colors.white.withValues(alpha: 0.05),
                    gradient: gradient,
                    borderRadius: effectiveBorderRadius,
                    border: border ??
                        Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                    boxShadow: boxShadow ??
                        [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                  ),
                  child: child,
                ),
              ),
            )
          : Container(
              padding: padding,
              decoration: BoxDecoration(
                color: color ?? context.surfaceColor,
                gradient: gradient,
                borderRadius: effectiveBorderRadius,
                border: border ??
                    Border.all(
                      color: context.borderColor,
                      width: 1,
                    ),
                boxShadow: boxShadow,
              ),
              child: child,
            ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

/// Widget pour créer des stat cards avec effet glassmorphism en mode sombre
class GlassStatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const GlassStatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: context.isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: context.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
