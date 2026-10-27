import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../domain/food.dart';
import '../../domain/portion.dart';
import '../../domain/nutriments.dart';
import '../../state/providers.dart';
import 'food_detail_sheet.dart' show openFoodDetail;
import '../common/undo_banner.dart' hide DiaryUndo;

class FoodResultTile extends ConsumerWidget {
  const FoodResultTile({
    super.key,
    required this.food,
    this.onPick,
    this.meal,
    this.historyCount = 0,
  });

  final Food food;
  final MealType? meal;

  /// When set, tapping returns the food instead of opening the portion editor
  /// (used by the recipe ingredient picker).
  final void Function(Food)? onPick;

  /// Times logged before (≥2 shows a "logged N×" marker — proof the
  /// ranking put a staple first).
  final int historyCount;

  String get _historySuffix =>
      historyCount >= 2 ? ' · logged $historyCount×' : '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kcalPerServing = food.per100.kcal * food.defaultGrams / 100;
    final isRecipe =
        food.source == FoodSource.recipe || food.id.startsWith('recipe:');

    return GlassLite(
      radius: 20,
      opacity: 0.07,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onPick != null
          ? () => onPick!(food)
          : () => openPortionEditor(context, food, initialMeal: meal),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              color: isRecipe
                  ? Yc.calories.withValues(alpha: 0.14)
                  : Colors.white.withValues(alpha: 0.06),
            ),
            child: Icon(
              _icon,
              size: 19,
              color: isRecipe ? Yc.calories : Yc.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        food.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (isRecipe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Yc.calories.withValues(alpha: 0.16),
                        ),
                        child: const Text(
                          'Recipe',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: Yc.calories,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        food.brand.isEmpty
                            ? '${food.source.hint}$_historySuffix'
                            : '${food.brand}$_historySuffix',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Yc.textTertiary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _SourceChip(source: food.source),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                kcalPerServing.kcalText,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                'kcal / ${food.defaultGrams.round()}g',
                style: const TextStyle(fontSize: 10.5, color: Yc.textTertiary),
              ),
            ],
          ),
          if (onPick != null) ...[
            const SizedBox(width: 8),
            const Icon(Icons.add_circle_rounded, color: Yc.calories, size: 26),
          ],
        ],
      ),
    );
  }

  IconData get _icon => switch (food.source) {
    FoodSource.chain => Icons.storefront_rounded,
    FoodSource.off => Icons.shopping_basket_rounded,
    FoodSource.recipe => Icons.soup_kitchen_rounded,
    FoodSource.ai => Icons.auto_awesome_rounded,
    FoodSource.custom => Icons.edit_note_rounded,
    _ => Icons.eco_rounded,
  };
}

/// Recents come back as LogEntry-shaped rows; adapt to Food for the tile.
class LogEntryFoodAdapter {
  static Food of(LogEntry e) => Food(
    id: e.foodId,
    name: e.name,
    brand: e.brand,
    source: e.source,
    per100: e.nutr,
    defaultGrams: e.grams,
  );
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.source});

  final FoodSource source;

  @override
  Widget build(BuildContext context) {
    final verified = source.verified;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: verified
            ? Yc.success.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.07),
      ),
      child: Text(
        source.label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
          color: verified ? Yc.success : Yc.textTertiary,
        ),
      ),
    );
  }
}

// ─── Portion editor (add / edit diary entry) ────────────────────────────────

Future<void> openPortionEditor(
  BuildContext context,
  Food food, {
  MealType? initialMeal,
  LogEntry? entry,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) =>
        PortionEditorSheet(food: food, initialMeal: initialMeal, entry: entry),
  );
}

class PortionEditorSheet extends ConsumerStatefulWidget {
  const PortionEditorSheet({
    super.key,
    required this.food,
    this.initialMeal,
    this.entry,
  });

  final Food food;
  final MealType? initialMeal;

  /// When set the sheet edits this entry instead of adding a new one.
  final LogEntry? entry;

  @override
  ConsumerState<PortionEditorSheet> createState() => _PortionEditorSheetState();
}

