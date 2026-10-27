import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../domain/food.dart';
import '../../domain/nutriments.dart';
import '../../state/providers.dart';
import 'add_food_manually_sheet.dart' show openFixProductSheet, openManualFoodEntry;
import 'search_sheet.dart' show openPortionEditor;

/// Adult AU/NZ reference intakes used for %Daily Intake bars.
const Map<String, ({String label, String unit, double rdi})> kMicroSpec = {
  'vitC': (label: 'Vitamin C', unit: 'mg', rdi: 45),
  'vitA': (label: 'Vitamin A', unit: 'µg', rdi: 900),
  'vitB1': (label: 'Thiamin (B1)', unit: 'mg', rdi: 1.1),
  'vitB2': (label: 'Riboflavin (B2)', unit: 'mg', rdi: 1.3),
  'vitB3': (label: 'Niacin (B3)', unit: 'mg', rdi: 10),
  'vitB6': (label: 'Vitamin B6', unit: 'mg', rdi: 1.3),
  'vitB12': (label: 'Vitamin B12', unit: 'µg', rdi: 2.4),
  'folate': (label: 'Folate', unit: 'µg', rdi: 400),
  'calcium': (label: 'Calcium', unit: 'mg', rdi: 1000),
  'iron': (label: 'Iron', unit: 'mg', rdi: 8),
  'magnesium': (label: 'Magnesium', unit: 'mg', rdi: 400),
  'potassium': (label: 'Potassium', unit: 'mg', rdi: 3800),
  'zinc': (label: 'Zinc', unit: 'mg', rdi: 14),
};

double _microOf(Nutriments n, String key) => switch (key) {
      'vitC' => n.vitCMg,
      'vitA' => n.vitAMcg,
      'vitB1' => n.vitB1Mg,
      'vitB2' => n.vitB2Mg,
      'vitB3' => n.vitB3Mg,
      'vitB6' => n.vitB6Mg,
      'vitB12' => n.vitB12Ug,
      'folate' => n.folateUg,
      'calcium' => n.calciumMg,
      'iron' => n.ironMg,
      'magnesium' => n.magnesiumMg,
      'potassium' => n.potassiumMg,
      'zinc' => n.zincMg,
      _ => 0,
    };

Future<void> openFoodDetail(BuildContext context, Food food) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) => Glass(
        radius: 34,
        blur: 30,
        opacity: 0.13,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
          child: FoodDetailBody(food: food),
        ),
      ),
    ),
  );
}

class FoodDetailBody extends ConsumerStatefulWidget {
  const FoodDetailBody({super.key, required this.food});

  final Food food;

  @override
  ConsumerState<FoodDetailBody> createState() => _FoodDetailBodyState();
}

class _FoodDetailBodyState extends ConsumerState<FoodDetailBody> {
  late bool _isFavorite = widget.food.isFavorite;
  bool _favPending = false;

