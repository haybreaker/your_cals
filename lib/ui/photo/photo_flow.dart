import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import '../../core/format.dart';
import '../../core/fx.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../domain/nutriments.dart' hide FoodSource;
import '../../state/providers.dart';
import '../common/portion_input.dart';

class PhotoFlowRoute extends PageRouteBuilder {
  PhotoFlowRoute(String imagePath, {MealType? initialMeal})
      : super(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 300),
          pageBuilder: (_, _, _) =>
              PhotoFlowScreen(imagePath: imagePath, initialMeal: initialMeal),
          transitionsBuilder: (_, anim, _, child) => FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween(begin: 0.96, end: 1.0)
                  .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          ),
        );
}

class PhotoFlowScreen extends ConsumerStatefulWidget {
  const PhotoFlowScreen({super.key, required this.imagePath, this.initialMeal});

  final String imagePath;
  final MealType? initialMeal;

  @override
  ConsumerState<PhotoFlowScreen> createState() => _PhotoFlowScreenState();
}

class _PhotoFlowScreenState extends ConsumerState<PhotoFlowScreen> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  bool get _isTextFlow => widget.imagePath.isEmpty;

  Future<void> _start() async {
    if (_started) return;
    _started = true;
    // Text flows drive the controller directly (analyzeText) — there is
    // no image to compress, and touching the empty path would reset+pop.
    if (_isTextFlow) return;
    try {
      final bytes = await FlutterImageCompress.compressWithFile(
        widget.imagePath,
        minWidth: 1024,
        minHeight: 1024,
        quality: 82,
      );
      if (bytes == null || bytes.isEmpty) throw Exception('compress');
      if (mounted) {
        ref
            .read(photoFlowControllerProvider.notifier)
            .analyze(bytes.toList(), widget.imagePath);
      }
    } catch (_) {
      // Fall back to raw bytes if compression unavailable.
      try {
        final raw = await File(widget.imagePath).readAsBytes();
        if (mounted) {
          ref.read(photoFlowControllerProvider.notifier).analyze(raw, widget.imagePath);
        }
      } catch (_) {
        if (mounted) {
          ref
              .read(photoFlowControllerProvider.notifier)
              .reset();
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(photoFlowControllerProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (widget.imagePath.isNotEmpty)
            Positioned.fill(
              child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
            ),
          const Positioned.fill(child: ColoredBox(color: Color(0x88000000))),
          const AuroraBackground(),
          SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        ref.read(photoFlowControllerProvider.notifier).reset();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                    ),
                    const Spacer(),
                  ],
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    child: switch (state) {
                      PhotoAnalyzing() =>
                        _AnalyzingView(key: const ValueKey('analyzing'), path: state.previewPath),
                      PhotoReady() => _ReadyView(
                          key: ValueKey('ready-${state.items.length}'),
                          state: state,
                          initialMeal: widget.initialMeal),
                      PhotoError(:final message) => _ErrorView(
                          key: const ValueKey('error'),
                          message: message,
                          path: widget.imagePath),
                      _ => const SizedBox(),
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Analyzing: scanning beam over the photo ────────────────────────────────

class _AnalyzingView extends StatefulWidget {
  const _AnalyzingView({super.key, required this.path});
  final String path;

  @override
  State<_AnalyzingView> createState() => _AnalyzingViewState();
}

class _AnalyzingViewState extends State<_AnalyzingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  static const _statusTexts = [
    'Identifying foods…',
    'Estimating portions…',
    'Checking hidden oils & sauces…',
    'Matching verified databases…',
  ];

  final Stopwatch _elapsed = Stopwatch()..start();
  late final Timer _ticker =
      Timer.periodic(const Duration(milliseconds: 250), (_) {
    if (mounted) setState(() {});
  });

  @override
  void dispose() {
    _ticker.cancel();
    _elapsed.stop();
    _c.dispose();
    super.dispose();
  }

  String get _elapsedText {
    final s = _elapsed.elapsedMilliseconds ~/ 1000;
    return '$s s';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SizedBox(
              width: 240,
              height: 240,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.path.isNotEmpty)
                    Image.file(File(widget.path), fit: BoxFit.cover)
                  else
                    const ColoredBox(
                      color: Color(0xFF0E1512),
                      child: Center(
                        child: Icon(Icons.auto_awesome_rounded,
                            size: 64, color: Yc.calories),
                      ),
                    ),
                  const ColoredBox(color: Color(0x55000000)),
                  AnimatedBuilder(
                    animation: _c,
                    builder: (context, _) => Positioned(
                      top: _c.value * 240 - 30,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Yc.calories.withValues(alpha: 0),
                              Yc.calories.withValues(alpha: 0.35),
                              Yc.calories.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 26),
          Text(
            _statusTexts[(_elapsed.elapsedMilliseconds ~/ 1400) %
                _statusTexts.length],
            style: const TextStyle(color: Yc.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 18),
          const CircularProgressIndicator(color: Yc.calories),
          const SizedBox(height: 12),
          Text(
            _elapsedText,
            style: const TextStyle(color: Yc.textTertiary, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── Ready: editable detected items ─────────────────────────────────────────

class _ReadyView extends ConsumerWidget {
  const _ReadyView({
    super.key,
    required this.state,
    required this.initialMeal,
  });

  final PhotoReady state;
  final MealType? initialMeal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalsKcal =
        state.items.fold<double>(0, (a, p) => a + p.nutr.kcal);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Glass(
            radius: 22,
            opacity: 0.12,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: Yc.calories, size: 20),
                    const SizedBox(width: 10),
                    Text(
                        '${state.items.length} items · ${totalsKcal.kcalText} kcal',
                        style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    const Text('adjust portions below',
                        style: TextStyle(
                            fontSize: 11.5, color: Yc.textTertiary)),
                  ],
                ),
                if (state.description != null &&
                    state.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('“${state.description}”',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Yc.textSecondary)),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            itemCount: state.items.length,
            itemBuilder: (context, i) {
              final item = state.items[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ItemCard(index: i, item: item),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Yc.calories,
              foregroundColor: const Color(0xFF06251B),
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
            ),
            onPressed: state.items.isEmpty
                ? null
                : () async {
                    final date = DateTime.now();
                    final day =
                        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                    final meal = initialMeal ?? MealTypeX.forNow(date);
                    final repo = ref.read(diaryRepoProvider);
                    final foodRepo = ref.read(foodRepoProvider);
                    for (final item in state.items) {
                      final food = item.matchedFood != null
                          ? item.matchedFood!
                          : item.detected.toAiFood();
                      if (item.matchedFood == null) {
                        await foodRepo.upsertFood(food); // remember AI foods
                      } else {
                        await foodRepo.upsertFood(food);
                      }
                      await repo.add(
                        day: day,
                        meal: meal,
                        food: food.copyWith(),
                        grams: item.grams,
                        photoPath: state.previewPath.isEmpty
                            ? null
                            : state.previewPath,
                      );
                    }
                    ref.read(photoFlowControllerProvider.notifier).reset();
                    if (context.mounted) Navigator.of(context).pop();
                  },
            icon: const Icon(Icons.check_rounded),
            label: Text('Log ${state.items.length} items',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5)),
          ),
        ),
      ],
    );
  }
}

class _ItemCard extends ConsumerWidget {
  const _ItemCard({required this.index, required this.item});

  final int index;
  final PendingItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conf = item.detected.confidence;
    final verified = item.matchedFood?.source.verified ?? false;

    final flowState = ref.watch(photoFlowControllerProvider);
    final correcting =
        (flowState is PhotoReady ? flowState.correctingIndex : null) == index;

    return LiquidCard(
      radius: 22,
      opacity: 0.09,
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
        IgnorePointer(
        ignoring: correcting,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _showCorrectionSheet(context, ref),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.matchedFood?.displayName ??
                              item.detected.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.edit_rounded,
                          size: 14, color: Yc.textTertiary),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: verified
                      ? Yc.success.withValues(alpha: 0.15)
                      : Yc.protein.withValues(alpha: 0.15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      verified
                          ? Icons.verified_rounded
                          : Icons.auto_awesome_rounded,
                      size: 12,
                      color: verified ? Yc.success : Yc.protein,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      verified
                          ? (item.matchedFood!.source.label)
                          : '${(conf * 100).round()}%',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: verified ? Yc.success : Yc.protein,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () => ref
                    .read(photoFlowControllerProvider.notifier)
                    .removeItem(index),
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: Yc.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MacroPill(label: 'kcal', value: item.nutr.kcal.kcalText, color: Yc.calories),
              const SizedBox(width: 8),
              _MacroPill(label: 'P', value: item.nutr.protein.gText, color: Yc.protein),
              const SizedBox(width: 8),
              _MacroPill(label: 'C', value: item.nutr.carbs.gText, color: Yc.carbs),
              const SizedBox(width: 8),
              _MacroPill(label: 'F', value: item.nutr.fat.gText, color: Yc.fat),
            ],
          ),
          const SizedBox(height: 12),
          _AiPortionInput(index: index, item: item),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${formatQty(item.grams)} g',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 16)),
              if (!verified)
                Text(
                    'tap name to correct · ${item.matchedFood != null ? 'DB match' : 'AI estimate'}',
                    style: const TextStyle(
                        fontSize: 11, color: Yc.textTertiary)),
            ],
          ),
        ],
      ),
        ),
        if (correcting)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x9906070D),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Yc.calories),
                    SizedBox(height: 10),
                    Text('Re-analysing…',
                        style:
                            TextStyle(fontSize: 12.5, color: Yc.textSecondary)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCorrectionSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (sheetCtx) => _CorrectionSheet(
        item: item,
        onSubmit: (text) {
          Navigator.pop(sheetCtx);
          ref
              .read(photoFlowControllerProvider.notifier)
              .correctItem(index, text);
        },
        onPickAlternative: (alt) {
          Navigator.pop(sheetCtx);
          ref
              .read(photoFlowControllerProvider.notifier)
              .correctItem(index, alt);
        },
      ),
    );
  }
}

