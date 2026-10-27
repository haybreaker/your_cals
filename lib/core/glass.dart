import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/material.dart';

/// Android's Impeller renders BackdropFilter unreliably (grey wash inside
/// modal sheets, flicker while scrolling). There we render the identical
/// pane WITHOUT blur — gradient + border + slightly stronger fill — and
/// keep true refraction for iOS only.
final bool kUseRealBlur = !Platform.isAndroid;

/// In-house liquid-glass engine.
///
/// [Glass] renders a refractive frosted pane: background blur, dual specular
/// edge sheen (rim light), and optional pointer-tracking highlight.
class Glass extends StatefulWidget {
  Glass({
    super.key,
    required this.child,
    this.radius = 24,
    double? blur,
    this.opacity = 0.10,
    this.tint,
    this.border = true,
    this.padding,
    this.margin,
    this.pointer,
  })  : blur = blur ?? (kUseRealBlur ? 22 : 0),
        fillOpacity = kUseRealBlur
            ? opacity
            : (opacity + 0.06).clamp(0.0, 0.30);

  final EdgeInsetsGeometry? margin;

  final Widget child;
  final double radius;
  final double blur;

  /// Android fallback uses a stronger fill since there's no blur behind it.
  final double fillOpacity;
  final double opacity;
  final Color? tint;
  final bool border;
  final EdgeInsetsGeometry? padding;

  /// Normalized (-1..1) pointer position for the liquid specular highlight.
  /// Null = no highlight.
  final Offset? pointer;

  @override
  State<Glass> createState() => _GlassState();
}

class _GlassState extends State<Glass> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (widget.tint ?? Colors.white)
                  .withValues(alpha: widget.opacity + 0.05),
              (widget.tint ?? Colors.white)
                  .withValues(alpha: widget.opacity * 0.5),
            ],
          ),
          border: widget.border
              ? Border.all(color: Colors.white.withValues(alpha: 0.14), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: widget.blur, sigmaY: widget.blur),
            child: RepaintBoundary(
              child: CustomPaint(
                foregroundPainter: _SheenPainter(
                  radius: widget.radius,
                  pointer: widget.pointer,
                ),
                child: Container(
                  color: Colors.white.withValues(alpha: 0.02),
                  padding: widget.padding,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rim light + finger-following specular blob. This is what sells "liquid".
class _SheenPainter extends CustomPainter {
  _SheenPainter({required this.radius, required this.pointer});

  final double radius;
  final Offset? pointer;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    // Top-left bright rim fading around the pane.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.4),
            Colors.white.withValues(alpha: 0.04),
            Colors.white.withValues(alpha: 0.16),
          ],
          stops: const [0, 0.55, 1],
        ).createShader(Offset.zero & size),
    );

    final p = pointer;
    if (p != null) {
      canvas.drawCircle(
        Offset(
          size.width * (p.dx * .5 + .5),
          size.height * (p.dy * .5 + .5),
        ),
        size.shortestSide * 0.6,
        Paint()
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 46)
          ..color = Colors.white.withValues(alpha: 0.09),
      );
    }
  }

  @override
  bool shouldRepaint(_SheenPainter old) => old.pointer != pointer;
}

/// Pressable glass card with springy scale + tracked specular highlight.
class LiquidCard extends StatefulWidget {
  const LiquidCard({
    super.key,
    required this.child,
    this.radius = 26,
    this.onTap,
    this.padding,
    this.tint,
    this.opacity = 0.08,
  });

  final Widget child;
  final double radius;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? tint;
  final double opacity;

  @override
  State<LiquidCard> createState() => _LiquidCardState();
}

class _LiquidCardState extends State<LiquidCard>
    with SingleTickerProviderStateMixin {
  // Rest at scale 1.0; dip to 0.98 while pressed.
  late final AnimationController _press = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
    lowerBound: 0.0,
    upperBound: 0.02,
    value: 0,
  );
  Offset? _pointer;

  @override
  void dispose() {
    _press.dispose();
    super.dispose();
  }

  void _track(Offset global) {
    final box = context.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final local = box.globalToLocal(global);
    setState(() {
      _pointer = Offset(
        (local.dx / box.size.width) * 2 - 1,
        (local.dy / box.size.height) * 2 - 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (d) {
        _track(d.localPosition);
        _press.forward();
      },
      onTapUp: (_) => _press.reverse(),
      onTapCancel: () => _press.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _press,
        builder: (context, child) =>
            Transform.scale(scale: 1 - _press.value, child: child),
        child: Glass(
          radius: widget.radius,
          padding: widget.padding ?? const EdgeInsets.all(18),
          tint: widget.tint,
          opacity: widget.opacity,
          pointer: _pointer,
          child: widget.child,
        ),
      ),
    );
  }
}

abstract final class YcRadii {
  static const row = 14.0;
  static const sm = 16.0;
  static const md = 26.0;
  static const lg = 34.0;
}

/// Apple-style fixed type sizes (HIG: Body/Headline 17, Subheadline 15,
/// Footnote 13, Caption 12). Applied as constants so every screen shares
/// one predictable scale.
abstract final class AppText {
  static const double headline = 17;
  static const double body = 17;
  static const double subheadline = 15;
  static const double footnote = 13;
  static const double caption = 12;
}

/// Cheap "fake glass" — identical visual language to [Glass] but with no
/// BackdropFilter. Use for list rows: dozens of live blurs murder scrolling.
class GlassLite extends StatelessWidget {
  const GlassLite({
    super.key,
    required this.child,
    this.radius = 20,
    this.opacity = 0.07,
    this.tint,
    this.padding,
    this.onTap,
  });

  final Widget child;
  final double radius;
  final double opacity;
  final Color? tint;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              (tint ?? Colors.white).withValues(alpha: opacity + 0.05),
              (tint ?? Colors.white).withValues(alpha: opacity * 0.5),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            splashColor: YcRadiiInk.splash,
            highlightColor: YcRadiiInk.highlight,
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

abstract final class YcRadiiInk {
  static const splash = Color(0x147CF5C8);
  static const highlight = Color(0x0A7CF5C8);
}