class _PortionEditorSheetState extends ConsumerState<PortionEditorSheet> {
  /// In edit mode the authoritative food may differ from the passed one
  /// (loaded fresh by id, or rebuilt from the entry snapshot if deleted).
  late Food _food = widget.food;
  bool _edit = false;

  late PortionUnit _unit;
  late double _qty;

  /// Serving option that "servings" mode multiplies.
  late int _servingIdx = 0;

  /// Guards the favourite star against rapid double-taps racing the DB.
  bool _favPending = false;

  /// Hoisted qty controller: previously rebuilt inline every frame, which
  /// reset the cursor on each keystroke and truncated decimals to 1dp.
  late final TextEditingController _qtyCtrl;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    if (entry != null) {
      _edit = true;
      _initFromEntry(entry);
    } else {
      _initSmartDefaults(widget.food);
    }
    _qtyCtrl = TextEditingController(text: formatQty(_qty));
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _syncQtyText() {
    final text = formatQty(_qty);
    if (_qtyCtrl.text != text) {
      _qtyCtrl.text = text;
      _qtyCtrl.selection = TextSelection.collapsed(offset: text.length);
    }
  }

  /// Smart unit defaulting: serves when the food has a real named serving
  /// (biscuits → "1 biscuit"), grams otherwise (chicken breast), ml for
  /// liquids without meaningful servings.
  void _initSmartDefaults(Food f) {
    final options = f.allServings;
    final hasRealServing =
        options.any((o) => o.grams > 0 && o.grams != 100) ||
        (f.defaultGrams > 0 && f.defaultGrams != 100);
    if (hasRealServing) {
      _unit = PortionUnit.serving;
      _servingIdx = _bestServingIdx(f);
      _qty = 1;
    } else {
      _unit = f.liquid ? PortionUnit.ml : PortionUnit.g;
      _servingIdx = _bestServingIdx(f);
      _qty = f.defaultGrams > 0 ? f.defaultGrams : 100;
    }
  }

  void _initFromEntry(LogEntry e) {
    _meal = e.meal;
    _unit = PortionUnitX.fromName(e.unit);
    // Diary entries are g/ml/serving today; kitchen units fall back to
    // grams display so old/new rows never crash the switch.
    if (_unit != PortionUnit.g &&
        _unit != PortionUnit.ml &&
        _unit != PortionUnit.serving) {
      _unit = PortionUnit.g;
    }
    if (e.hasServings) {
      _qty = e.servingCount!;
      _servingIdx = _servingIdxFor(e.servingGrams!, e.servingLabel);
    } else if (_unit == PortionUnit.serving) {
      // Legacy serving entry without metadata — treat as grams.
      _unit = PortionUnit.g;
      _qty = e.grams;
    } else {
      _qty = e.unit == 'ml' ? e.grams : e.grams;
    }
    if (_qty <= 0) _qty = 1;
    _loadFood(e);
  }

  int _servingIdxFor(double grams, String? label) {
    final options = _food.allServings;
    for (var i = 0; i < options.length; i++) {
      if (options[i].grams == grams) return i;
    }
    if (label != null) {
      // Entry's serving isn't in the current food (or food missing) —
      // extend with a synthetic option so editing keeps working.
      _food = _foodWithExtraServing(label, grams);
      return _food.allServings.length - 1;
    }
    return 0;
  }

  Food _foodWithExtraServing(String label, double grams) {
    final base = _food;
    return Food(
      id: base.id,
      name: base.name,
      brand: base.brand,
      source: base.source,
      per100: base.per100,
      defaultGrams: base.defaultGrams,
      servings: [
        ...base.servings,
        ServingOption(label: label, grams: grams),
      ],
      isFavorite: base.isFavorite,
      barcode: base.barcode,
      liquid: base.liquid,
    );
  }

  int _bestServingIdx(Food f) {
    final options = f.allServings;
    // Prefer the first concrete serving (skipping the generic 100 g).
    for (var i = 0; i < options.length; i++) {
      if (options[i].grams != 100) return i;
    }
    return 0;
  }

