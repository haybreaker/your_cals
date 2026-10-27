import 'package:flutter/material.dart' hide SearchController;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/fx.dart';
import '../../core/glass.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../domain/food.dart';
import '../../domain/nutriments.dart';
import '../../state/providers.dart';
import '../../state/search_controller.dart';
import '../barcode/barcode_scanner.dart' show scanBarcodeForFilter;
import '../search/add_food_manually_sheet.dart' show openManualFoodEntry;
import '../search/food_search_list.dart'
    show FoodResultsList, SearchEmptyState, SearchSkeletonList;
import '../search/search_sheet.dart' show FoodResultTile, LogEntryFoodAdapter;

/// Full-height food search: the [LibraryPage] hosted in a slide-up modal,
/// so the search surface is identical everywhere and callers never lose
/// navigation context by jumping tabs.
Future<void> openSearchSheet(BuildContext context, {MealType? initialMeal}) {
  return Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      pageBuilder: (_, _, _) => Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const AuroraBackground(),
            LibraryPage(
              initialMeal: initialMeal,
              autofocus: true,
              showBackButton: true,
              resetOnOpen: true,
              // The tab keeps its own controller instance; the modal
              // reuses the transient search controller (also used by the
              // recipe picker, which resets on open and never stacks
              // with this sheet).
              searchProvider: searchControllerProvider,
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

/// Opens the custom-food form. In pick mode (recipe ingredient picker) the
/// saved food is handed back to [onPick] instead of opening the portion
/// editor — pickers never write diary entries.
Future<void> _openCustomFood(
  BuildContext context, {
  MealType? meal,
  String? name,
  String? barcode,
  void Function(Food)? onPick,
}) async {
  final food = await openManualFoodEntry(
    context,
    initialMeal: meal,
    initialName: name,
    initialBarcode: barcode,
    openPortionEditorOnSave: onPick == null,
  );
  if (food != null && onPick != null && context.mounted) onPick(food);
}

/// Library: persistent search bar on top, tab bar for
/// History (default) / Favourites. Typing ≥2 chars replaces the tab view
/// with the live search list.
///
/// Doubles as the modal search sheet (see [openSearchSheet]): pass
/// [initialMeal] to pre-select the diary meal, [autofocus]/[showBackButton]
/// for modal chrome, and [searchProvider] to isolate query state.
///
/// Pick mode (recipe ingredients): pass [onPick] — tapping a tile returns
/// the food instead of opening the portion editor. [excludeId] hides one
/// row (a recipe can't pick itself); [hintText] relabels the field.
class LibraryPage extends ConsumerStatefulWidget {
  LibraryPage({
    super.key,
    this.initialMeal,
    this.autofocus = false,
    this.showBackButton = false,
    this.resetOnOpen = false,
    this.onPick,
    this.excludeId,
    this.hintText = 'Search foods, brands, menus…',
    StateNotifierProvider<SearchController, SearchState>? searchProvider,
  }) : searchProvider = searchProvider ?? librarySearchControllerProvider;

  final MealType? initialMeal;
  final bool autofocus;
  final bool showBackButton;
  final bool resetOnOpen;
  final void Function(Food)? onPick;
  final String? excludeId;
  final String hintText;
  final StateNotifierProvider<SearchController, SearchState> searchProvider;

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(
    length: 2,
    vsync: this,
    initialIndex: 1,
  );
  final _controller = TextEditingController();
  final _focus = FocusNode();

  /// Barcode quick-filter result (single exact match). Takes over the
  /// results area until cleared or the query changes.
  List<Food>? _barcodeOnly;

  /// Barcode that found no product anywhere — shows the inline miss
  /// state (with a "save it as custom" action) until the query changes.
  String? _barcodeMiss;

  @override
  void initState() {
    super.initState();
    // Typing clears a stale barcode filter or miss state; the X button
    // clears text (which clears both through here too).
    _controller.addListener(() {
      if (_barcodeOnly != null || _barcodeMiss != null) {
        _barcodeOnly = null;
        _barcodeMiss = null;
      }
      setState(() {});
    });
    // Never inherit the previous session's query/results in modal mode.
    // Post-frame: mutating a provider inside initState/build throws.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.resetOnOpen) {
        ref.read(widget.searchProvider.notifier).reset();
      }
      if (widget.autofocus) _focus.requestFocus();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(widget.searchProvider);
    final ctrl = ref.read(widget.searchProvider.notifier);
    final searching = state.query.trim().length >= 2;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Glass(
              radius: 24,
              opacity: 0.12,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                children: [
                  if (widget.showBackButton)
                    BackButton(
                      onPressed: () => Navigator.of(context).pop(),
                      color: Yc.textPrimary,
                    )
                  else
                    const Icon(Icons.search_rounded, color: Yc.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      // Tab mode deliberately skips autofocus: keyboard
                      // only opens on explicit user tap.
                      autofocus: false,
                      style: const TextStyle(fontSize: 16.5),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: Yc.textTertiary),
                      ),
                      onChanged: ctrl.onQueryChanged,
                      textInputAction: TextInputAction.search,
                    ),
                  ),
                  // Barcode quick-filter: exact match, bypasses naming.
                  IconButton(
                    tooltip: 'Scan barcode',
                    icon: const Icon(
                      Icons.qr_code_scanner_rounded,
                      color: Yc.textSecondary,
                    ),
                    onPressed: _scanBarcode,
                  ),
                  if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Yc.textSecondary,
                      ),
                      onPressed: () {
                        _controller.clear();
                        ctrl.onQueryChanged('');
                        FocusScope.of(context).unfocus();
                      },
                    ),
                ],
              ),
            ),
          ),
          if (searching)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    '${state.results.length} foods',
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Yc.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  if (state.phase == SearchPhase.remoteLoading &&
                      state.results.isNotEmpty)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Yc.calories,
                      ),
                    ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: TabBar(
                  controller: _tabs,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Yc.calories.withValues(alpha: 0.22),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Yc.textPrimary,
                  unselectedLabelColor: Yc.textTertiary,
                  labelStyle: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  tabs: const [
                    Tab(text: 'Favourites'),
                    Tab(text: 'History'),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _barcodeOnly != null
                ? _BarcodeResults(
                    foods: _barcodeOnly!,
                    meal: widget.initialMeal,
                    onPick: widget.onPick,
                    historyCounts: state.historyCounts,
                    onClear: () => setState(() => _barcodeOnly = null),
                  )
                : _barcodeMiss != null
                ? _BarcodeMiss(
                    barcode: _barcodeMiss!,
                    meal: widget.initialMeal,
                    onPick: widget.onPick,
                    onClear: () => setState(() => _barcodeMiss = null),
                  )
                : searching
                ? _LibraryResults(
                    state: state,
                    meal: widget.initialMeal,
                    onPick: widget.onPick,
                    excludeId: widget.excludeId,
                  )
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _FavoritesTab(
                        meal: widget.initialMeal,
                        onPick: widget.onPick,
                        excludeId: widget.excludeId,
                      ),
                      _HistoryTab(
                        meal: widget.initialMeal,
                        onPick: widget.onPick,
                        excludeId: widget.excludeId,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Barcode quick-filter: exact local match first (whoever named the
  /// row doesn't matter), OFF fallback second, miss with an out.
  Future<void> _scanBarcode() async {
    final code = await scanBarcodeForFilter(context);
    if (code == null || code.trim().isEmpty || !mounted) return;
    final barcode = code.trim();
    final repo = ref.read(foodRepoProvider);
    List<Food>? found;
    final local = await repo.byBarcode(barcode);
    if (local != null) {
      found = [local];
    } else {
      try {
        final remote = await ref
            .read(offClientProvider)
            .fetchByBarcode(barcode);
        if (remote != null) {
          await repo.upsertFood(remote);
          final again = await repo.byBarcode(barcode);
          if (again != null) found = [again];
        }
      } catch (_) {}
    }
    if (!mounted) return;
    if (found != null) {
      _focus.unfocus();
      setState(() {
        _barcodeOnly = found;
        _barcodeMiss = null;
      });
    } else {
      _focus.unfocus();
      setState(() => _barcodeMiss = barcode);
    }
  }
}

class _LibraryResults extends StatelessWidget {
  const _LibraryResults({
    required this.state,
    this.meal,
    this.onPick,
    this.excludeId,
  });

  final SearchState state;
  final MealType? meal;
  final void Function(Food)? onPick;
  final String? excludeId;

  @override
  Widget build(BuildContext context) {
    if (state.showSkeleton) {
      return const SearchSkeletonList();
    }
    final results = excludeId == null
        ? state.results
        : state.results.where((f) => f.id != excludeId).toList();
    if (results.isEmpty) {
      return Column(
        children: [
          if (state.remoteFailed) const _OfflineBanner(),
          Expanded(
            child: SearchEmptyState(
              onAddManually: () => _openCustomFood(
                context,
                meal: meal,
                name: state.query.trim(),
                onPick: onPick,
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        if (state.remoteFailed) const _OfflineBanner(),
        Expanded(
          child: FoodResultsList(
            results: results,
            meal: meal,
            onPick: onPick,
            onAddManually: () => _openCustomFood(
              context,
              meal: meal,
              name: state.query.trim(),
              onPick: onPick,
            ),
            bottomPadding: 120,
            historyCounts: state.historyCounts,
          ),
        ),
      ],
    );
  }
}

/// Shown when the live OFF lookup failed but local results are still
/// displayed: the exact barcode product may exist remotely even though
/// text search could not reach it.
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Yc.calories.withValues(alpha: 0.10),
          border: Border.all(color: Yc.calories.withValues(alpha: 0.30)),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 17,
              color: Yc.calories,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Live search unavailable — local results only. '
                'A barcode scan may still find it.',
                style: TextStyle(fontSize: 12, color: Yc.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Single exact barcode match with a clear-filter escape hatch.
class _BarcodeResults extends StatelessWidget {
  const _BarcodeResults({
    required this.foods,
    this.meal,
    this.onPick,
    this.historyCounts = const {},
    required this.onClear,
  });

  final List<Food> foods;
  final MealType? meal;
  final void Function(Food)? onPick;
  final Map<String, int> historyCounts;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              const Text(
                'Barcode match',
                style: TextStyle(fontSize: 12.5, color: Yc.textTertiary),
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onClear,
                child: const Text(
                  'Clear',
                  style: TextStyle(fontSize: 12.5, color: Yc.calories),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: FoodResultsList(
            results: foods,
            meal: meal,
            onPick: onPick,
            onAddManually: () =>
                _openCustomFood(context, meal: meal, onPick: onPick),
            bottomPadding: 120,
            historyCounts: historyCounts,
          ),
        ),
      ],
    );
  }
}

/// Barcode scanned but no product exists anywhere: offer to save it as a
/// custom food with the code prefilled, so the next scan finds it.
class _BarcodeMiss extends StatelessWidget {
  const _BarcodeMiss({
    required this.barcode,
    required this.onClear,
    this.meal,
    this.onPick,
  });

  final String barcode;
  final MealType? meal;
  final void Function(Food)? onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.qr_code_2_rounded,
              size: 48,
              color: Yc.textTertiary,
            ),
            const SizedBox(height: 14),
            Text(
              'No product for barcode $barcode',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Yc.textTertiary, fontSize: 15),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Yc.calories,
                foregroundColor: const Color(0xFF06251B),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => _openCustomFood(
                context,
                meal: meal,
                barcode: barcode,
                onPick: onPick,
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add a custom food',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
            TextButton(
              onPressed: onClear,
              child: const Text(
                'Clear',
                style: TextStyle(fontSize: 12.5, color: Yc.calories),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab({this.meal, this.onPick, this.excludeId});

  final MealType? meal;
  final void Function(Food)? onPick;
  final String? excludeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoritesProvider);
    final favs = favAsync.value ?? const [];
    if (favAsync.isLoading) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: List.generate(
          5,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Skeleton(height: 64, radius: 20),
          ),
        ),
      );
    }
    if (favs.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'No favourites yet — star foods from the portion editor to pin them here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Yc.textTertiary, fontSize: 13, height: 1.5),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: favs.length,
      itemBuilder: (context, i) {
        final f = favs[i];
        if (excludeId != null && f.id == excludeId) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: FoodResultTile(food: f, meal: meal, onPick: onPick),
        );
      },
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab({this.meal, this.onPick, this.excludeId});

  final MealType? meal;
  final void Function(Food)? onPick;
  final String? excludeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyDistinctProvider);
    final items = historyAsync.value ?? const [];
    if (historyAsync.isLoading) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: List.generate(
          7,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: Skeleton(height: 64, radius: 20),
          ),
        ),
      );
    }
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            'Nothing logged yet — search above to begin',
            textAlign: TextAlign.center,
            style: TextStyle(color: Yc.textTertiary, fontSize: 13),
          ),
        ),
      );
    }
    // Group by generalized day so the list reads "Today / Yesterday /
    // X days ago" instead of repeating "Last logged …" on every tile.
    final groups = <String, List<RecentFood>>{};
    final order = <String>[];
    for (final item in items) {
      final key = _dayGroupKey(item.lastLogged);
      if (!groups.containsKey(key)) {
        groups[key] = [];
        order.add(key);
      }
      groups[key]!.add(item);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
      itemCount: order.length,
      itemBuilder: (context, gi) {
        final key = order[gi];
        final group = groups[key]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 6, bottom: 6, top: 4),
              child: Text(
                _dayGroupLabel(group.first.lastLogged),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Yc.textTertiary,
                ),
              ),
            ),
            ...group.map((item) {
              if (excludeId != null && item.food.id == excludeId) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: FoodResultTile(
                  meal: meal,
                  onPick: onPick,
                  food: LogEntryFoodAdapter.of(
                    LogEntry(
                      id: '',
                      day: '',
                      meal: MealType.snack,
                      foodId: item.food.id,
                      name: item.food.name,
                      brand: item.food.brand,
                      source: item.food.source,
                      grams: item.food.defaultGrams,
                      nutr: item.food.per100,
                      createdAt: item.lastLogged,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  /// Day bucket key (yyyy-MM-dd) for grouping.
  String _dayGroupKey(DateTime dt) {
    final d = DateTime(dt.year, dt.month, dt.day);
    return d.dayKey;
  }

  /// Generalized day label: Today / Yesterday / X days ago / date.
  String _dayGroupLabel(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diffDays = today.difference(day).inDays;
    if (diffDays <= 0) return 'Today';
    if (diffDays == 1) return 'Yesterday';
    if (diffDays < 7) return '$diffDays days ago';
    return dt.prettyDay;
  }
}