/// Recipe-style portion editor for one AI item (replaces the old gram
/// slider, which couldn't represent servings/ml/tsp and appeared stuck
/// for AI-estimate items). Servings come from the verified DB match when
/// present, otherwise a plain 100 g fallback.
class _AiPortionInput extends ConsumerWidget {
  const _AiPortionInput({required this.index, required this.item});

  final int index;
  final PendingItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servings = item.matchedFood?.allServings ??
        const [ServingOption(label: '100 g', grams: 100)];
    final fallback = item.matchedFood?.defaultGrams ?? item.detected.grams;
    final safeIdx = item.servingIdx.clamp(0, servings.length - 1);
    return PortionInput(
      qty: item.qty,
      unit: item.unit,
      servingIdx: safeIdx,
      servings: servings,
      servingGramsFallback: fallback > 0 ? fallback : 100,
      onChanged: (q, u, si) {
        final grams = servings[si.clamp(0, servings.length - 1)].grams;
        ref.read(photoFlowControllerProvider.notifier).updatePortion(
              index,
              qty: q,
              unit: u,
              servingIdx: si,
              servingGrams: grams,
            );
      },
    );
  }
}

/// "It was actually…" sheet: AI alternatives + free-text correction.
class _CorrectionSheet extends StatefulWidget {
  const _CorrectionSheet({
    required this.item,
    required this.onSubmit,
    required this.onPickAlternative,
  });

