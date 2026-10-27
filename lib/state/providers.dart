import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

import '../data/ai/gemini_client.dart';
import '../data/db/database.dart';
import '../data/repositories.dart';
import '../data/search/off_client.dart';
import '../domain/activity.dart';
import '../domain/food.dart';
import '../domain/weight.dart';
import 'activity_search_controller.dart';
import '../domain/nutriments.dart';
import '../domain/portion.dart';
import '../domain/profile.dart';
import 'search_controller.dart';

// ─── Core singletons ────────────────────────────────────────────────────────

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final foodRepoProvider = Provider<FoodRepository>(
  (ref) => FoodRepository(ref.watch(databaseProvider)),
);
final diaryRepoProvider = Provider<DiaryRepository>(
  (ref) => DiaryRepository(ref.watch(databaseProvider)),
);
final recipeRepoProvider = Provider<RecipeRepository>(
  (ref) => RecipeRepository(ref.watch(databaseProvider)),
);
final profileRepoProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(ref.watch(databaseProvider)),
);
final settingsRepoProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);
final activityRepoProvider = Provider<ActivityRepository>(
  (ref) => ActivityRepository(ref.watch(databaseProvider)),
);
final exerciseRepoProvider = Provider<ExerciseRepository>(
  (ref) => ExerciseRepository(ref.watch(databaseProvider)),
);
final weightRepoProvider = Provider<WeightRepository>(
  (ref) => WeightRepository(ref.watch(databaseProvider)),
);

final offClientProvider = Provider<OffClient>((ref) {
  final c = OffClient();
  ref.onDispose(c.dispose);
  return c;
});

final geminiClientProvider = Provider<GeminiClient>((ref) => GeminiClient());

const _secure = FlutterSecureStorage();

// ─── Gemini key management ──────────────────────────────────────────────────

class GeminiKeyState {
  const GeminiKeyState({this.key, this.loading = false});
  final String? key;
  final bool loading;

  bool get hasKey => key != null && key!.trim().isNotEmpty;

  GeminiKeyState copyWith({String? key, bool? loading}) =>
      GeminiKeyState(key: key ?? this.key, loading: loading ?? this.loading);
}

class GeminiKeyController extends StateNotifier<GeminiKeyState> {
  GeminiKeyController() : super(const GeminiKeyState(loading: true)) {
    _loadFuture = _load();
  }

  static const _storageKey = 'gemini_api_key';

  late final Future<void> _loadFuture;

  /// Completes once the persisted key has been read. AI callers must
  /// await this (via [ensureKey]) instead of reading `hasKey`
  /// synchronously — otherwise a cold-start analysis races secure-storage
  /// latency and falsely reports "no key".
  Future<void> get ready => _loadFuture;

  /// Trimmed key, or null when missing. Waits for the initial load
  /// (bounded by [timeout]) so early AI calls don't false-negative.
  Future<String?> ensureKey({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      await ready.timeout(timeout);
    } catch (_) {
      // Timeout / load failure — fall through to whatever we have.
    }
    final k = state.key?.trim();
    return (k == null || k.isEmpty) ? null : k;
  }

  Future<void> _load() async {
    try {
      final k = await _secure.read(key: _storageKey);
      final t = k?.trim();
      if (!mounted) return;
      state = GeminiKeyState(
        key: (t == null || t.isEmpty) ? null : t,
        loading: false,
      );
    } catch (_) {
      if (!mounted) return;
      state = const GeminiKeyState(loading: false);
    }
  }

  Future<void> save(String key) async {
    final trimmed = key.trim();
    await _secure.write(key: _storageKey, value: trimmed);
    if (!mounted) return;
    state = GeminiKeyState(
      key: trimmed.isEmpty ? null : trimmed,
      loading: false,
    );
  }

  Future<void> clear() async {
    await _secure.delete(key: _storageKey);
    if (!mounted) return;
    state = const GeminiKeyState(loading: false);
  }
}

final geminiKeyProvider =
    StateNotifierProvider<GeminiKeyController, GeminiKeyState>(
      (ref) => GeminiKeyController(),
    );

// ─── Gemini model preference ─────────────────────────────────────────────────

/// 'auto' or a concrete model id, persisted in the Settings table so scans
/// start on a known-good model (no dead-alias probing every session).
class GeminiModelState {
  const GeminiModelState({
    this.preference = GeminiClient.autoModel,
    this.loading = false,
    this.available = const [],
    this.loadingModels = false,
    this.error,
  });

  final String preference; // 'auto' | model id
  final bool loading;
  final List<String> available;
  final bool loadingModels;
  final String? error;

  GeminiModelState copyWith({
    String? preference,
    bool? loading,
    List<String>? available,
    bool? loadingModels,
    String? error,
  }) => GeminiModelState(
    preference: preference ?? this.preference,
    loading: loading ?? this.loading,
    available: available ?? this.available,
    loadingModels: loadingModels ?? this.loadingModels,
    error: error,
  );
}

class GeminiModelController extends StateNotifier<GeminiModelState> {
  GeminiModelController(this._ref) : super(const GeminiModelState()) {
    _load();
  }

  final Ref _ref;
  static const _settingsKey = 'gemini_model';

  GeminiClient get _client => _ref.read(geminiClientProvider);

  Future<void> _load() async {
    final saved = await _ref.read(settingsRepoProvider).get(_settingsKey);
    if (saved != null && saved.isNotEmpty) {
      _client.modelPreference = saved;
      state = state.copyWith(preference: saved);
    }
  }

