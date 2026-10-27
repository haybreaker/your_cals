import 'package:flutter/material.dart';

/// The ONE progress bar in the app (liquid-glass teal language).
///
/// Full-width track guaranteed by construction: the background fills the
/// available width and the fill is a fraction of it — so 0% reads as an
/// empty track, never as a broken/missing line. Replaces the ad-hoc
/// Container-based bars that shrink-wrapped to their fill width.
class YcProgressBar extends StatelessWidget {
  const YcProgressBar({
    super.key,
    required this.fraction,
    required this.color,
    this.height = 8,
    this.trackAlpha = 0.08,
    this.animate = true,
  });

  /// 0..1 fill. Clamped.
  final double fraction;
  final Color color;
  final double height;

  /// Opacity of the frosted track.
  final double trackAlpha;
  final bool animate;

  /// Convenience for value-vs-target bars (macros, budgets).
  factory YcProgressBar.of({
    Key? key,
    required double value,
    required double target,
    required Color color,
    double height = 8,
    bool animate = true,
  }) {
    final p = target <= 0 ? 0.0 : (value / target).clamp(0.0, 1.0);
    return YcProgressBar(
      key: key,
      fraction: p,
      color: color,
      height: height,
      animate: animate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = fraction.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Stack(
        children: [
          Container(
            height: height,
            color: Colors.white.withValues(alpha: trackAlpha),
          ),
          FractionallySizedBox(
            widthFactor: p,
            alignment: Alignment.centerLeft,
            child: animate
                ? TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutExpo,
                    builder: (context, t, _) => Opacity(
                      opacity: t,
                      child: Container(height: height, color: color),
                    ),
                  )
                : Container(height: height, color: color),
          ),
        ],
      ),
    );
  }
}