  final PendingItem item;
  final void Function(String) onSubmit;
  final void Function(String) onPickAlternative;

  @override
  State<_CorrectionSheet> createState() => _CorrectionSheetState();
}

class _CorrectionSheetState extends State<_CorrectionSheet> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final alts = widget.item.detected.alternatives;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Glass(
        radius: 30,
        blur: 30,
        opacity: 0.14,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Was "${widget.item.detected.name}" actually…',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15.5)),
            const SizedBox(height: 12),
            if (alts.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: alts
                    .map((a) => ActionChip(
                          label:
                              Text(a, style: const TextStyle(fontSize: 12.5)),
                          backgroundColor: Yc.protein.withValues(alpha: 0.14),
                          side: BorderSide(
                              color: Yc.protein.withValues(alpha: 0.35)),
                          onPressed: () => widget.onPickAlternative(a),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 14),
            TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'It was actually… (e.g. grilled salmon)',
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (v) {
                if (v.trim().isNotEmpty) widget.onSubmit(v);
              },
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Yc.calories,
                foregroundColor: const Color(0xFF06251B),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: () {
                if (_ctrl.text.trim().isNotEmpty) {
                  widget.onSubmit(_ctrl.text);
                }
              },
              icon: const Icon(Icons.auto_fix_high_rounded, size: 19),
              label: const Text('Re-analyse with AI',
                  style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroPill extends StatelessWidget {
  const _MacroPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color.withValues(alpha: 0.11),
      ),
      child: Text('$value $label',
          style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: color.withValues(alpha: 0.95))),
    );
  }
}

// ─── Error ──────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({super.key, required this.message, required this.path});

  final String message;
  final String path;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Glass(
          radius: 26,
          opacity: 0.12,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  color: Yc.danger, size: 40),
              const SizedBox(height: 14),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, height: 1.35)),
              const SizedBox(height: 20),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Yc.calories,
                  foregroundColor: const Color(0xFF06251B),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