  Future<void> setPreference(String value) async {
    state = state.copyWith(preference: value, loading: true, error: null);
    _client.modelPreference = value;
    await _ref.read(settingsRepoProvider).set(_settingsKey, value);
    state = state.copyWith(loading: false);
  }

  /// Pull the live model list for the picker (needs the API key).
  Future<void> refreshModels() async {
    state = state.copyWith(loadingModels: true, error: null);
    final key = await _ref.read(geminiKeyProvider.notifier).ensureKey();
    if (key == null) {
      if (!mounted) return;
      state = state.copyWith(
        error: 'Add your Gemini API key first.',
        loadingModels: false,
      );
      return;
    }
    try {
      final models = await _client.listModels(key);
      if (!mounted) return;
      state = state.copyWith(available: models, loadingModels: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        error: 'Could not list models ($e).',
        loadingModels: false,
      );
    }
  }
}

final geminiModelProvider =
    StateNotifierProvider<GeminiModelController, GeminiModelState>(
      (ref) => GeminiModelController(ref),
    );

// ─── Profile / goals ────────────────────────────────────────────────────────

final profileProvider = StreamProvider<Profile?>(
  (ref) => ref.watch(profileRepoProvider).watchProfile(),
);

// ─── First-run catalog import ───────────────────────────────────────────────

class ImportState {
  const ImportState({
    this.stage = '',
    this.done = 0,
    this.total = 0,
    this.finished = false,
    this.error,
  });

  final String stage;
  final int done;
  final int total;
  final bool finished;
  final Object? error;

  bool get working => !finished && error == null;

  ImportState copyWith({
    String? stage,
    int? done,
    int? total,
    bool? finished,
    Object? error,
  }) => ImportState(
    stage: stage ?? this.stage,
    done: done ?? this.done,
    total: total ?? this.total,
    finished: finished ?? this.finished,
    error: error ?? this.error,
  );
}

class ImportController extends StateNotifier<ImportState> {
  ImportController(this._ref) : super(const ImportState());

  final Ref _ref;
  bool _started = false;

  Future<void> startIfNeeded() async {
    if (_started) return;
    _started = true;
    try {
      final importer = SeedImporter(
        _ref.read(foodRepoProvider),
        _ref.read(settingsRepoProvider),
        onProgress: (stage, done, total) {
          state = state.copyWith(stage: stage, done: done, total: total);
        },
      );
      await importer.importIfNeeded();
      // Activity catalog is versioned separately — no food churn.
      final activityImporter = ActivitySeedImporter(
        _ref.read(activityRepoProvider),
        _ref.read(settingsRepoProvider),
        onProgress: (stage, done, total) {
          state = state.copyWith(stage: stage, done: done, total: total);
        },
      );
      await activityImporter.importIfNeeded();
      _ref.invalidate(catalogStatsProvider);
      state = state.copyWith(finished: true);
    } catch (e) {
      state = state.copyWith(error: e, finished: true);
    }
  }
}

final importProvider = StateNotifierProvider<ImportController, ImportState>(
  (ref) => ImportController(ref)..startIfNeeded(),
);

// ─── Diary ──────────────────────────────────────────────────────────────────

final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

String _dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

final dayEntriesProvider = StreamProvider.family<List<LogEntry>, DateTime>(
  (ref, date) => ref.watch(diaryRepoProvider).watchDay(_dayKey(date)),
);

final dayExerciseProvider =
    StreamProvider.family<List<ExerciseEntry>, DateTime>(
      (ref, date) => ref.watch(exerciseRepoProvider).watchDay(_dayKey(date)),
    );

/// Diary display mode: daily sections vs the Sun–Sat weekly summary.
/// Tapping a day chip snaps back to daily.
final diaryWeeklyProvider = StateProvider<bool>((ref) => false);

/// Start (Sunday) of the week containing [date].
DateTime weekStartOf(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  return d.subtract(Duration(days: d.weekday % 7));
}

/// All 7 days (Sun–Sat) of the week containing [date].
List<DateTime> weekDaysOf(DateTime date) {
  final start = weekStartOf(date);
  return List.generate(7, (i) => start.add(Duration(days: i)));
}

/// Every log entry in the Sun–Sat week containing [date].
/// Re-emits whenever any row in the week changes (one watch per day).
final weekEntriesProvider = StreamProvider.family<List<LogEntry>, DateTime>((
  ref,
  date,
) async* {
  final repo = ref.watch(diaryRepoProvider);
  final days = weekDaysOf(date);
  final streams = [for (final d in days) repo.watchDay(_dayKey(d))];
  // Combine the 7 day-streams: re-emit the merged list whenever any
  // of them fires. Implemented with a broadcast fan-in so late
  // invalidation still merges correctly.
  final latest = List<List<LogEntry>?>.filled(7, null);
  var ready = 0;
  final controller = StreamController<List<LogEntry>>();
  final subs = <StreamSubscription>[];
  for (var i = 0; i < 7; i++) {
    final idx = i;
    subs.add(
      streams[idx].listen((entries) {
        if (latest[idx] == null) ready++;
        latest[idx] = entries;
        if (ready == 7 && !controller.isClosed) {
          controller.add(latest.expand((l) => l!).toList());
        }
      }),
    );
  }
  ref.onDispose(() {
    for (final s in subs) {
      s.cancel();
    }
    controller.close();
  });
  await for (final merged in controller.stream) {
    yield merged;
  }
});

