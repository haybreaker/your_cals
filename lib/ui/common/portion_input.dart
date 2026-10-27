import 'package:flutter/material.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../domain/nutriments.dart' show ServingOption;
import '../../domain/portion.dart';

/// Shared quantity + unit input used by the portion editor, recipe
/// ingredient cards, and the AI confirmation screen.
///
/// Matches the recipe-screen style: stepper (- qty +) with unit chips and
/// an optional serving picker. All math goes through [PortionMath].
class PortionInput extends StatefulWidget {
  const PortionInput({
    super.key,
    required this.qty,
    required this.unit,
    required this.servingIdx,
    required this.servings,
    required this.onChanged,
    this.servingGramsFallback = 100,
  });

  final double qty;
  final PortionUnit unit;
  final int servingIdx;
  final List<ServingOption> servings;
  final void Function(double qty, PortionUnit unit, int servingIdx) onChanged;

  /// Used when [servings] is empty.
  final double servingGramsFallback;

  @override
  State<PortionInput> createState() => _PortionInputState();
}

class _PortionInputState extends State<PortionInput> {
  late final TextEditingController _qtyCtrl =
      TextEditingController(text: formatQty(widget.qty));

  double get _servingGrams {
    if (widget.servings.isEmpty) {
      return widget.servingGramsFallback > 0
          ? widget.servingGramsFallback
          : 100;
    }
    final idx = widget.servingIdx.clamp(0, widget.servings.length - 1);
    return widget.servings[idx].grams;
  }

  double get _resolvedGrams => PortionMath.resolveGrams(
        unit: widget.unit,
        qty: widget.qty,
        servingGrams: _servingGrams,
      );

  @override
  void didUpdateWidget(PortionInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.qty != widget.qty &&
        _qtyCtrl.text != formatQty(widget.qty)) {
      _qtyCtrl.text = formatQty(widget.qty);
      _qtyCtrl.selection =
          TextSelection.collapsed(offset: _qtyCtrl.text.length);
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _bump(double delta) {
    final next = (widget.qty + delta).clamp(0, 5000).toDouble();
    _qtyCtrl.text = formatQty(next);
    _qtyCtrl.selection =
        TextSelection.collapsed(offset: _qtyCtrl.text.length);
    widget.onChanged(next, widget.unit, widget.servingIdx);
  }

  void _setUnit(PortionUnit u) {
    if (u == widget.unit) return;
    final converted = PortionMath.convert(
      qty: widget.qty,
      from: widget.unit,
      to: u,
      servingGrams: _servingGrams,
    );
    var q = converted.qty.clamp(0, 5000).toDouble();
    // Keep labels tidy: gram-precision for g/ml, 2dp elsewhere.
    q = (u == PortionUnit.g || u == PortionUnit.ml)
        ? q.roundToDouble()
        : double.parse(q.toStringAsFixed(2));
    if (q <= 0 && u == PortionUnit.serving) q = 1;
    widget.onChanged(q, u, widget.servingIdx);
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.unit == PortionUnit.g ||
            widget.unit == PortionUnit.ml
        ? 10.0
        : 0.5;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed:
                  widget.qty <= 0 ? null : () => _bump(-step),
              icon: const Icon(Icons.remove_circle_outline_rounded),
            ),
            SizedBox(
              width: 84,
              child: TextField(
                controller: _qtyCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 6),
                ),
                onChanged: (v) {
                  final parsed = parseQty(v);
                  if (parsed != null) {
                    widget.onChanged(
                        parsed, widget.unit, widget.servingIdx);
                  }
                },
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: () => _bump(step),
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${formatQty(_resolvedGrams)} g',
                textAlign: TextAlign.end,
                style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Yc.textSecondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: PortionUnit.values.map((u) {
            final selected = widget.unit == u;
            return GestureDetector(
              onTap: () => _setUnit(u),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(99),
                  color: selected
                      ? Yc.calories.withValues(alpha: 0.25)
                      : Colors.white.withValues(alpha: 0.06),
                  border: Border.all(
                      color: selected
                          ? Yc.calories.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.12)),
                ),
                child: Text(u.label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Yc.textPrimary
                            : Yc.textSecondary)),
              ),
            );
          }).toList(),
        ),
        if (widget.unit == PortionUnit.serving &&
            widget.servings.isNotEmpty) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: widget.servings.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (context, si) {
                final s = widget.servings[si];
                final selected = widget.servingIdx == si;
                return GestureDetector(
                  onTap: () =>
                      widget.onChanged(widget.qty, widget.unit, si),
                  child: Container(
                    alignment: Alignment.center,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: selected
                          ? Yc.calories.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                          color: selected
                              ? Yc.calories.withValues(alpha: 0.6)
                              : Colors.white.withValues(alpha: 0.12)),
                    ),
                    child: Text(s.label,
                        style: const TextStyle(fontSize: 11.5)),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}