  Future<void> _loadFood(LogEntry e) async {
    final loaded = await ref.read(foodRepoProvider).byId(e.foodId);
    if (!mounted) return;
    if (loaded != null) {
      // Keep entry-specific serving selection against the fresh food.
      final old = _food;
      _food = loaded;
      if (e.hasServings) {
        _servingIdx = _servingIdxFor(e.servingGrams!, e.servingLabel);
      } else {
        _servingIdx = _bestServingIdx(loaded);
      }
      // _servingIdxFor may have mutated _food via synthetic option —
      // only relevant when the loaded food lacks the entry's serving.
      if (_food == loaded &&
          old != loaded &&
          e.servingLabel != null &&
          !loaded.allServings.any((s) => s.grams == e.servingGrams)) {
        _food = _foodWithExtraServing(e.servingLabel!, e.servingGrams!);
        _servingIdx = _food.allServings.length - 1;
      }
    } else {
      // Food deleted since logging — rebuild from the snapshot.
      final per100 = e.grams > 0 ? e.nutr.forGrams(100 / e.grams) : e.nutr;
      _food = Food(
        id: e.foodId,
        name: e.name,
        brand: e.brand,
        source: e.source,
        per100: per100,
        defaultGrams: e.servingGrams ?? 100,
        servings: [
          if (e.servingLabel != null && e.servingGrams != null)
            ServingOption(label: e.servingLabel!, grams: e.servingGrams!),
        ],
      );
      if (e.hasServings) {
        _servingIdx = _servingIdxFor(e.servingGrams!, e.servingLabel);
      }
    }
    setState(() {});
  }

  ServingOption get _activeServing {
    final s = _food.allServings;
    if (s.isEmpty) return const ServingOption(label: '100 g', grams: 100);
    if (_servingIdx >= s.length) _servingIdx = s.length - 1;
    return s[_servingIdx];
  }

  double get _resolvedGrams => PortionMath.resolveGrams(
    unit: _unit,
    qty: _qty,
    servingGrams: _activeServing.grams,
  );

  void _setUnit(PortionUnit u) {
    if (u == _unit) return;
    // Convert keeping total grams stable (kitchen units included).
    final converted = PortionMath.convert(
      qty: _qty,
      from: _unit,
      to: u,
      servingGrams: _activeServing.grams,
    );
    setState(() {
      _qty = converted.qty.clamp(0, 5000).toDouble();
      _unit = u;
    });
    _syncQtyText();
  }

  late MealType _meal =
      widget.initialMeal ?? widget.entry?.meal ?? MealTypeX.forNow();