/// Every exercise entry in the Sun–Sat week containing [date].
final weekExerciseProvider =
    StreamProvider.family<List<ExerciseEntry>, DateTime>((ref, date) async* {
      final repo = ref.watch(exerciseRepoProvider);
      final days = weekDaysOf(date);
      final latest = List<List<ExerciseEntry>?>.filled(7, null);
      var ready = 0;
      final controller = StreamController<List<ExerciseEntry>>();
      final subs = <StreamSubscription>[];
      for (var i = 0; i < 7; i++) {
        final idx = i;
        subs.add(
          repo.watchDay(_dayKey(days[idx])).listen((entries) {
            if (latest[idx] == null) ready++;
            latest[idx] = entries;
            if (ready == 7 && !controller.isClosed) {
              controller.add(latest.expand((l) => l!).toList());
            }
          }),
        );
      }
      ref.onDispose(() {
        for (final s in subs) {
          s.cancel();
        }
        controller.close();
      });
      await for (final merged in controller.stream) {
        yield merged;
      }
    });

final activityFavoritesProvider = StreamProvider(
  (ref) => ref.watch(activityRepoProvider).watchFavorites(),
);

final activitySearchControllerProvider =
    StateNotifierProvider<ActivitySearchController, ActivitySearchState>(
      (ref) => ActivitySearchController(ref.watch(activityRepoProvider)),
    );

/// Distinct logged activities for the activity History tab.
///
/// A live stream (not a one-shot future): the modal opens directly on the
/// History tab, so a cached future would keep showing the pre-logging
/// empty state forever. Re-queries whenever exercise rows change.
final activityHistoryProvider = StreamProvider((ref) async* {
  final db = ref.watch(databaseProvider);
  final repo = ref.watch(activityRepoProvider);
  yield await repo.historyDistinct(limit: 100);
  await for (final _ in db.select(db.exerciseEntries).watch()) {
    yield await repo.historyDistinct(limit: 100);
  }
});

// ─── Diary multi-select ──────────────────────────────────────────────────────

/// UI mode for the diary list.
enum DiaryListMode { normal, multiSelect }

class DiarySelectionState {
  const DiarySelectionState({
    this.mode = DiaryListMode.normal,
    this.selectedIds = const {},
  });

  final DiaryListMode mode;

  /// Multi-select selection (entry ids).
  final Set<String> selectedIds;

  DiarySelectionState copyWith({
    DiaryListMode? mode,
    Set<String>? selectedIds,
  }) => DiarySelectionState(
    mode: mode ?? this.mode,
    selectedIds: selectedIds ?? this.selectedIds,
  );

  bool get isMultiSelect => mode == DiaryListMode.multiSelect;
}

class DiarySelectionController extends StateNotifier<DiarySelectionState> {
  DiarySelectionController() : super(const DiarySelectionState());

  /// Long-press-and-lift on a tile: enter multi-select with it checked.
  /// Tapping it again while selected deselects (via [toggle]).
  void toggleAndEnter(String id) => state = DiarySelectionState(
    mode: DiaryListMode.multiSelect,
    selectedIds: state.isMultiSelect
        ? (state.selectedIds.contains(id)
              ? ({...state.selectedIds}..remove(id))
              : ({...state.selectedIds}..add(id)))
        : {id},
  );

  void toggle(String id) {
    if (state.mode != DiaryListMode.multiSelect) return;
    final ids = {...state.selectedIds};
    if (!ids.add(id)) ids.remove(id);
    state = state.copyWith(selectedIds: ids);
  }

  void selectAll(Iterable<String> ids) =>
      state = state.copyWith(selectedIds: {...ids});

  /// Leave multi-select only if it's active (a deliberate drag cancels it).
  void exitIfMultiSelect() {
    if (state.isMultiSelect) exit();
  }

  void exit() => state = const DiarySelectionState();
}

final diarySelectionProvider =
    StateNotifierProvider<DiarySelectionController, DiarySelectionState>(
      (ref) => DiarySelectionController(),
    );

/// Today's day key (recomputed on read — cheap).
String todayKey() => _dayKey(DateTime.now());

final favoritesProvider = StreamProvider(
  (ref) => ref.watch(foodRepoProvider).watchFavorites(),
);

/// Recipe list sort modes (persisted in Settings).
enum RecipeSort { alphabetical, lastUsedNewest, lastUsedOldest, custom }

extension RecipeSortX on RecipeSort {
  String get label => switch (this) {
    RecipeSort.alphabetical => 'A–Z',
    RecipeSort.lastUsedNewest => 'Last used (newest)',
    RecipeSort.lastUsedOldest => 'Last used (oldest)',
    RecipeSort.custom => 'Custom',
  };

  static RecipeSort fromName(String? s) => RecipeSort.values.firstWhere(
    (e) => e.name == s,
    orElse: () => RecipeSort.lastUsedNewest,
  );
}

class RecipeSortController extends StateNotifier<RecipeSort> {
  RecipeSortController(this._ref) : super(RecipeSort.lastUsedNewest) {
    _load();
  }

  final Ref _ref;
  static const _key = 'recipe_sort';

  Future<void> _load() async {
    final saved = await _ref.read(settingsRepoProvider).get(_key);
    if (mounted && saved != null && saved.isNotEmpty) {
      state = RecipeSortX.fromName(saved);
    }
  }

