import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories.dart';
import '../../data/search/off_client.dart';
import '../../data/search/relevance.dart';
import '../../domain/food.dart';

enum SearchPhase { idle, localDone, remoteLoading, done }

class SearchState {
  const SearchState({
    this.query = '',
    this.phase = SearchPhase.idle,
    this.results = const [],
    this.historyCounts = const {},
    this.remoteFailed = false,
  });

  final String query;
  final SearchPhase phase;
  final List<Food> results;

  /// foodId → times logged. Powers the "logged N×" tile markers and the
  /// frequency tier in remote merges.
  final Map<String, int> historyCounts;
  final bool remoteFailed;

  bool get showSkeleton =>
      phase == SearchPhase.remoteLoading && results.isEmpty;

  SearchState copyWith({
    String? query,
    SearchPhase? phase,
    List<Food>? results,
    Map<String, int>? historyCounts,
    bool? remoteFailed,
  }) => SearchState(
    query: query ?? this.query,
    phase: phase ?? this.phase,
    results: results ?? this.results,
    historyCounts: historyCounts ?? this.historyCounts,
    remoteFailed: remoteFailed ?? this.remoteFailed,
  );
}

/// Unified search: instant local (5k+ bundled AU foods + everything cached),
/// then OFF in the background, merged + re-ranked.
///
/// Debounced 450 ms; OFF client is single-flight so bursts never stack.
class SearchController extends StateNotifier<SearchState> {
  SearchController(this._repo, this._off) : super(const SearchState());

  final FoodRepository _repo;
  final OffClient _off;

  Timer? _debounce;
  int _generation = 0;
  final Set<String> _seenIdsThisQuery = {};

  /// Fresh slate every time the search screen opens/disposes —
  /// stale last-search results must never reappear.
  void reset() {
    _debounce?.cancel();
    _generation++;
    _seenIdsThisQuery.clear();
    state = const SearchState();
  }

  void onQueryChanged(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) {
      state = const SearchState();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () => _run(q));
  }

  Future<void> _run(String rawQuery) async {
    final gen = ++_generation;
    final tokens = Relevance.tokenize(rawQuery);

    // Phase 1 — instant local results (tiered exact-recipe > exact >
    // recipe > favourite > history > relevance inside the repository).
    final local = await _repo.search(rawQuery);
    _seenIdsThisQuery
      ..clear()
      ..addAll(local.map((f) => f.id))
      ..addAll(local.map(dedupeKey));
    if (gen != _generation) return;

    // History counts for tiering the remote merge below (frequency
    // bonus included, same as local) and for tile markers.
    Set<String> historyIds = const {};
    Map<String, int> historyCounts = const {};
    try {
      historyCounts = await _repo.recentFoodCounts();
      historyIds = historyCounts.keys.toSet();
    } catch (_) {}
    if (gen != _generation) return;

    state = SearchState(
      query: rawQuery,
      phase: SearchPhase.localDone,
      results: local,
      historyCounts: historyCounts,
    );

    // Phase 2 — background OFF lookup.
    state = state.copyWith(phase: SearchPhase.remoteLoading);
    try {
      var remote = await _off.search(rawQuery);

      // Thin AU results → second pass worldwide. Catches products sold in
      // AU but tagged elsewhere (Aldi AU own-brands, imports).
      if (remote.length < 5 && !rawQuery.contains('#all')) {
        final world = await _off.search(rawQuery, worldwide: true);
        final known = remote.map(dedupeKey).toSet();
        remote = [
          ...remote,
          ...world.where((f) => !known.contains(dedupeKey(f))),
        ];
      }

      if (gen != _generation) return;
      final fresh = remote.where((f) {
        final key = dedupeKey(f);
        return !_seenIdsThisQuery.contains(f.id) &&
            !_seenIdsThisQuery.contains(key);
      }).toList();

      // Cache into local DB so future searches are offline-fast.
      if (fresh.isNotEmpty) {
        unawaited(_repo.upsertFoods(fresh));
      }

      final merged = [...local, ...fresh];
      merged.sort((a, b) {
        final scoreA = FoodRepository.rankWithHistory(
          a,
          tokens,
          historyIds,
          historyCounts,
          rawQuery,
        );
        final scoreB = FoodRepository.rankWithHistory(
          b,
          tokens,
          historyIds,
          historyCounts,
          rawQuery,
        );
        return FoodRepository.compareFoods(a, b, scoreA, scoreB);
      });

      for (final f in merged) {
        _seenIdsThisQuery.add(dedupeKey(f));
      }

      state = state.copyWith(
        phase: SearchPhase.done,
        results: merged.take(60).toList(),
      );
    } catch (_) {
      if (gen != _generation) return;
      state = state.copyWith(phase: SearchPhase.done, remoteFailed: true);
    }
  }

  /// Normalized name+brand for cross-source duplicate detection
  /// ("Big-Mac" ≡ "Big Mac").
  static String dedupeKey(Food f) =>
      '${Relevance.normalize(f.name)}|${Relevance.normalize(f.brand)}';

  @override
  void dispose() {
    _debounce?.cancel();
    _off.dispose();
    super.dispose();
  }
}
