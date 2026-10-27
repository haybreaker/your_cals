import 'dart:io' show Platform;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'theme.dart';

/// Android's Impeller re-filters BackdropFilters when the backdrop mutates
/// every frame — that's the flicker. Static aurora there, drifting on iOS.
final bool kAnimateAurora = !Platform.isAndroid;

/// Blur sigma is the single most expensive knob; Android gets less.
double glassBlurForPlatform({required bool hero}) {
  if (Platform.isAndroid) return hero ? 14 : 0;
  return hero ? 22 : 0;
}

/// Slowly drifting aurora blobs — the colorful canvas glass refracts.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ColoredBox(
        color: Yc.bg,
        child: kAnimateAurora
            ? Stack(children: [_animatedBlobs()])
            : const _StaticAurora(),
      ),
    );
  }

  static Widget _animatedBlobs() => const Stack(
        children: [
          _Blob(
            color: Color(0x2E14B8A6),
            size: Size(420, 420),
            from: Alignment(-0.9, -0.85),
            to: Alignment(-0.4, -0.5),
            duration: Duration(seconds: 26),
          ),
          _Blob(
            color: Color(0x286366F1),
            size: Size(500, 500),
            from: Alignment(1.1, -0.7),
            to: Alignment(0.55, -0.25),
            duration: Duration(seconds: 32),
          ),
          _Blob(
            color: Color(0x22F472B6),
            size: Size(380, 380),
            from: Alignment(0.9, 1.05),
            to: Alignment(0.3, 0.6),
            duration: Duration(seconds: 24),
          ),
          _Blob(
            color: Color(0x18F59E0B),
            size: Size(300, 300),
            from: Alignment(-1.05, 0.8),
            to: Alignment(-0.5, 0.45),
            duration: Duration(seconds: 30),
          ),
        ],
      );
}

/// Paint-once gradient mesh — zero per-frame cost.
class _StaticAurora extends StatelessWidget {
  const _StaticAurora();

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(
      size: Size.infinite,
      painter: _StaticAuroraPainter(),
    );
  }
}

class _StaticAuroraPainter extends CustomPainter {
  const _StaticAuroraPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const blobs = [
      (color: Color(0x2E14B8A6), center: Offset(0.12, 0.10), r: 0.55),
      (color: Color(0x286366F1), center: Offset(0.88, 0.18), r: 0.62),
      (color: Color(0x22F472B6), center: Offset(0.78, 0.92), r: 0.5),
      (color: Color(0x18F59E0B), center: Offset(0.10, 0.85), r: 0.42),
    ];
    final paint = Paint();
    for (final b in blobs) {
      paint.shader = RadialGradient(
        colors: [b.color, b.color.withValues(alpha: 0)],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * b.center.dx, size.height * b.center.dy),
          radius: size.longestSide * b.r,
        ),
      );
      canvas.drawCircle(
        Offset(size.width * b.center.dx, size.height * b.center.dy),
        size.longestSide * b.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StaticAuroraPainter oldDelegate) => false;
}

class _Blob extends StatefulWidget {
  const _Blob({
    required this.color,
    required this.size,
    required this.from,
    required this.to,
    required this.duration,
  });

  final Color color;
  final Size size;
  final Alignment from;
  final Alignment to;
  final Duration duration;

  @override
  State<_Blob> createState() => _BlobState();
}

class _BlobState extends State<_Blob> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);
  late final Animation<double> _t =
      CurvedAnimation(parent: _c, curve: Curves.easeInOut);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) {
        return Align(
          alignment:
              Alignment.lerp(widget.from, widget.to, _t.value)!,
          child: Container(
            width: widget.size.width,
            height: widget.size.height,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [widget.color, widget.color.withValues(alpha: 0)],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated progress ring used for calories + macros.
///
/// [bonusProgress] draws a second arc (e.g. exercise-earned allowance in
/// light green) continuing where the main arc ends. Zero (default) renders
/// pixel-identical to the single-arc ring.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    required this.color,
    required this.size,
    this.stroke = 10,
    this.trackOpacity = 0.12,
    this.child,
    this.gradientEnd,
    this.bonusProgress = 0,
    this.bonusColor,
  });

  final double progress; // 0..1 (clamped internally)
  final Color color;
  final Color? gradientEnd;
  final double size;
  final double stroke;
  final double trackOpacity;
  final Widget? child;

  /// Bonus fraction of the same whole, drawn after [progress].
  final double bonusProgress;
  final Color? bonusColor;

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);
    final b = bonusProgress
        .clamp(0.0, 1.0)
        .clamp(0.0, (1.0 - p).clamp(0.0, 1.0));
    // Nested builders so each arc keeps the original retarget-on-change
    // animation when its value updates (e.g. logging food mid-day).
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: p),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutExpo,
      builder: (context, main, child) =>
          TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: b),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutExpo,
        builder: (context, bonus, _) => CustomPaint(
          size: Size.square(size),
          painter: _RingPainter(
            progress: main,
            bonusProgress: bonus,
            color: color,
            stroke: stroke,
            trackOpacity: trackOpacity,
            gradientEnd: gradientEnd,
            bonusColor: bonusColor,
          ),
          child: child,
        ),
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.stroke,
    required this.trackOpacity,
    this.gradientEnd,
    this.bonusProgress = 0,
    this.bonusColor,
  });

  final double progress;
  final Color color;
  final Color? gradientEnd;
  final double stroke;
  final double trackOpacity;
  final double bonusProgress;
  final Color? bonusColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = Colors.white.withValues(alpha: trackOpacity),
    );

    if (progress <= 0 && bonusProgress <= 0) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
        transform: const GradientRotation(-math.pi / 2),
        colors: [color, gradientEnd ?? color],
        tileMode: TileMode.repeated,
      ).createShader(rect);

    // Overshoot glow when exceeding goal.
    if (progress >= 1) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..color = Colors.white.withValues(alpha: 0.25),
      );
    }

    if (progress > 0) {
      canvas.drawArc(
          rect, -math.pi / 2, 2 * math.pi * progress, false, paint);
    }
    if (bonusProgress > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2 + 2 * math.pi * progress,
        2 * math.pi * bonusProgress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = (bonusColor ?? color).withValues(alpha: 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.bonusProgress != bonusProgress ||
      old.color != color ||
      old.bonusColor != bonusColor ||
      old.stroke != stroke;
}

/// Shimmering skeleton block for loading states.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height = 16, this.radius = 8});
  final double? width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          gradient: LinearGradient(
            begin: Alignment(-1 - 2 + 4 * _c.value, 0),
            end: Alignment(2 * _c.value, 0),
            colors: const [
              Color(0x14FFFFFF),
              Color(0x2EFFFFFF),
              Color(0x14FFFFFF),
            ],
          ),
        ),
      ),
    );
  }
}
