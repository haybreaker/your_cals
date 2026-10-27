import 'package:flutter/material.dart';

/// YourCals design system — deep-space canvas + aurora accents + glass.
abstract final class Yc {
  // Canvas
  static const bg = Color(0xFF06070D);
  static const bgElevated = Color(0xFF0D0F17);

  // Aurora blob palette (drawn behind glass so refraction has something to eat)
  static const auroraTeal = Color(0x332DD4BF);
  static const auroraIndigo = Color(0x2E6366F1);
  static const auroraPink = Color(0x26F472B6);
  static const auroraAmber = Color(0x22F59E0B);

  // Macro accents
  static const calories = Color(0xFF7CF5C8);
  static const protein = Color(0xFF8B8CF9);
  static const carbs = Color(0xFFFFC24B);
  static const fat = Color(0xFFFF7A9C);

  static const textPrimary = Color(0xFFF4F6FB);
  static const textSecondary = Color(0xB3FFFFFF);
  static const textTertiary = Color(0x66FFFFFF);

  static const danger = Color(0xFFFF5470);
  static const success = Color(0xFF34D399);

  /// App tint for selection / interactive accents (Apple HIG "app tint"
  /// role — systemBlue in Apple's own apps, brand mint here).
  static const accent = calories;

  /// Content color drawn on top of [accent] fills (checkmarks etc.).
  static const onAccent = Color(0xFF06251B);

  // Surface the drag-feedback / floating chips are built on.
  static const chipBg = Color(0xE6161822);

  // Corner-radius scale — the ONE scale; use these, never literals.
  static const radiusRow = 14.0;
  static const radiusSm = 16.0;
  static const radiusMd = 26.0;
  static const radiusLg = 34.0;

  // Legacy aliases (glass.dart) — see YcRadii below for the same values.
  static const rSm = radiusRow;
  static const rMd = 22.0;
  static const rLg = 30.0;

  static ThemeData theme(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: base.colorScheme.copyWith(
        primary: calories,
        secondary: protein,
        surface: bg,
        error: danger,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      splashFactory: InkSparkle.splashFactory,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: calories,
        selectionColor: Color(0x337CF5C8),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.iOS: _SpringPageTransitionBuilder(),
        TargetPlatform.android: _SpringPageTransitionBuilder(),
      }),
    );
  }
}

class _SpringPageTransitionBuilder extends PageTransitionsBuilder {
  const _SpringPageTransitionBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return SlideTransition(
      position: Tween(begin: const Offset(0, 0.06), end: Offset.zero)
          .animate(curved),
      child: FadeTransition(opacity: curved, child: child),
    );
  }
}