  Future<void> set(RecipeSort sort) async {
    state = sort;
    await _ref.read(settingsRepoProvider).set(_key, sort.name);
  }
}

final recipeSortProvider =
    StateNotifierProvider<RecipeSortController, RecipeSort>(
      (ref) => RecipeSortController(ref),
    );

/// Custom drag-to-reorder position for the recipe list (recipe ids in
/// order). Unknown ids sort after the listed ones.
class RecipeCustomOrderController extends StateNotifier<List<String>> {
  RecipeCustomOrderController(this._ref) : super(const []) {
    _load();
  }

  final Ref _ref;
  static const _key = 'recipe_custom_order';

  Future<void> _load() async {
    final saved = await _ref.read(settingsRepoProvider).get(_key);
    if (mounted && saved != null && saved.isNotEmpty) {
      state = saved.split(',').where((s) => s.isNotEmpty).toList();
    }
  }

  Future<void> setOrder(List<String> ids) async {
    state = [...ids];
    await _ref.read(settingsRepoProvider).set(_key, ids.join(','));
  }
}

final recipeCustomOrderProvider =
    StateNotifierProvider<RecipeCustomOrderController, List<String>>(
      (ref) => RecipeCustomOrderController(ref),
    );

/// Recipes sorted per [recipeSortProvider]. Last-used timestamps come
/// from diary entries referencing recipe foods.
final recipesProvider = StreamProvider((ref) async* {
  final db = ref.watch(databaseProvider);
  final repo = ref.watch(recipeRepoProvider);
  final sort = ref.watch(recipeSortProvider);
  final customOrder = ref.watch(recipeCustomOrderProvider);

  await for (final recipes in repo.watchAll()) {
    final rows = await db
        .customSelect(
          "SELECT food_id, COUNT(*) AS n, MAX(created_at) AS latest FROM log_entries "
          "WHERE food_id LIKE 'recipe:%' GROUP BY food_id",
        )
        .get();
    final lastUsed = {
      for (final r in rows)
        (r.data['food_id'] as String).substring('recipe:'.length):
            _parseLogTime(r.data['latest']),
    };
    final sorted = [...recipes]
      ..sort((a, b) {
        switch (sort) {
          case RecipeSort.alphabetical:
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          case RecipeSort.lastUsedNewest:
            final la = lastUsed[a.id];
            final lb = lastUsed[b.id];
            if (la == null && lb == null) {
              return b.createdAt.compareTo(a.createdAt);
            }
            if (la == null) return 1;
            if (lb == null) return -1;
            return lb.compareTo(la);
          case RecipeSort.lastUsedOldest:
            final la = lastUsed[a.id];
            final lb = lastUsed[b.id];
            if (la == null && lb == null) {
              return b.createdAt.compareTo(a.createdAt);
            }
            if (la == null) return 1;
            if (lb == null) return -1;
            return la.compareTo(lb);
          case RecipeSort.custom:
            final order = {
              for (var i = 0; i < customOrder.length; i++) customOrder[i]: i,
            };
            final ia = order[a.id];
            final ib = order[b.id];
            if (ia == null && ib == null) {
              return b.createdAt.compareTo(a.createdAt);
            }
            if (ia == null) return 1;
            if (ib == null) return -1;
            return ia.compareTo(ib);
        }
      });
    // Keep the custom order list warm: newly created recipes (absent
    // from the list) still sort deterministically above.
    yield sorted;
  }
});

// ─── Search ─────────────────────────────────────────────────────────────────

final searchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>(
      (ref) => SearchController(
        ref.watch(foodRepoProvider),
        ref.watch(offClientProvider),
      ),
    );

/// Dedicated search state for the Library page. The modal search sheets
/// (capture flow, recipe ingredient picker) share [searchControllerProvider]
/// and reset on open; Library stays alive in the IndexedStack so it needs
/// its own instance to avoid clobbering queries.
final librarySearchControllerProvider =
    StateNotifierProvider<SearchController, SearchState>(
      (ref) => SearchController(
        ref.watch(foodRepoProvider),
        ref.watch(offClientProvider),
      ),
    );

// ─── Photo flow ─────────────────────────────────────────────────────────────

sealed class PhotoFlowState {
  const PhotoFlowState();
}

class PhotoIdle extends PhotoFlowState {
  const PhotoIdle();
}

class PhotoAnalyzing extends PhotoFlowState {
  const PhotoAnalyzing({required this.previewPath});
  final String previewPath;
}

class PhotoReady extends PhotoFlowState {
  const PhotoReady({
    required this.items,
    required this.previewPath,
    this.correctingIndex,
    this.description,
  });
  final List<PendingItem> items;
  final String previewPath;

  /// Index of the item currently being re-analysed by AI (spinner).
  final int? correctingIndex;

  /// When the flow was started from typed text (Describe to AI) rather
  /// than a photo, the user's description. Empty for photo flows.
  final String? description;

  PhotoReady copyWith({
    List<PendingItem>? items,
    int? correctingIndex,
    bool clearCorrecting = false,
    String? description,
  }) => PhotoReady(
    items: items ?? this.items,
    previewPath: previewPath,
    correctingIndex: clearCorrecting
        ? null
        : (correctingIndex ?? this.correctingIndex),
    description: description ?? this.description,
  );
}