  @override
  Widget build(BuildContext context) {
    final f = _food;
    final nutr = f.per100.forGrams(_resolvedGrams);
    final e = widget.entry;

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    f.displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Full nutrition',
                  onPressed: () => openFoodDetail(context, f),
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: Yc.textSecondary,
                  ),
                ),
                IconButton(
                  onPressed: _favPending
                      ? null
                      : () async {
                          final next = !f.isFavorite;
                          // Optimistic local update so the star fills
                          // instantly; the DB write follows. Previously the
                          // stale `_food` snapshot was re-read after the
                          // write, so the icon never changed and a second
                          // tap wrote the same value again (never unfaving).
                          setState(() {
                            _favPending = true;
                            _food = _food.copyWith(isFavorite: next);
                          });
                          try {
                            await ref
                                .read(foodRepoProvider)
                                .setFavorite(f.id, next);
                          } catch (_) {
                            // Revert on failure so UI matches the DB.
                            if (mounted) {
                              setState(() {
                                _food = _food.copyWith(isFavorite: !next);
                              });
                            }
                          } finally {
                            if (mounted) {
                              setState(() => _favPending = false);
                            } else {
                              _favPending = false;
                            }
                          }
                        },
                  icon: Icon(
                    f.isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: f.isFavorite ? Yc.carbs : Yc.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _Total(
                  value: nutr.kcal.kcalText,
                  unit: 'kcal',
                  color: Yc.calories,
                ),
                const SizedBox(width: 10),
                _Total(
                  value: nutr.proteinG.gText,
                  unit: 'P',
                  color: Yc.protein,
                ),
                const SizedBox(width: 10),
                _Total(value: nutr.carbsG.gText, unit: 'C', color: Yc.carbs),
                const SizedBox(width: 10),
                _Total(value: nutr.fatG.gText, unit: 'F', color: Yc.fat),
              ],
            ),
            const SizedBox(height: 16),

            // Amount + unit
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) {
                      final parsed = parseQty(v);
                      if (parsed != null) {
                        setState(() => _qty = parsed);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SegmentedButton<PortionUnit>(
                    // Diary logging stays g/ml/serving; tbsp/cup/etc live
                    // in the recipe editor where fixed conversions apply.
                    segments:
                        [PortionUnit.g, PortionUnit.ml, PortionUnit.serving]
                            .map(
                              (u) => ButtonSegment(
                                value: u,
                                label: Text(
                                  u.label,
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                              ),
                            )
                            .toList(),
                    selected: {_unit},
                    onSelectionChanged: (s) => _setUnit(s.first),
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      selectedBackgroundColor: Yc.calories.withValues(
                        alpha: 0.25,
                      ),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Quick serving chips (set exact amounts)
            if (f.allServings.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: f.allServings.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final s = f.allServings[i];
                    return ActionChip(
                      label: Text(
                        s.label,
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      onPressed: () {
                        setState(() {
                          _servingIdx = i;
                          _unit = PortionUnit.serving;
                          _qty = 1;
                        });
                        _syncQtyText();
                      },
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),

            SegmentedButton<MealType>(
              segments: MealType.values
                  .map(
                    (m) => ButtonSegment(
                      value: m,
                      label: Text(
                        m.label,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                    ),
                  )
                  .toList(),
              selected: {_meal},
              onSelectionChanged: (s) => setState(() => _meal = s.first),
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                selectedBackgroundColor: Yc.calories.withValues(alpha: 0.25),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
            ),
            const SizedBox(height: 16),

            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Yc.calories,
                foregroundColor: const Color(0xFF06251B),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              onPressed: () async {
                final repo = ref.read(diaryRepoProvider);
                final isServing = _unit == PortionUnit.serving;
                if (_edit && e != null) {
                  final nav = Navigator.of(context);
                  await repo.updatePortion(
                    e,
                    grams: _resolvedGrams,
                    unit: _unit.name,
                    servingCount: isServing ? _qty : null,
                    servingGrams: isServing ? _activeServing.grams : null,
                    servingLabel: isServing ? _activeServing.label : null,
                    meal: _meal,
                  );
                  nav.pop();
                  return;
                }
                final date = ref.read(selectedDateProvider);
                final dayKey =
                    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                final nav = Navigator.of(context);
                final entry = await repo.add(
                  day: dayKey,
                  meal: _meal,
                  food: _food,
                  grams: _resolvedGrams,
                  unit: _unit.name,
                  servingCount: isServing ? _qty : null,
                  servingGrams: isServing ? _activeServing.grams : null,
                  servingLabel: isServing ? _activeServing.label : null,
                );
                // Capture the undo host BEFORE popping (context dies on pop).
                if (!context.mounted) return;
                final host = UndoBannerHostState.of(context);
                host?.show(
                  UndoRequest(
                    text:
                        '${entry.name} added · ${entry.nutr.kcal.round()} kcal',
                    onUndo: () => ref.read(diaryRepoProvider).delete(entry.id),
                  ),
                );
                nav.pop();
              },
              icon: const Icon(Icons.check_rounded),
              label: Text(
                // Keep the button to a bare verb: the portion (grams /
                // servings) and calories already render above it.
                _edit ? 'Update' : 'Add',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.value, required this.unit, required this.color});

  final String value;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: color.withValues(alpha: 0.10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              unit,
              style: TextStyle(
                fontSize: 11,
                color: color.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
