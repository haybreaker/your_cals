import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
// intl ships its own TextDirection (LTR/RTL) — hide it so dart:ui's wins.
import 'package:intl/intl.dart' hide TextDirection;

import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/ai/gemini_client.dart';
import '../../domain/weight.dart';
import '../../state/providers.dart';
import '../common/yc_progress_bar.dart';
import '../settings/settings_page.dart';

/// Goals tab: weigh-in trend graph, logging streak, and macro adherence.
class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 120),
        children: [
          Text(
            'Goals',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),
          const _WeightCard(),
          const SizedBox(height: 12),
          const _StreakCard(),
          const SizedBox(height: 12),
          const _MacroAdherenceCard(),
        ],
      ),
    );
  }
}

// ─── Weight graph ─────────────────────────────────────────────────────────────

/// Graph window presets (default 3 months).
enum _WeightRange { m1, m3, m6, all }

extension on _WeightRange {
  String get label => switch (this) {
    _WeightRange.m1 => '1M',
    _WeightRange.m3 => '3M',
    _WeightRange.m6 => '6M',
    _WeightRange.all => 'All',
  };

  Duration? get window => switch (this) {
    _WeightRange.m1 => const Duration(days: 31),
    _WeightRange.m3 => const Duration(days: 93),
    _WeightRange.m6 => const Duration(days: 186),
    _WeightRange.all => null,
  };
}

class _WeightCard extends ConsumerStatefulWidget {
  const _WeightCard();

  @override
  ConsumerState<_WeightCard> createState() => _WeightCardState();
}

class _WeightCardState extends ConsumerState<_WeightCard> {
  _WeightRange _range = _WeightRange.m3;

  @override
  Widget build(BuildContext context) {
    final weightsAsync = ref.watch(weightEntriesProvider);
    final weights = weightsAsync.value ?? const <WeightEntry>[];

    final now = DateTime.now();
    final window = _range.window;
    final visible = window == null
        ? weights
        : weights.where((w) => now.difference(w.createdAt) <= window).toList();

    final latest = weights.isEmpty ? null : weights.last;
    // First weigh-in convenience: pre-fill with the profile weight the
    // user entered during onboarding / TDEE recalc.
    final profileWeight = ref.watch(profileProvider).value?.weightKg;

    return LiquidCard(
      radius: YcRadii.lg,
      opacity: 0.09,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Weight',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
              ),
              const Spacer(),
              if (latest != null)
                Text(
                  '${latest.weightKg.gText} kg',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Yc.calories,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Range chips (wraps instead of clipping at large text sizes).
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _WeightRange.values.map((r) {
              final sel = r == _range;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _range = r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(99),
                    color: sel
                        ? Yc.calories.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: sel
                          ? Yc.calories.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Text(
                    r.label,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: sel ? Yc.calories : Yc.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            width: double.infinity,
            child: visible.length < 2
                ? Center(
                    child: Text(
                      weights.isEmpty
                          ? 'Log your first weigh-in below to start your trend.'
                          : 'Log one more weigh-in to draw your trend.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Yc.textTertiary,
                        height: 1.5,
                      ),
                    ),
                  )
                : CustomPaint(painter: _WeightChartPainter(entries: visible)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Long-press to import from a graph photo.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Yc.textTertiary,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _LogWeightButton(initialKg: latest?.weightKg ?? profileWeight),
            ],
          ),
        ],
      ),
    );
  }
}