class PhotoError extends PhotoFlowState {
  const PhotoError(this.message);
  final String message;
}

/// An AI-detected item awaiting confirmation, with live-editable portions.
///
/// [grams] is the canonical resolved weight used for nutrition math;
/// [qty]/[unit]/[servingIdx] preserve the user's display intent (same
/// model as the recipe editor). Use [copyWith] — items are immutable so
/// state emissions always produce a new list.
class PendingItem {
  PendingItem({
    required this.detected,
    required this.grams,
    required this.matchedFood,
    double? qty,
    PortionUnit? unit,
    this.servingIdx = 0,
  }) : qty = qty ?? grams,
       unit = unit ?? PortionUnit.g;

  final DetectedItem detected;

  /// Resolved gram weight for nutrition math.
  final double grams;
  final Food? matchedFood; // verified DB match that overrides AI numbers

  /// Display amount + unit (e.g. 1.5 serves).
  final double qty;
  final PortionUnit unit;
  final int servingIdx;

  NutrimentsLike get nutr => NutrimentsLike(matchedFood, detected, grams);

  PendingItem copyWith({
    double? grams,
    Food? matchedFood,
    double? qty,
    PortionUnit? unit,
    int? servingIdx,
  }) => PendingItem(
    detected: detected,
    grams: grams ?? this.grams,
    matchedFood: matchedFood ?? this.matchedFood,
    qty: qty ?? this.qty,
    unit: unit ?? this.unit,
    servingIdx: servingIdx ?? this.servingIdx,
  );
}

class NutrimentsLike {
  NutrimentsLike(this.matchedFood, this.detected, this.grams);
  final Food? matchedFood;
  final DetectedItem detected;
  final double grams;

  // NOTE: the AI path must scale per-100g numbers by the edited grams.
  // Previously it returned `detected.totals` (frozen at detection time),
  // so the slider appeared to do nothing for unmatched items.
  double get kcal => matchedFood != null
      ? matchedFood!.per100.kcal * grams / 100
      : detected.per100.kcal * grams / 100;
  double get protein => matchedFood != null
      ? matchedFood!.per100.proteinG * grams / 100
      : detected.per100.proteinG * grams / 100;
  double get carbs => matchedFood != null
      ? matchedFood!.per100.carbsG * grams / 100
      : detected.per100.carbsG * grams / 100;
  double get fat => matchedFood != null
      ? matchedFood!.per100.fatG * grams / 100
      : detected.per100.fatG * grams / 100;
}

class PhotoFlowController extends StateNotifier<PhotoFlowState> {
  PhotoFlowController(this._ref) : super(const PhotoIdle());

  final Ref _ref;
  List<int> _lastBytes = const [];

  Future<void> analyze(List<int> jpegBytes, String previewPath) async {
    _lastBytes = jpegBytes;
    // Fast path: key already known-missing (loaded, empty) fails fast
    // without flashing the spinner. When still loading, fall through to
    // Analyzing + await so cold-start calls don't false-negative.
    final fast = _ref.read(geminiKeyProvider);
    if (!fast.loading && !fast.hasKey) {
      state = const PhotoError('Add your Gemini API key in Settings first.');
      return;
    }
    state = PhotoAnalyzing(previewPath: previewPath);
    final apiKey = await _ref.read(geminiKeyProvider.notifier).ensureKey();
    if (apiKey == null) {
      state = const PhotoError('Add your Gemini API key in Settings first.');
      return;
    }
    try {
      final analysis = await _ref
          .read(geminiClientProvider)
          .analyzePhoto(jpegBytes: jpegBytes, apiKey: apiKey);
      if (!analysis.isFood || analysis.items.isEmpty) {
        state = const PhotoError('No food detected — try a clearer photo.');
        return;
      }

      // Cross-match each item against our verified databases.
      final pending = <PendingItem>[];
      for (final item in analysis.items) {
        Food? match;
        try {
          final hits = await _ref
              .read(foodRepoProvider)
              .search(item.name, limit: 3, includeHistoryBoost: false);
          if (hits.isNotEmpty &&
              (hits.first.source.verified ||
                  hits.first.source == FoodSource.off)) {
            match = hits.first;
          }
        } catch (_) {}
        pending.add(
          PendingItem(detected: item, grams: item.grams, matchedFood: match),
        );
      }

      state = PhotoReady(items: pending, previewPath: previewPath);
    } on GeminiException catch (e) {
      state = PhotoError(e.message);
    } catch (_) {
      state = const PhotoError('Analysis failed — please try again.');
    }
  }

  /// Re-identifies an item from the user's free-text correction.
  Future<void> correctItem(int index, String correction) async {
    final s = state;
    if (s is! PhotoReady || correction.trim().isEmpty) return;
    final fast = _ref.read(geminiKeyProvider);
    if (!fast.loading && !fast.hasKey) {
      state = const PhotoError('Add your Gemini API key in Settings first.');
      return;
    }
    state = s.copyWith(correctingIndex: index);
    final apiKey = await _ref.read(geminiKeyProvider.notifier).ensureKey();
    if (apiKey == null) {
      state = const PhotoError('Add your Gemini API key in Settings first.');
      return;
    }
    try {
      final item = await _ref
          .read(geminiClientProvider)
          .correctItem(
            jpegBytes: _lastBytes,
            originalName: s.items[index].detected.name,
            userCorrection: correction.trim(),
            apiKey: apiKey,
          );
      Food? match;
      try {
        final hits = await _ref
            .read(foodRepoProvider)
            .search(item.name, limit: 3, includeHistoryBoost: false);
        if (hits.isNotEmpty && hits.first.source.verified) match = hits.first;
      } catch (_) {}
      if (state is! PhotoReady) return;
      final cur = state as PhotoReady;
      final items = [...cur.items];
      if (index >= items.length) return;
      items[index] = PendingItem(
        detected: item,
        grams: item.grams,
        matchedFood: match,
      );
      state = PhotoReady(items: items, previewPath: cur.previewPath);
    } on GeminiException catch (e) {
      state = PhotoError(e.message);
    } catch (_) {
      state = const PhotoError('Correction failed — try again.');
    }
  }

