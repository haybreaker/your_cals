import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories.dart';
import '../../domain/activity.dart';

class ActivitySearchState {
  const ActivitySearchState({
    this.query = '',
    this.searching = false,
    this.results = const [],
  });

  final String query;
  final bool searching;
  final List<Activity> results;

  ActivitySearchState copyWith({
    String? query,
    bool? searching,
    List<Activity>? results,
  }) =>
      ActivitySearchState(
        query: query ?? this.query,
        searching: searching ?? this.searching,
        results: results ?? this.results,
      );
}

/// Local-only activity search (no remote catalog): instant results over
/// the bundled + custom catalog, debounced like food search.
class ActivitySearchController extends StateNotifier<ActivitySearchState> {
  ActivitySearchController(this._repo) : super(const ActivitySearchState());

  final ActivityRepository _repo;

  Timer? _debounce;
  int _generation = 0;

  void reset() {
    _debounce?.cancel();
    _generation++;
    state = const ActivitySearchState();
  }

  void onQueryChanged(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) {
      _generation++;
      state = const ActivitySearchState();
      return;
    }
    state = state.copyWith(query: q, searching: true);
    _debounce = Timer(const Duration(milliseconds: 300), () => _run(q));
  }

  Future<void> _run(String rawQuery) async {
    final gen = ++_generation;
    final results = await _repo.search(rawQuery);
    if (gen != _generation) return;
    // Boost previously-logged activities above never-tried catalog rows
    // (favourites still lead via the repository sort).
    Set<String> historyIds = const {};
    try {
      historyIds = (await _repo.recentActivityIds()).toSet();
    } catch (_) {}
    if (gen != _generation) return;
    // Stable partition matching food-search tiers: favourites first,
    // then previously-logged, then the rest — repository order (token
    // score) preserved within each group.
    final ranked = [
      ...results.where((a) => a.isFavorite),
      ...results.where((a) => !a.isFavorite && historyIds.contains(a.id)),
      ...results.where((a) => !a.isFavorite && !historyIds.contains(a.id)),
    ];
    state = ActivitySearchState(
      query: rawQuery,
      searching: false,
      results: ranked,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
