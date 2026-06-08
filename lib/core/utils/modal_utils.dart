import 'dart:ui';
import 'package:flutter/material.dart';

/// Utilitaires pour afficher des modals avec effet blur
class ModalUtils {
  /// Affiche un bottom sheet avec effet blur en arrière-plan
  static Future<T?> showBlurredBottomSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool isScrollControlled = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation ?? 0,
      shape: shape,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: builder(context),
      ),
    );
  }

  /// Affiche un dialog avec effet blur en arrière-plan
  static Future<T?> showBlurredDialog<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? Colors.black.withValues(alpha: 0.3),
      barrierLabel: barrierLabel,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: builder(context),
      ),
    );
  }

  /// Affiche un modal full screen avec effet blur
  static Future<T?> showBlurredModalRoute<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
    bool barrierDismissible = true,
  }) {
    return Navigator.of(context).push<T>(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: barrierDismissible,
        barrierColor: Colors.black.withValues(alpha: 0.3),
        pageBuilder: (context, animation, secondaryAnimation) {
          return BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: FadeTransition(
              opacity: animation,
              child: builder(context),
            ),
          );
        },
      ),
    );
  }
}