  /// Direct gram edit (kept for compat; prefers [updatePortion]).
  void updateGrams(int index, double grams) {
    final s = state;
    if (s is! PhotoReady) return;
    if (index < 0 || index >= s.items.length) return;
    final clamped = grams.clamp(0, 5000).toDouble();
    final items = [...s.items];
    final old = items[index];
    items[index] = old.copyWith(grams: clamped, qty: clamped);
    state = s.copyWith(items: items, clearCorrecting: true);
  }

  /// Recipe-style portion edit: resolves qty+unit into grams via
  /// [PortionMath] so all measurement types behave identically.
  void updatePortion(
    int index, {
    required double qty,
    required PortionUnit unit,
    required int servingIdx,
    required double servingGrams,
  }) {
    final s = state;
    if (s is! PhotoReady) return;
    if (index < 0 || index >= s.items.length) return;
    final grams = PortionMath.resolveGrams(
      unit: unit,
      qty: qty.clamp(0, 5000).toDouble(),
      servingGrams: servingGrams,
    ).clamp(0, 5000).toDouble();
    final items = [...s.items];
    items[index] = s.items[index].copyWith(
      grams: grams,
      qty: qty.clamp(0, 5000).toDouble(),
      unit: unit,
      servingIdx: servingIdx,
    );
    state = s.copyWith(items: items, clearCorrecting: true);
  }

  /// Text-based analysis (Describe to AI): same confirmation flow as
  /// photos, but sourced from a typed description. No image bytes.
  Future<void> analyzeText(String description) async {
    final text = description.trim();
    if (text.isEmpty) {
      state = const PhotoError('Describe your meal first.');
      return;
    }
    final fast = _ref.read(geminiKeyProvider);
    if (!fast.loading && !fast.hasKey) {
      state = const PhotoError('Add your Gemini API key in Settings first.');
      return;
    }
    _lastBytes = const [];
    state = const PhotoAnalyzing(previewPath: '');
    final apiKey = await _ref.read(geminiKeyProvider.notifier).ensureKey();
    if (apiKey == null) {
      state = const PhotoError('Add your Gemini API key in Settings first.');
      return;
    }
    try {
      final analysis = await _ref
          .read(geminiClientProvider)
          .analyzeText(description: text, apiKey: apiKey);
      if (!analysis.isFood || analysis.items.isEmpty) {
        state = const PhotoError('No food detected — try more detail.');
        return;
      }
      final pending = <PendingItem>[];
      for (final item in analysis.items) {
        Food? match;
        try {
          final hits = await _ref
              .read(foodRepoProvider)
              .search(item.name, limit: 3, includeHistoryBoost: false);
          if (hits.isNotEmpty &&
              (hits.first.source.verified ||
                  hits.first.source == FoodSource.off)) {
            match = hits.first;
          }
        } catch (_) {}
        pending.add(
          PendingItem(detected: item, grams: item.grams, matchedFood: match),
        );
      }
      state = PhotoReady(items: pending, previewPath: '', description: text);
    } on GeminiException catch (e) {
      state = PhotoError(e.message);
    } catch (_) {
      state = const PhotoError('Analysis failed — please try again.');
    }
  }

  void removeItem(int index) {
    final s = state;
    if (s is! PhotoReady) return;
    final items = [...s.items]..removeAt(index);
    state = PhotoReady(items: items, previewPath: s.previewPath);
  }

  void reset() => state = const PhotoIdle();
}

final photoFlowControllerProvider =
    StateNotifierProvider<PhotoFlowController, PhotoFlowState>(
      (ref) => PhotoFlowController(ref),
    );

// ─── Catalog stats ──────────────────────────────────────────────────────────

class CatalogStats {
  const CatalogStats({required this.total, required this.bySource});
  final int total;
  final Map<String, int> bySource;
}

final catalogStatsProvider = FutureProvider<CatalogStats>((ref) async {
  final db = ref.watch(databaseProvider);
  final rows = await db
      .customSelect('SELECT source, COUNT(*) AS n FROM foods GROUP BY source')
      .get();
  final bySource = {
    for (final r in rows) r.data['source'] as String: r.data['n'] as int,
  };
  return CatalogStats(
    total: bySource.values.fold(0, (a, b) => a + b),
    bySource: bySource,
  );
});