/// Minimal line chart: accent line, gradient fill, endpoint dots.
class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter({required this.entries});

  final List<WeightEntry> entries;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    const padL = 8.0, padR = 8.0, padT = 12.0, padB = 22.0;
    final plotW = size.width - padL - padR;
    final plotH = size.height - padT - padB;

    var minW = entries.first.weightKg, maxW = entries.first.weightKg;
    for (final e in entries) {
      if (e.weightKg < minW) minW = e.weightKg;
      if (e.weightKg > maxW) maxW = e.weightKg;
    }
    // Raw data range for the label (padding below is plot-only).
    final rawMin = minW;
    final rawMax = maxW;
    var span = maxW - minW;
    if (span < 2) {
      // Flat line would be invisible — pad symmetrically.
      minW -= 1;
      maxW += 1;
      span = maxW - minW;
    } else {
      final pad = span * 0.25;
      minW -= pad;
      maxW += pad;
      span = maxW - minW;
    }

    final first = entries.first.createdAt;
    final last = entries.last.createdAt;
    var timeSpan = last.difference(first).inMilliseconds.toDouble();
    if (timeSpan <= 0) timeSpan = 1;

    Offset pt(WeightEntry e) {
      final x =
          padL +
          e.createdAt.difference(first).inMilliseconds / timeSpan * plotW;
      final y = padT + (1 - (e.weightKg - minW) / span) * plotH;
      return Offset(x, y);
    }

    final pts = entries.map(pt).toList();

    // Area fill.
    final fillPath = Path()
      ..moveTo(pts.first.dx, padT + plotH)
      ..lineTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      fillPath.lineTo(pts[i].dx, pts[i].dy);
    }
    fillPath
      ..lineTo(pts.last.dx, padT + plotH)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Yc.calories.withValues(alpha: 0.28),
            Yc.calories.withValues(alpha: 0.02),
          ],
        ).createShader(Rect.fromLTWH(0, padT, size.width, plotH)),
    );

    // Trend line.
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      linePath.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = Yc.calories
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Dots (latest emphasized).
    for (var i = 0; i < pts.length; i++) {
      final last = i == pts.length - 1;
      canvas.drawCircle(
        pts[i],
        last ? 4.5 : 2.5,
        Paint()
          ..color = last ? Yc.calories : Yc.calories.withValues(alpha: 0.55),
      );
    }

    // Min/max labels.
    final labelStyle = TextStyle(
      fontSize: 10.5,
      color: Yc.textTertiary.withValues(alpha: 0.9),
      fontWeight: FontWeight.w600,
    );
    void label(String text, Offset anchor, TextAlign align) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: labelStyle),
        textAlign: align,
        textDirection: TextDirection.ltr,
      )..layout();
      final dx = align == TextAlign.right ? size.width - padR - tp.width : padL;
      tp.paint(canvas, Offset(dx, anchor.dy));
    }

    // Labels own unique anchors: range top-left, dates bottom-left /
    // bottom-right. The old bottom-right min value shared its corner
    // with the last date and overlapped it.
    label('${rawMin.gText} – ${rawMax.gText} kg', Offset.zero, TextAlign.left);

    // Date labels: first + last.
    final df = DateFormat('d MMM');
    final dateStyle = labelStyle;
    void dateLabel(String text, double x, bool right) {
      final tp = TextPainter(
        text: TextSpan(text: text, style: dateStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(right ? x - tp.width : x, padT + plotH + 6));
    }

    dateLabel(df.format(entries.first.createdAt), padL, false);
    dateLabel(df.format(entries.last.createdAt), size.width - padR, true);
  }

  @override
  bool shouldRepaint(_WeightChartPainter old) => old.entries != entries;
}

/// Liquid-glass "Log weight" pill → bottom sheet with a numeric input.
/// Long-press imports past weigh-ins from a graph screenshot via Gemini.
class _LogWeightButton extends ConsumerWidget {
  const _LogWeightButton({this.initialKg});

  final double? initialKg;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _openLogWeight(context, ref),
      onLongPress: () => _startGraphImport(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.16),
              Colors.white.withValues(alpha: 0.07),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monitor_weight_rounded, size: 17, color: Yc.calories),
            SizedBox(width: 7),
            Text(
              'Log weight',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Yc.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLogWeight(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => _LogWeightSheet(initialKg: initialKg),
    );
  }
}

// ─── Graph-screenshot import (long-press) ────────────────────────────────────

