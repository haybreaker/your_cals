import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../domain/food.dart';
import '../../domain/nutriments.dart';
import '../../state/providers.dart';
import '../search/food_detail_sheet.dart' show MacroDonut, kMicroSpec;
import 'log_entry_sheet.dart' show showLogEntryEditor;

/// Tap an entry in the diary → detail hub for the logged serve.
/// Edit lives one hop inside; swipe-delete unchanged.
Future<void> openLogEntryDetail(
  BuildContext context,
  WidgetRef ref,
  LogEntry entry,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.45,
      maxChildSize: 0.93,
      builder: (context, scrollCtrl) => Glass(
        radius: 34,
        blur: 30,
        opacity: 0.13,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),
          child: _EntryDetailBody(entry: entry),
        ),
      ),
    ),
  );
}

class _EntryDetailBody extends ConsumerStatefulWidget {
  const _EntryDetailBody({required this.entry});

  final LogEntry entry;

  @override
  ConsumerState<_EntryDetailBody> createState() => _EntryDetailBodyState();
}

class _EntryDetailBodyState extends ConsumerState<_EntryDetailBody> {
  Nutriments? _fullMicros;

  @override
  void initState() {
    super.initState();
    _loadFullMicros();
  }

  /// Entry snapshots only carry 4 micros — top up from the food row
  /// when it still exists so the detail view shows everything.
  Future<void> _loadFullMicros() async {
    final food = await ref.read(foodRepoProvider).byId(widget.entry.foodId);
    if (food != null && food.per100.hasMicros && mounted) {
      setState(() => _fullMicros = food.per100.forGrams(widget.entry.grams));
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final n = e.nutr;
    final display = _fullMicros ?? n;

    final pCal = n.proteinG * 4;
    final cCal = n.carbsG * 4;
    final fCal = n.fatG * 9;
    final totalMacroCal = pCal + cCal + fCal == 0
        ? 1.0
        : pCal + cCal + fCal;

    final micros = kMicroSpec.entries
        .map((e) => (
              key: e.key,
              spec: e.value,
              value: _microOf(display, e.key),
            ))
        .where((m) => m.value > 0)
        .toList()
      ..sort((a, b) =>
          (b.value / b.spec.rdi).compareTo(a.value / a.spec.rdi));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Text(e.name,
            style:
                const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        if (e.brand.isNotEmpty)
          Text(e.brand,
              style: const TextStyle(color: Yc.textSecondary, fontSize: 13.5)),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                color: Yc.calories.withValues(alpha: 0.14),
              ),
              child: Text(e.meal.label,
                  style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Yc.calories)),
            ),
            const SizedBox(width: 8),
            Text(
              '${e.amountLabel} · ${_time(e.createdAt)}',
              style:
                  const TextStyle(fontSize: 12.5, color: Yc.textSecondary),
            ),
            const SizedBox(width: 8),
            Text(e.source.label,
                style: const TextStyle(
                    fontSize: 11.5, color: Yc.textTertiary)),
          ],
        ),
        const SizedBox(height: 22),
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
                  _LegendRow(
                      color: Yc.protein,
                      label: 'Protein',
                      grams: n.proteinG,
                      pct: pCal / totalMacroCal),
                  _LegendRow(
                      color: Yc.carbs,
                      label: 'Carbs',
                      grams: n.carbsG,
                      pct: cCal / totalMacroCal),
                  _LegendRow(
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
        _InfoRow(label: 'Saturated fat', value: '${n.satFatG.gText} g'),
        _InfoRow(label: 'Sugars', value: '${n.sugarsG.gText} g'),
        _InfoRow(label: 'Fibre', value: '${n.fiberG.gText} g'),
        _InfoRow(label: 'Sodium', value: '${n.sodiumMg.round()} mg'),
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
                      Text('$valTxt ${m.spec.unit} · ${(pct * 100).round()}%',
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
            showLogEntryEditor(context, e);
          },
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Edit entry',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        ),
      ],
    );
  }

  static String _time(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static double _microOf(Nutriments n, String key) => switch (key) {
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
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
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
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
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
              style:
                  const TextStyle(fontSize: 13.5, color: Yc.textSecondary)),
          Text(value,
              style: const TextStyle(
                  fontSize: 13.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