final recentsProvider = FutureProvider.autoDispose<List<LogEntry>>((ref) async {
  // Distinct recently-logged foods, resolved back to full Food rows.
  // Kept for the modal search sheet; the Library History tab uses
  // [historyDistinctProvider] (larger limit + timestamps + counts).
  final repo = ref.watch(foodRepoProvider);
  final rows = await ref
      .watch(databaseProvider)
      .customSelect(
        'SELECT DISTINCT food_id, MAX(created_at) AS latest FROM log_entries '
        'GROUP BY food_id ORDER BY latest DESC LIMIT 12',
      )
      .get();
  final ids = rows.map((r) => r.data['food_id'] as String).toList();
  final out = <LogEntry>[];
  for (final id in ids) {
    final food = await repo.byId(id);
    if (food != null) {
      out.add(
        LogEntry(
          id: '',
          day: '',
          meal: MealType.snack,
          foodId: food.id,
          name: food.name,
          brand: food.brand,
          source: food.source,
          grams: food.defaultGrams,
          nutr: food.per100,
          createdAt: DateTime.now(),
        ),
      );
    }
  }
  return out;
});

/// One distinct food from log history with recency metadata.
class RecentFood {
  const RecentFood({
    required this.food,
    required this.lastLogged,
    required this.count,
  });

  final Food food;
  final DateTime lastLogged;
  final int count;
}

DateTime _parseLogTime(Object? raw) {
  if (raw is DateTime) return raw;
  if (raw is int) {
    // Drift stores DateTime as seconds or millis since epoch.
    if (raw > 1000000000000) return DateTime.fromMillisecondsSinceEpoch(raw);
    return DateTime.fromMillisecondsSinceEpoch(raw * 1000);
  }
  if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
  return DateTime.now();
}

/// Distinct recently-logged foods for the Library History tab (default).
/// Extended to ~100 rows so users can scroll back almost a week.
///
/// A live stream (not a one-shot future): re-queries whenever log rows
/// change so freshly-logged foods appear in History immediately.
final historyDistinctProvider = StreamProvider<List<RecentFood>>((ref) async* {
  final db = ref.watch(databaseProvider);
  final repo = ref.watch(foodRepoProvider);
  yield await _fetchHistoryDistinct(db, repo);
  await for (final _ in db.select(db.logEntries).watch()) {
    yield await _fetchHistoryDistinct(db, repo);
  }
});

Future<List<RecentFood>> _fetchHistoryDistinct(
  AppDatabase db,
  FoodRepository repo,
) async {
  final rows = await db
      .customSelect(
        'SELECT food_id, MAX(created_at) AS latest, COUNT(*) AS n '
        'FROM log_entries GROUP BY food_id ORDER BY latest DESC LIMIT 100',
      )
      .get();
  if (rows.isEmpty) return const [];
  final ids = rows.map((r) => r.data['food_id'] as String).toList();
  final latestById = {
    for (final r in rows)
      r.data['food_id'] as String: _parseLogTime(r.data['latest']),
  };
  final countById = {
    for (final r in rows)
      r.data['food_id'] as String: (r.data['n'] as int? ?? 1),
  };
  final foods = await repo.byIds(ids);
  return [
    for (final f in foods)
      RecentFood(
        food: f,
        lastLogged: latestById[f.id] ?? DateTime.now(),
        count: countById[f.id] ?? 1,
      ),
  ];
}

// ─── Goals: weight log + streak + macro adherence ────────────────────────────

/// All weigh-ins, oldest first. Live stream for the Goals graph.
final weightEntriesProvider = StreamProvider<List<WeightEntry>>(
  (ref) => ref.watch(weightRepoProvider).watchAll(),
);

/// Consecutive days with at least one log entry, counting back from
/// yesterday. Today is included once logged — a missing today never
/// zeroes the streak.
final streakProvider = StreamProvider<int>((ref) async* {
  final db = ref.watch(databaseProvider);
  yield await _computeStreak(db);
  await for (final _ in db.select(db.logEntries).watch()) {
    yield await _computeStreak(db);
  }
});