/// Long-press flow: pick a graph screenshot → AI extracts dated weigh-ins
/// → review → bulk import, skipping already-logged days.
Future<void> _startGraphImport(BuildContext context, WidgetRef ref) async {
  HapticFeedback.mediumImpact();

  final key = ref.read(geminiKeyProvider).key;
  if (key == null || key.trim().isEmpty) {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _ImportNoKeyDialog(),
    );
    return;
  }
  final apiKey = key.trim();
  final client = ref.read(geminiClientProvider);
  final repo = ref.read(weightRepoProvider);

  var retake = true;
  while (retake && context.mounted) {
    retake = false;

    // 1. Pick the screenshot.
    XFile? file;
    try {
      file = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        imageQuality: 90,
      );
    } catch (_) {
      return;
    }
    if (file == null || !context.mounted) return;
    final bytes = await file.readAsBytes();
    final mime = file.path.toLowerCase().endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';

    // 2. Analyse (Retry re-runs the same image for transient errors).
    List<WeightPoint>? points;
    while (true) {
      if (!context.mounted) return;
      final outcome = await showDialog<_ImportOutcome>(
        context: context,
        barrierColor: Colors.black54,
        barrierDismissible: false,
        builder: (_) => _ImportProgressDialog(
          run: () => client.analyzeWeightGraph(
            bytes: bytes,
            mimeType: mime,
            apiKey: apiKey,
          ),
        ),
      );
      if (outcome == null) return; // user cancelled
      final error = outcome.error;
      if (error == null) {
        points = outcome.points ?? const [];
        break;
      }
      if (!context.mounted) return;
      final retry = await showDialog<bool>(
        context: context,
        barrierColor: Colors.black54,
        builder: (_) => _ImportErrorDialog(message: error),
      );
      if (retry != true) return;
    }
    final List<WeightPoint> resolved = points;
    if (!context.mounted) return;
    // Long graphs (years) come back as hundreds of noisy points —
    // condense to the weekly trend before reviewing/importing.
    final trend = GeminiClient.weeklyTrend(resolved);

    // 3. Review (Retake re-opens the picker).
    final existing = await repo.existingDayKeys();
    if (!context.mounted) return;
    final action = await showDialog<_ReviewAction>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _ImportReviewDialog(
        points: trend,
        rawCount: resolved.length,
        existingKeys: existing,
      ),
    );
    if (action == _ReviewAction.retake) {
      retake = true;
      continue;
    }
    if (action != _ReviewAction.save) return;
    final fresh = trend
        .where((p) => !existing.contains(p.date.dayKey))
        .map((p) => (date: p.date, weightKg: p.weightKg));
    final res = await repo.addMany(fresh);
    // Imported history can shift the latest reading — re-sync the
    // profile so the live target tracks it.
    await syncProfileWeightToLatest(ref);
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) =>
          _ImportDoneDialog(inserted: res.inserted, skipped: res.skipped),
    );
  }
}

class _ImportOutcome {
  const _ImportOutcome({this.points, this.error});
  final List<WeightPoint>? points;
  final String? error;
}

enum _ReviewAction { save, retake, cancel }

/// Runs the import future, then pops itself with the outcome.
/// Cancel pops with null (the result is discarded on arrival).
class _ImportProgressDialog extends StatefulWidget {
  const _ImportProgressDialog({required this.run});

  final Future<List<WeightPoint>> Function() run;

  @override
  State<_ImportProgressDialog> createState() => _ImportProgressDialogState();
}

class _ImportProgressDialogState extends State<_ImportProgressDialog> {
  @override
  void initState() {
    super.initState();
    _go();
  }