  @override
  void didUpdateWidget(FoodDetailBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.food.id != widget.food.id ||
        oldWidget.food.isFavorite != widget.food.isFavorite) {
      _isFavorite = widget.food.isFavorite;
    }
  }

  Future<void> _toggleFavorite() async {
    if (_favPending) return;
    final next = !_isFavorite;
    setState(() {
      _favPending = true;
      _isFavorite = next;
    });
    try {
      await ref.read(foodRepoProvider).setFavorite(widget.food.id, next);
    } catch (_) {
      if (mounted) setState(() => _isFavorite = !next);
    } finally {
      if (mounted) setState(() => _favPending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final n = food.per100;
    final pCal = n.proteinG * 4;
    final cCal = n.carbsG * 4;
    final fCal = n.fatG * 9;
    final totalMacroCal = math.max(pCal + cCal + fCal, 1);
    final micros = kMicroSpec.entries
        .map((e) => (key: e.key, spec: e.value, value: _microOf(n, e.key)))
        .where((m) => m.value > 0)
        .toList()
      ..sort((a, b) =>
          (b.value / b.spec.rdi).compareTo(a.value / a.spec.rdi));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grab handle
        Center(
          child: Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(99),
              color: Colors.white.withValues(alpha: 0.2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(food.displayName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
            ),
            IconButton(
              tooltip: _isFavorite
                  ? 'Remove from favourites'
                  : 'Add to favourites',
              visualDensity: VisualDensity.compact,
              onPressed: _favPending ? null : _toggleFavorite,
              icon: Icon(
                _isFavorite
                    ? Icons.star_rounded
                    : Icons.star_outline_rounded,
                color: _isFavorite ? Yc.carbs : Yc.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text('per 100${food.liquid ? ' ml' : ' g'}',
                style: const TextStyle(color: Yc.textSecondary, fontSize: 13)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: food.source.verified
                    ? Yc.success.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.08),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (food.source.verified)
                    const Icon(Icons.verified_rounded,
                        size: 12, color: Yc.success),
                  const SizedBox(width: 4),
                  Text(food.source.label,
                      style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: food.source.verified
                              ? Yc.success
                              : Yc.textTertiary)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Macro donut + legend
        Row(
          children: [
            SizedBox(
              width: 132,
              height: 132,
              child: CustomPaint(
                painter: MacroDonut(
                  pShare: pCal / totalMacroCal,
                  cShare: cCal / totalMacroCal,
                  fShare: fCal / totalMacroCal,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(n.kcal.kcalText,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w800)),
                      const Text('kcal',
                          style:
                              TextStyle(fontSize: 11, color: Yc.textTertiary)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                children: [
                  _MacroLegendRow(
                      color: Yc.protein,
                      label: 'Protein',
                      grams: n.proteinG,
                      pct: pCal / totalMacroCal),
                  _MacroLegendRow(
                      color: Yc.carbs,
                      label: 'Carbs',
                      grams: n.carbsG,
                      pct: cCal / totalMacroCal),
                  _MacroLegendRow(
                      color: Yc.fat,
                      label: 'Fat',
                      grams: n.fatG,
                      pct: fCal / totalMacroCal),
                ],
              ),
            ),
          ],
        ),

        const Divider(height: 34, color: Color(0x1AFFFFFF)),

        // Secondary macros
        _InfoRow(label: 'Saturated fat', value: '${n.satFatG.gText} g'),
        _InfoRow(label: 'Sugars', value: '${n.sugarsG.gText} g'),
        _InfoRow(label: 'Fibre', value: '${n.fiberG.gText} g'),
        _InfoRow(label: 'Sodium', value: '${n.sodiumMg.round()} mg'),
        if (food.barcode != null)
          _InfoRow(label: 'Barcode', value: food.barcode!),

        if (micros.isNotEmpty) ...[
          const Divider(height: 34, color: Color(0x1AFFFFFF)),
          const Text('Micronutrients · % daily intake',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 12),
          ...micros.map((m) {
            final pct = (m.value / m.spec.rdi).clamp(0.0, 1.0);
            final valTxt = m.value >= 100
                ? m.value.round().toString()
                : m.value.toStringAsFixed(1);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m.spec.label,
                          style: const TextStyle(
                              fontSize: 13, color: Yc.textSecondary)),
                      Text(
                          '$valTxt ${m.spec.unit} · '
                          '${(pct * 100).round()}%',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Yc.textSecondary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 6,
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.08),
                      valueColor:
                          const AlwaysStoppedAnimation(Yc.calories),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        const SizedBox(height: 18),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Yc.calories,
            foregroundColor: const Color(0xFF06251B),
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(17)),
          ),
          onPressed: () {
            Navigator.pop(context);
            openPortionEditor(context, food);
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add to diary',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
        const SizedBox(height: 10),
        if (food.source == FoodSource.custom)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Yc.textPrimary,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17)),
            ),
            onPressed: () {
              Navigator.pop(context);
              openManualFoodEntry(context, existingFood: food);
            },
            icon: const Icon(Icons.edit_rounded, size: 19),
            label: const Text('Edit my food',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          )
        else
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: Yc.textPrimary,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(17)),
            ),
            onPressed: () {
              Navigator.pop(context);
              openFixProductSheet(context, food);
            },
            icon: const Icon(Icons.construction_rounded, size: 19),
            label: const Text('Wrong data? Fix it as my food',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
      ],
    );
  }
}

class _MacroLegendRow extends StatelessWidget {
  const _MacroLegendRow({
    required this.color,
    required this.label,
    required this.grams,
    required this.pct,
  });

  final Color color;
  final String label;
  final double grams;
  final double pct;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text('${grams.gText} g · ${(pct * 100).round()}%',
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13.5, color: Yc.textSecondary)),
          Text(value,
              style:
                  const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Three-segment macro donut with gaps.
class MacroDonut extends CustomPainter {
  MacroDonut({
    required this.pShare,
    required this.cShare,
    required this.fShare,
  });

  final double pShare;
  final double cShare;
  final double fShare;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 10;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const gap = 0.06; // radians between segments
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.butt;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..color = Colors.white.withValues(alpha: 0.07),
    );

    var start = -math.pi / 2;
    final segs = [
      (share: pShare.clamp(0.0, 1.0), color: Yc.protein),
      (share: cShare.clamp(0.0, 1.0), color: Yc.carbs),
      (share: fShare.clamp(0.0, 1.0), color: Yc.fat),
    ];

    for (final s in segs) {
      if (s.share <= 0) continue;
      final sweep = 2 * math.pi * s.share;
      canvas.drawArc(rect, start + gap / 2, math.max(sweep - gap, 0.01), false,
          stroke..color = s.color);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(MacroDonut old) =>
      old.pShare != pShare || old.cShare != cShare || old.fShare != fShare;
}