Future<int> _computeStreak(AppDatabase db) async {
  final rows = await db
      .customSelect('SELECT DISTINCT day FROM log_entries ORDER BY day DESC')
      .get();
  if (rows.isEmpty) return 0;
  final days = {for (final r in rows) r.data['day'] as String};
  var cursor = DateTime.now();
  // Today missing → start counting from yesterday (streak stays alive).
  if (!days.contains(_dayKey(cursor))) {
    cursor = cursor.subtract(const Duration(days: 1));
  }
  var streak = 0;
  while (days.contains(_dayKey(cursor))) {
    streak++;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

/// Per-macro hit rate over the last 7 days (a day counts as "hit" when
/// intake lands within ±15% of target). Powers the Goals adherence card.
class MacroAdherence {
  const MacroAdherence({
    required this.proteinDays,
    required this.carbsDays,
    required this.fatDays,
    required this.days,
  });

  final int proteinDays;
  final int carbsDays;
  final int fatDays;

  /// Days with any food logged (denominator).
  final int days;
}

final weeklyMacroAdherenceProvider = FutureProvider<MacroAdherence>((
  ref,
) async {
  final db = ref.watch(databaseProvider);
  final profile = await ref.watch(profileProvider.future);
  if (profile == null) {
    return const MacroAdherence(
      proteinDays: 0,
      carbsDays: 0,
      fatDays: 0,
      days: 0,
    );
  }
  // Weigh-ins move the bands: each day is judged against the targets
  // live on THAT day.
  final weighIns = await ref.watch(weightEntriesProvider.future);
  final now = DateTime.now();
  var proteinDays = 0, carbsDays = 0, fatDays = 0, days = 0;
  for (var i = 0; i < 7; i++) {
    final day = now.subtract(Duration(days: i));
    final rows = await (db.select(
      db.logEntries,
    )..where((l) => l.day.equals(_dayKey(day)))).get();
    if (rows.isEmpty) continue;
    days++;
    final goals = Goals.effectiveForDay(profile, weighIns, day);
    var p = 0.0, c = 0.0, f = 0.0;
    for (final r in rows) {
      p += r.proteinG;
      c += r.carbsG;
      f += r.fatG;
    }
    bool hit(double v, double t) =>
        t <= 0 ? true : (v >= t * 0.85 && v <= t * 1.15);
    if (hit(p, goals.proteinG)) proteinDays++;
    if (hit(c, goals.carbsG)) carbsDays++;
    if (hit(f, goals.fatG)) fatDays++;
  }
  return MacroAdherence(
    proteinDays: proteinDays,
    carbsDays: carbsDays,
    fatDays: fatDays,
    days: days,
  );
});

/// Logs a weigh-in and syncs the profile's current weight so TDEE,
/// exercise estimates, and sliders track the latest reading.
/// Historical days keep their own targets via [Goals.effectiveForDay].
Future<void> logWeight(WidgetRef ref, double weightKg, {DateTime? at}) async {
  final repo = ref.read(weightRepoProvider);
  if (at == null) {
    await repo.add(weightKg);
  } else {
    await repo.addAt(weightKg, at);
  }
  final profile = await ref.read(profileProvider.future);
  if (profile != null && profile.weightKg != weightKg) {
    await ref
        .read(profileRepoProvider)
        .save(profile.copyWith(weightKg: weightKg));
  }
}

/// Re-syncs the profile weight to the latest weigh-in overall (used
/// after bulk imports spanning the past).
Future<void> syncProfileWeightToLatest(WidgetRef ref) async {
  final weighIns = await ref.read(weightEntriesProvider.future);
  if (weighIns.isEmpty) return;
  final latest = weighIns.reduce(
    (a, b) => a.createdAt.isAfter(b.createdAt) ? a : b,
  );
  final profile = await ref.read(profileProvider.future);
  if (profile != null && profile.weightKg != latest.weightKg) {
    await ref
        .read(profileRepoProvider)
        .save(profile.copyWith(weightKg: latest.weightKg));
  }
}

// ─── OFF catalog update ─────────────────────────────────────────────────────

class OffCatalogUpdateState {
  const OffCatalogUpdateState({
    this.running = false,
    this.done = 0,
    this.total = 0,
    this.lastUpdate,
    this.error,
    this.inserted,
    this.updatedCount,
    this.unchanged,
    this.fetched,
  });

  final bool running;
  final int done;
  final int total;
  final DateTime? lastUpdate;
  final String? error;
  final int? inserted;
  final int? updatedCount;

  /// Rows checked but identical (skipped, not rewritten).
  final int? unchanged;

  /// Total rows fetched from OFF this run.
  final int? fetched;

  OffCatalogUpdateState copyWith({
    bool? running,
    int? done,
    int? total,
    DateTime? lastUpdate,
    String? error,
    int? inserted,
    int? updatedCount,
    int? unchanged,
    int? fetched,
  }) => OffCatalogUpdateState(
    running: running ?? this.running,
    done: done ?? this.done,
    total: total ?? this.total,
    lastUpdate: lastUpdate ?? this.lastUpdate,
    error: error,
    inserted: inserted ?? this.inserted,
    updatedCount: updatedCount ?? this.updatedCount,
    unchanged: unchanged ?? this.unchanged,
    fetched: fetched ?? this.fetched,
  );
}

class OffCatalogUpdateController extends StateNotifier<OffCatalogUpdateState> {
  OffCatalogUpdateController(this._ref) : super(const OffCatalogUpdateState()) {
    _loadLastUpdate();
  }

  final Ref _ref;

  Future<void> _loadLastUpdate() async {
    final updater = _ref.read(offCatalogUpdaterProvider);
    final last = await updater.lastUpdate;
    if (mounted) state = state.copyWith(lastUpdate: last);
  }

  Future<void> runUpdate() async {
    if (state.running) return;
    state = state.copyWith(running: true, error: null, done: 0, total: 0);

    try {
      final updater = _ref.read(offCatalogUpdaterProvider);
      final result = await updater.update(
        onProgress: (stage, done, total) {
          if (mounted) {
            state = state.copyWith(
              running: true,
              done: done,
              total: total > 0 ? total : done,
              error: null,
            );
          }
        },
      );
      final last = await updater.lastUpdate;
      // Re-count the catalog so the "X foods" figure reflects new rows.
      _ref.invalidate(catalogStatsProvider);
      if (mounted) {
        state = state.copyWith(
          running: false,
          done: result.fetched,
          total: result.fetched,
          lastUpdate: last,
          inserted: result.inserted,
          updatedCount: result.updated,
          unchanged: result.unchanged,
          fetched: result.fetched,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(running: false, error: 'Update failed: $e');
      }
    }
  }
}

final offCatalogUpdaterProvider = Provider<OffCatalogUpdater>((ref) {
  return OffCatalogUpdater(
    ref.watch(foodRepoProvider),
    ref.watch(settingsRepoProvider),
  );
});

final offCatalogUpdateProvider =
    StateNotifierProvider<OffCatalogUpdateController, OffCatalogUpdateState>(
      (ref) => OffCatalogUpdateController(ref),
    );