  Future<void> _go() async {
    List<WeightPoint>? points;
    String? error;
    try {
      points = await widget.run();
    } catch (e) {
      error = e is GeminiException ? e.message : '$e';
    }
    if (mounted) {
      Navigator.of(context).pop(_ImportOutcome(points: points, error: error));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Glass(
        radius: Yc.radiusMd,
        blur: 30,
        opacity: 0.14,
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Yc.calories,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Reading your graph…',
              style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pulling the full trend out of the screenshot.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Yc.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Yc.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportNoKeyDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Glass(
        radius: Yc.radiusMd,
        blur: 30,
        opacity: 0.14,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gemini API key needed',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Graph imports use AI. Add your free key in Settings first — it stays on this device.',
              style: TextStyle(
                fontSize: 13,
                color: Yc.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Not now',
                    style: TextStyle(color: Yc.textSecondary),
                  ),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Yc.calories,
                    foregroundColor: Yc.onAccent,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        transitionDuration: const Duration(milliseconds: 300),
                        pageBuilder: (_, _, _) => const SettingsPage(),
                        transitionsBuilder: (_, anim, _, child) =>
                            SlideTransition(
                              position:
                                  Tween(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(
                                    CurvedAnimation(
                                      parent: anim,
                                      curve: Curves.easeOutCubic,
                                    ),
                                  ),
                              child: child,
                            ),
                      ),
                    );
                  },
                  child: const Text(
                    'Open Settings',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportErrorDialog extends StatelessWidget {
  const _ImportErrorDialog({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Glass(
        radius: Yc.radiusMd,
        blur: 30,
        opacity: 0.14,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Import failed',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Yc.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Yc.textSecondary),
                  ),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Yc.calories,
                    foregroundColor: Yc.onAccent,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text(
                    'Retry',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Review what the AI read as a range summary (never a day list — long
/// graphs condense to hundreds of points). Already-logged weeks are
/// marked and excluded from the save count.
class _ImportReviewDialog extends StatelessWidget {
  const _ImportReviewDialog({
    required this.points,
    required this.rawCount,
    required this.existingKeys,
  });

  /// Condensed trend points (weekly medians for long ranges).
  final List<WeightPoint> points;

  /// Raw readings extracted, before condensing.
  final int rawCount;
  final Set<String> existingKeys;

  @override
  Widget build(BuildContext context) {
    final fresh = points
        .where((p) => !existingKeys.contains(p.date.dayKey))
        .toList();
    final skipped = points.length - fresh.length;
    final df = DateFormat('d MMM yyyy');
    final condensed = rawCount > points.length;

    String? range;
    String? movement;
    if (fresh.isNotEmpty) {
      range = '${df.format(fresh.first.date)} → ${df.format(fresh.last.date)}';
      if (fresh.length >= 2) {
        final d = fresh.last.weightKg - fresh.first.weightKg;
        movement =
            '${fresh.first.weightKg.gText} → ${fresh.last.weightKg.gText} kg '
            '(${d < 0 ? '\u2212' : '+'}${d.abs().gText})';
      } else {
        movement = '${fresh.first.weightKg.gText} kg';
      }
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30),
      child: Glass(
        radius: Yc.radiusMd,
        blur: 30,
        opacity: 0.14,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              points.isEmpty
                  ? 'Nothing found'
                  : fresh.isEmpty
                  ? 'Already imported'
                  : 'Import weigh-ins',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              points.isEmpty
                  ? 'Couldn\u2019t read any weights from that screenshot — try a clearer crop of the graph.'
                  : fresh.isEmpty
                  ? 'All ${points.length} weeks are already logged — nothing to add.'
                  : 'Covers the full range in the screenshot'
                        '${skipped > 0 ? ' · $skipped already logged (skipped)' : ''}.',
              style: const TextStyle(
                fontSize: 13,
                color: Yc.textSecondary,
                height: 1.45,
              ),
            ),
            if (fresh.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${fresh.length} weekly trend point${fresh.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      range!,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Yc.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      movement!,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: Yc.calories,
                      ),
                    ),
                    if (condensed) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Smoothed from $rawCount readings — daily noise removed.',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Yc.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_ReviewAction.retake),
                  child: const Text(
                    'Retake',
                    style: TextStyle(color: Yc.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_ReviewAction.cancel),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Yc.textSecondary),
                  ),
                ),
                const SizedBox(width: 4),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Yc.calories,
                    foregroundColor: Yc.onAccent,
                  ),
                  // Nothing to save → primary just closes the dialog.
                  onPressed: fresh.isEmpty
                      ? () => Navigator.of(context).pop(_ReviewAction.cancel)
                      : () => Navigator.of(context).pop(_ReviewAction.save),
                  child: Text(
                    fresh.isEmpty ? 'Done' : 'Import ${fresh.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportDoneDialog extends StatelessWidget {
  const _ImportDoneDialog({required this.inserted, required this.skipped});

  final int inserted;
  final int skipped;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Glass(
        radius: Yc.radiusMd,
        blur: 30,
        opacity: 0.14,
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weigh-ins imported',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              '$inserted added to your graph'
              '${skipped > 0 ? ' · $skipped skipped (already logged)' : ''}.',
              style: const TextStyle(
                fontSize: 13,
                color: Yc.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Yc.calories,
                  foregroundColor: Yc.onAccent,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Done',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogWeightSheet extends ConsumerStatefulWidget {
  const _LogWeightSheet({this.initialKg});

  final double? initialKg;

  @override
  ConsumerState<_LogWeightSheet> createState() => _LogWeightSheetState();
}

class _LogWeightSheetState extends ConsumerState<_LogWeightSheet> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.initialKg == null ? '' : widget.initialKg!.gText,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Glass(
        radius: 34,
        blur: 30,
        opacity: 0.13,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Log weight',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              "Today's weigh-in — the graph updates instantly.",
              style: TextStyle(
                fontSize: 13,
                color: Yc.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'e.g. 72.5',
                      suffixText: 'kg',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Yc.calories,
                    foregroundColor: Yc.onAccent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 16,
                    ),
                  ),
                  onPressed: () async {
                    final v = double.tryParse(
                      _ctrl.text.trim().replaceAll(',', '.'),
                    );
                    if (v == null || v <= 20 || v > 400) return;
                    // Weigh-in moves the live target forward AND syncs the
                    // profile so TDEE/sliders track it; past days keep the
                    // targets that were live then.
                    await logWeight(ref, v);
                    if (context.mounted) Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Streak ───────────────────────────────────────────────────────────────────

class _StreakCard extends ConsumerWidget {
  const _StreakCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streak = ref.watch(streakProvider).value ?? 0;

    return LiquidCard(
      radius: YcRadii.lg,
      opacity: 0.09,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Yc.carbs.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 27,
              color: Yc.carbs,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  streak == 0
                      ? 'No streak yet'
                      : '$streak day${streak == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  streak == 0
                      ? 'Log today to start your streak.'
                      : 'days logged in a row — keep it burning.',
                  style: const TextStyle(fontSize: 13, color: Yc.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Macro adherence ──────────────────────────────────────────────────────────

class _MacroAdherenceCard extends ConsumerWidget {
  const _MacroAdherenceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adherence = ref.watch(weeklyMacroAdherenceProvider).value;

    return LiquidCard(
      radius: YcRadii.lg,
      opacity: 0.09,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This week: macros on target',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
          ),
          const SizedBox(height: 4),
          const Text(
            'Days within ±15% of target — last 7 logged days.',
            style: TextStyle(
              fontSize: 12.5,
              color: Yc.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          if (adherence == null || adherence.days == 0)
            const Text(
              'Log a few days to see how your macros track.',
              style: TextStyle(
                fontSize: 13,
                color: Yc.textTertiary,
                height: 1.5,
              ),
            )
          else ...[
            _AdherenceRow(
              label: 'Protein',
              color: Yc.protein,
              hit: adherence.proteinDays,
              days: adherence.days,
            ),
            const SizedBox(height: 10),
            _AdherenceRow(
              label: 'Carbs',
              color: Yc.carbs,
              hit: adherence.carbsDays,
              days: adherence.days,
            ),
            const SizedBox(height: 10),
            _AdherenceRow(
              label: 'Fat',
              color: Yc.fat,
              hit: adherence.fatDays,
              days: adherence.days,
            ),
            const SizedBox(height: 12),
            Text(
              _verdict(adherence),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Yc.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _verdict(MacroAdherence a) {
    if (a.days == 0) return '';
    final worst = [
      ('protein', a.proteinDays),
      ('carbs', a.carbsDays),
      ('fat', a.fatDays),
    ]..sort((x, y) => x.$2.compareTo(y.$2));
    if (worst.first.$2 == a.days) {
      return 'Perfect week — every macro on target every logged day.';
    }
    return 'Watch your ${worst.first.$1} — on target ${worst.first.$2} of ${a.days} days.';
  }
}

class _AdherenceRow extends StatelessWidget {
  const _AdherenceRow({
    required this.label,
    required this.color,
    required this.hit,
    required this.days,
  });

  final String label;
  final Color color;
  final int hit;
  final int days;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: Yc.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$hit / $days days',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Yc.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        YcProgressBar(fraction: days <= 0 ? 0.0 : hit / days, color: color),
      ],
    );
  }
}
