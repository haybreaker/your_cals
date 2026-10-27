import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/format.dart';
import '../../core/fx.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../domain/food.dart';
import '../../domain/nutriments.dart';
import '../../domain/portion.dart';
import '../../state/providers.dart';
import '../common/dialogs.dart';
import '../library/library_page.dart' show LibraryPage;
import '../search/search_sheet.dart' show openPortionEditor;

class RecipesPage extends ConsumerStatefulWidget {
  const RecipesPage({super.key});

  @override
  ConsumerState<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends ConsumerState<RecipesPage> {
  /// Local display order for custom mode, updated synchronously in the
  /// same frame as the drop. The provider-sorted list lags a few frames
  /// (async stream re-query), which previously snapped tiles back to the
  /// old order mid-animation. Display-only; persistence still flows
  /// through [recipeCustomOrderProvider].
  List<String>? _manualIds;

  /// Merges provider emissions into the local order: keeps the user's
  /// relative order, appends brand-new ids at the end, drops deleted ids.
  List<Recipe> _displayRecipes(List<Recipe> recipes) {
    final ordered = mergeManualOrder(
      _manualIds,
      recipes.map((r) => r.id).toList(),
    );
    final byId = {for (final r in recipes) r.id: r};
    return [for (final id in ordered) byId[id]!];
  }

  void _reorder(List<Recipe> display, int oldIdx, int newIdx) {
    // onReorderItem already adjusts newIdx for the removed item.
    final ids = display.map((r) => r.id).toList();
    final moved = ids.removeAt(oldIdx);
    ids.insert(newIdx.clamp(0, ids.length), moved);
    setState(() => _manualIds = ids);
    ref.read(recipeCustomOrderProvider.notifier).setOrder(ids);
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(recipesProvider);
    final recipes = recipesAsync.value ?? const [];
    final sort = ref.watch(recipeSortProvider);
    // Leaving custom mode discards the local override so re-entry
    // re-seeds from the persisted order.
    ref.listen(recipeSortProvider, (_, next) {
      if (next != RecipeSort.custom && _manualIds != null) {
        setState(() => _manualIds = null);
      }
    });

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Row(
              children: [
                Text(
                  'Recipes',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Sort recipes',
                  onPressed: () => showRecipeSortSheet(context),
                  icon: const Icon(Icons.sort_rounded, color: Yc.textSecondary),
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: Yc.calories.withValues(alpha: 0.18),
                    foregroundColor: Yc.calories,
                  ),
                  onPressed: () => openRecipeEditor(context),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 2, 20, 8),
            child: Text(
              sort == RecipeSort.custom
                  ? 'Custom order · drag to re-order'
                  : 'Sorted by ${sort.label}',
              style: const TextStyle(fontSize: 12, color: Yc.textTertiary),
            ),
          ),
          Expanded(
            child: recipes.isEmpty
                ? ListView(
                    padding: const EdgeInsets.fromLTRB(20, 60, 20, 120),
                    children: [
                      Icon(
                        Icons.soup_kitchen_rounded,
                        size: 56,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Build a recipe once,\nlog it in one tap forever.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Yc.textSecondary, height: 1.4),
                      ),
                    ],
                  )
                : sort == RecipeSort.custom
                ? Builder(
                    builder: (context) {
                      final display = _displayRecipes(recipes);
                      return ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                        itemCount: display.length,
                        onReorderItem: (oldIdx, newIdx) =>
                            _reorder(display, oldIdx, newIdx),
                        proxyDecorator: (child, _, _) =>
                            Material(color: Colors.transparent, child: child),
                        itemBuilder: (context, i) => Padding(
                          key: ValueKey(display[i].id),
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _RecipeCard(recipe: display[i]),
                        ),
                      );
                    },
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    children: [
                      ...recipes.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _RecipeCard(recipe: r),
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

/// Pure merge for the custom recipe order: keeps the user's relative
/// order, appends brand-new ids at the end, drops deleted ids.
/// Null [local] (no manual reorder yet) passes [incoming] through.
@visibleForTesting
List<String> mergeManualOrder(List<String>? local, List<String> incoming) {
  if (local == null) return [...incoming];
  final known = incoming.toSet();
  return [
    ...local.where(known.contains),
    ...incoming.where((id) => !local.contains(id)),
  ];
}

/// Sort picker in the app's liquid-glass bottom-sheet style (same chrome
/// as the capture / correction sheets), replacing the default Material
/// popup menu.
Future<void> showRecipeSortSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black54,
    builder: (_) => const _SortSheet(),
  );
}

class _SortSheet extends ConsumerWidget {
  const _SortSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sort = ref.watch(recipeSortProvider);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Glass(
        radius: 34,
        blur: 30,
        opacity: 0.13,
        border: true,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 14),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Sort recipes',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            ...RecipeSort.values.map((s) {
              final selected = s == sort;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LiquidCard(
                  radius: 22,
                  opacity: selected ? 0.12 : 0.07,
                  tint: selected ? Yc.calories.withValues(alpha: 0.18) : null,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  onTap: () {
                    ref.read(recipeSortProvider.notifier).set(s);
                    Navigator.pop(context);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.label,
                          style: TextStyle(
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: selected ? Yc.calories : Yc.textPrimary,
                          ),
                        ),
                      ),
                      if (selected)
                        const Icon(
                          Icons.check_rounded,
                          size: 20,
                          color: Yc.calories,
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends ConsumerWidget {
  const _RecipeCard({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LiquidCard(
      radius: 22,
      opacity: 0.08,
      padding: const EdgeInsets.all(16),
      onTap: () => openRecipeEditor(context, existing: recipe),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                      ),
                    ),
                    if (recipe.ingredients.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          _ingredientPreview,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Yc.textSecondary,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${recipe.perServing.kcal.kcalText} kcal / serve · ${recipe.servings} serves',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Yc.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Log a serving',
                visualDensity: VisualDensity.compact,
                onPressed: () async {
                  final food = await ref
                      .read(recipeRepoProvider)
                      .recipeAsFood(recipe.id);
                  if (food != null && context.mounted) {
                    openPortionEditor(context, food);
                  }
                },
                icon: const Icon(
                  Icons.add_circle_rounded,
                  color: Yc.calories,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _ingredientPreview {
    final names = recipe.ingredients.map((i) => i.name).toList();
    if (names.isEmpty) return '';
    final preview = names.take(3).join(', ');
    final extra = names.length - 3;
    return extra > 0 ? '$preview · $extra more' : preview;
  }
}

// ─── Editor ─────────────────────────────────────────────────────────────────

Future<void> openRecipeEditor(
  BuildContext context, {
  Recipe? existing,
  List<RecipeIngredient>? initialIngredients,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, _, _) => _RecipeEditorScreen(
        existing: existing,
        initialIngredients: initialIngredients,
      ),
      transitionsBuilder: (_, anim, _, child) => SlideTransition(
        position: Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  );
}

class _IngredientLine {
  _IngredientLine(
    this.food, {
    required this.qty,
    required this.unit,
    this.servingIdx = 0,
    this.expanded = false,
  });

  final Food food;
  double qty;
  PortionUnit unit;
  int servingIdx;
  bool expanded;

  double get servingGrams {
    final options = food.allServings;
    if (options.isEmpty) {
      return food.defaultGrams > 0 ? food.defaultGrams : 100;
    }
    final idx = servingIdx.clamp(0, options.length - 1);
    return options[idx].grams;
  }

  ServingOption get activeServing {
    final options = food.allServings;
    if (options.isEmpty) {
      return const ServingOption(label: '100 g', grams: 100);
    }
    return options[servingIdx.clamp(0, options.length - 1)];
  }

  /// Resolved gram weight for nutrition math.
  double get grams => PortionMath.resolveGrams(
    unit: unit,
    qty: qty,
    servingGrams: servingGrams,
  );

  double get kcal => food.per100.kcal * grams / 100;

  bool get isRecipe =>
      food.id.startsWith('recipe:') || food.source == FoodSource.recipe;

  String get qtyLabel => '${formatQty(qty)} ${unit.label}';

  factory _IngredientLine.fromFood(Food f) {
    if (f.id.startsWith('recipe:') || f.source == FoodSource.recipe) {
      return _IngredientLine(
        f,
        qty: 1,
        unit: PortionUnit.serving,
        servingIdx: _bestServingIdx(f),
      );
    }
    if (f.liquid) {
      return _IngredientLine(
        f,
        qty: f.defaultGrams > 0 ? f.defaultGrams : 100,
        unit: PortionUnit.ml,
        servingIdx: _bestServingIdx(f),
      );
    }
    return _IngredientLine(
      f,
      qty: f.defaultGrams > 0 ? f.defaultGrams : 100,
      unit: PortionUnit.g,
      servingIdx: _bestServingIdx(f),
    );
  }

  factory _IngredientLine.fromIngredient(RecipeIngredient i, Food? fullFood) {
    final food =
        fullFood ??
        Food(
          id: i.foodId,
          name: i.name,
          brand: i.brand,
          source: i.isRecipeRef ? FoodSource.recipe : i.source,
          per100: i.per100,
          defaultGrams: i.grams > 0 ? i.grams : 100,
        );
    final unit = PortionUnitX.fromName(i.unit);
    var servingIdx = _bestServingIdx(food);
    if (unit == PortionUnit.serving && i.qty > 0) {
      // Pick the serving option closest to the stored gram weight.
      final target = i.qty > 0 && i.grams > 0 ? i.grams / i.qty : 0;
      final options = food.allServings;
      var best = 0;
      var bestDiff = double.infinity;
      for (var k = 0; k < options.length; k++) {
        final diff = (options[k].grams - target).abs();
        if (diff < bestDiff) {
          bestDiff = diff;
          best = k;
        }
      }
      servingIdx = best;
    }
    return _IngredientLine(
      food,
      qty: i.qty > 0 ? i.qty : i.grams,
      unit: unit,
      servingIdx: servingIdx,
    );
  }

  static int _bestServingIdx(Food f) {
    final options = f.allServings;
    for (var i = 0; i < options.length; i++) {
      if (options[i].grams != 100) return i;
    }
    return 0;
  }
}

class _RecipeEditorScreen extends ConsumerStatefulWidget {
  const _RecipeEditorScreen({this.existing, this.initialIngredients});

  final Recipe? existing;

  /// Prefilled ingredients (e.g. from multi-selected diary entries).
  final List<RecipeIngredient>? initialIngredients;

  @override
  ConsumerState<_RecipeEditorScreen> createState() =>
      _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<_RecipeEditorScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late int _servings = widget.existing?.servings ?? 2;
  final List<_IngredientLine> _lines = [];
  bool _saving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _seedInitialIngredients();
    _loadExisting();
  }

  void _seedInitialIngredients() {
    final initial = widget.initialIngredients;
    if (initial == null) return;
    _lines.addAll(
      initial.map(
        (i) => _IngredientLine.fromIngredient(
          i,
          Food(
            id: i.foodId,
            name: i.name,
            brand: i.brand,
            source: i.isRecipeRef ? FoodSource.recipe : i.source,
            per100: i.per100,
            defaultGrams: i.grams > 0 ? i.grams : 100,
          ),
        ),
      ),
    );
    // Enrich with full food rows (servings, liquid, true source) async.
    _enrichLinesWithFoodRows();
  }

  Future<void> _enrichLinesWithFoodRows() async {
    final repo = ref.read(foodRepoProvider);
    var changed = false;
    for (var k = 0; k < _lines.length; k++) {
      final line = _lines[k];
      // Snapshot lines have no servings; try to load the real food.
      if (line.food.servings.isEmpty) {
        final full = await repo.byId(line.food.id);
        if (full != null && mounted) {
          _lines[k] = _IngredientLine(
            full,
            qty: line.qty,
            unit: line.unit,
            servingIdx: line.servingIdx,
            expanded: line.expanded,
          );
          changed = true;
        }
      }
    }
    if (changed && mounted) setState(() {});
  }

  /// BUGFIX: reopening a recipe used to show zero ingredients (and
  /// re-saving would wipe them). Load them from the DB first.
  Future<void> _loadExisting() async {
    final existing = widget.existing;
    if (existing == null || _loaded) return;
    _loaded = true;
    final repo = ref.read(recipeRepoProvider);
    final foodRepo = ref.read(foodRepoProvider);
    final recipe = await repo.byId(existing.id);
    if (!mounted || recipe == null) return;
    final lines = <_IngredientLine>[];
    for (final i in recipe.ingredients) {
      // Enrich with the full food row so servings/units/source are real.
      // Deleted foods (or deleted sub-recipes) fall back to the snapshot.
      final full = await foodRepo.byId(i.foodId);
      lines.add(_IngredientLine.fromIngredient(i, full));
    }
    if (!mounted) return;
    setState(() => _lines.addAll(lines));
  }

  Future<void> _delete() async {
    final existing = widget.existing;
    if (existing == null) return;
    final ok = await confirmGlassDialog(
      context,
      title: 'Delete ${existing.name}?',
      body: 'The recipe and its food entry will be removed.',
    );
    if (!ok || !mounted) return;
    await ref.read(recipeRepoProvider).delete(existing.id);
    if (mounted) Navigator.of(context).pop();
  }

  void _addIngredient(Food f) {
    setState(() {
      final line = _IngredientLine.fromFood(f)..expanded = true;
      // Collapse others so only the new row's stepper is open.
      for (final l in _lines) {
        l.expanded = false;
      }
      _lines.add(line);
    });
  }

  Future<void> _drillIntoSubRecipe(_IngredientLine line) async {
    final refId = line.food.id.startsWith('recipe:')
        ? line.food.id.substring('recipe:'.length)
        : null;
    if (refId == null) return;
    final sub = await ref.read(recipeRepoProvider).byId(refId);
    if (!mounted) return;
    if (sub == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sub-recipe unavailable — it may have been deleted.'),
        ),
      );
      return;
    }
    await openRecipeEditor(context, existing: sub);
    // Refresh: child may have changed, and parent totals are live.
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty || _lines.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(recipeRepoProvider)
          .save(
            existingId: widget.existing?.id,
            name: _name.text.trim(),
            servings: _servings,
            ingredients: _lines
                .map(
                  (l) => RecipeIngredient(
                    foodId: l.food.id,
                    name: l.food.name,
                    brand: l.food.brand,
                    grams: l.grams,
                    per100: l.food.per100,
                    qty: l.qty,
                    unit: l.unit.name,
                  ),
                )
                .toList(),
          );
      if (mounted) Navigator.of(context).pop();
    } on StateError catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not save recipe.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalKcal = _lines.fold<double>(
      0,
      (a, l) => a + l.food.per100.kcal * l.grams / 100,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const AuroraBackground(),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                  child: Row(
                    children: [
                      BackButton(onPressed: () => Navigator.pop(context)),
                      if (widget.existing != null)
                        IconButton(
                          tooltip: 'Delete recipe',
                          onPressed: _delete,
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Yc.danger,
                          ),
                        ),
                      Expanded(
                        child: TextField(
                          controller: _name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Recipe name',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Yc.textTertiary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Text(
                        'Servings',
                        style: TextStyle(color: Yc.textSecondary),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => setState(
                          () => _servings = (_servings - 1).clamp(1, 50),
                        ),
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                      Text(
                        '$_servings',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(
                          () => _servings = (_servings + 1).clamp(1, 50),
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _lines.isEmpty
                      ? Center(
                          child: Text(
                            'Add ingredients below',
                            style: TextStyle(color: Yc.textTertiary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                          itemCount: _lines.length,
                          itemBuilder: (context, i) {
                            final l = _lines[i];
                            return _IngredientCard(
                              key: ValueKey(
                                '${l.food.id}_${i}_${l.unit.name}_${l.servingIdx}',
                              ),
                              line: l,
                              onChanged: () => setState(() {}),
                              onToggleExpand: () => setState(() {
                                l.expanded = !l.expanded;
                              }),
                              onRemove: () =>
                                  setState(() => _lines.removeAt(i)),
                              onDrillIn: l.isRecipe
                                  ? () => _drillIntoSubRecipe(l)
                                  : null,
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Yc.textPrimary,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          onPressed: () => showSearchSheetForPick(
                            context,
                            _addIngredient,
                            excludeRecipeId: widget.existing?.id,
                          ),
                          icon: const Icon(Icons.search_rounded),
                          label: const Text('Add ingredient'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Yc.calories,
                            foregroundColor: const Color(0xFF06251B),
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(17),
                            ),
                          ),
                          onPressed: _save,
                          icon: const Icon(Icons.check_rounded),
                          label: Text(
                            'Save · ${totalKcal.kcalText} kcal',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
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

/// One ingredient row: tap the quantity pill to expand an inline stepper
/// (- qty +) with unit chips. Recipe ingredients get a badge; tapping the
/// name drills into the sub-recipe editor.
class _IngredientCard extends StatefulWidget {
  const _IngredientCard({
    super.key,
    required this.line,
    required this.onChanged,
    required this.onToggleExpand,
    required this.onRemove,
    this.onDrillIn,
  });

  final _IngredientLine line;
  final VoidCallback onChanged;
  final VoidCallback onToggleExpand;
  final VoidCallback onRemove;
  final VoidCallback? onDrillIn;

  @override
  State<_IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends State<_IngredientCard> {
  late final TextEditingController _qtyCtrl = TextEditingController(
    text: formatQty(widget.line.qty),
  );

  _IngredientLine get _line => widget.line;

  void _syncQtyText() {
    _qtyCtrl.text = formatQty(_line.qty);
    _qtyCtrl.selection = TextSelection.collapsed(offset: _qtyCtrl.text.length);
  }

  void _bump(double delta) {
    setState(() {
      _line.qty = (_line.qty + delta).clamp(0, 5000);
      _syncQtyText();
    });
    widget.onChanged();
  }

  void _setUnit(PortionUnit u) {
    if (u == _line.unit) return;
    final converted = PortionMath.convert(
      qty: _line.qty,
      from: _line.unit,
      to: u,
      servingGrams: _line.servingGrams,
    );
    var q = converted.qty.clamp(0, 5000).toDouble();
    // Keep labels tidy: whole numbers for g/ml, halves elsewhere.
    q = (u == PortionUnit.g || u == PortionUnit.ml)
        ? q.roundToDouble()
        : (q * 2).round() / 2;
    if (q <= 0) q = u == PortionUnit.serving ? 1 : q;
    setState(() {
      _line.unit = u;
      _line.qty = q;
      _syncQtyText();
    });
    widget.onChanged();
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = _line;
    return Glass(
      radius: 20,
      opacity: l.expanded ? 0.10 : 0.07,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onDrillIn,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              l.food.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (l.isRecipe) ...[
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
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 16,
                              color: Yc.textTertiary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l.kcal.kcalText} kcal · ${l.grams.round()} g'
                        '${l.unit == PortionUnit.serving ? ' · ${l.activeServing.label}' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Yc.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onToggleExpand,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: l.expanded
                        ? Yc.calories.withValues(alpha: 0.20)
                        : Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: l.expanded
                          ? Yc.calories.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l.qtyLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        l.expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 16,
                        color: Yc.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 17,
                  color: Yc.textTertiary,
                ),
                onPressed: widget.onRemove,
              ),
            ],
          ),
          if (l.expanded) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: l.qty <= 0
                      ? null
                      : () => _bump(
                          l.unit == PortionUnit.g || l.unit == PortionUnit.ml
                              ? -10
                              : -0.5,
                        ),
                  icon: const Icon(Icons.remove_circle_outline_rounded),
                ),
                SizedBox(
                  width: 84,
                  child: TextField(
                    controller: _qtyCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 6,
                      ),
                    ),
                    onChanged: (v) {
                      final parsed = parseQty(v);
                      if (parsed != null) {
                        l.qty = parsed;
                        widget.onChanged();
                      }
                    },
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _bump(
                    l.unit == PortionUnit.g || l.unit == PortionUnit.ml
                        ? 10
                        : 0.5,
                  ),
                  icon: const Icon(Icons.add_circle_outline_rounded),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${l.grams.round()} g',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Yc.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: PortionUnit.values.map((u) {
                final selected = l.unit == u;
                return GestureDetector(
                  onTap: () => _setUnit(u),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(99),
                      color: selected
                          ? Yc.calories.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.06),
                      border: Border.all(
                        color: selected
                            ? Yc.calories.withValues(alpha: 0.6)
                            : Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      u.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: selected ? Yc.textPrimary : Yc.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (l.unit == PortionUnit.serving &&
                l.food.allServings.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 34,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: l.food.allServings.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, si) {
                    final s = l.food.allServings[si];
                    final selected = l.servingIdx == si;
                    return GestureDetector(
                      onTap: () {
                        setState(() => l.servingIdx = si);
                        widget.onChanged();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99),
                          color: selected
                              ? Yc.calories.withValues(alpha: 0.25)
                              : Colors.white.withValues(alpha: 0.06),
                          border: Border.all(
                            color: selected
                                ? Yc.calories.withValues(alpha: 0.6)
                                : Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          s.label,
                          style: const TextStyle(fontSize: 11.5),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Ingredient picker: the shared LibraryPage in pick mode — tapping a
/// tile returns the food for direct-add (no portion sheet, no diary
/// write) instead of logging to today.
Future<void> showSearchSheetForPick(
  BuildContext context,
  void Function(Food) onPicked, {
  String? excludeRecipeId,
}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const AuroraBackground(),
            LibraryPage(
              autofocus: true,
              showBackButton: true,
              resetOnOpen: true,
              // Same transient controller the old picker used; resets
              // on open and never stacks with the diary search sheet.
              searchProvider: searchControllerProvider,
              hintText: 'Find an ingredient…',
              excludeId: excludeRecipeId == null
                  ? null
                  : 'recipe:$excludeRecipeId',
              onPick: (f) {
                Navigator.of(context).pop();
                onPicked(f);
              },
            ),
          ],
        ),
      ),
      transitionsBuilder: (_, anim, _, child) => SlideTransition(
        position: Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  );
}
