import 'dart:convert';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

import '../domain/activity.dart';
import '../domain/food.dart';
import '../domain/nutriments.dart';
import '../domain/profile.dart';
import '../domain/weight.dart';
import 'db/database.dart';
import 'search/relevance.dart';
import 'seed/chain_pack.dart';

const _uuid = Uuid();

// ─── Mapping helpers ────────────────────────────────────────────────────────

Food _rowToFood(FoodRow r) => Food(
  id: r.id,
  name: r.name,
  brand: r.brand,
  source: FoodSource.fromName(r.source),
  per100: Nutriments(
    kcal: r.kcal,
    proteinG: r.proteinG,
    carbsG: r.carbsG,
    fatG: r.fatG,
    satFatG: r.satFatG,
    sugarsG: r.sugarsG,
    fiberG: r.fiberG,
    sodiumMg: r.sodiumMg,
    vitAMcg: r.vitAMcg,
    vitB1Mg: r.vitB1Mg,
    vitB2Mg: r.vitB2Mg,
    vitB3Mg: r.vitB3Mg,
    vitB6Mg: r.vitB6Mg,
    vitB12Ug: r.vitB12Ug,
    vitCMg: r.vitCMg,
    folateUg: r.folateUg,
    calciumMg: r.calciumMg,
    ironMg: r.ironMg,
    magnesiumMg: r.magnesiumMg,
    potassiumMg: r.potassiumMg,
    zincMg: r.zincMg,
  ),
  defaultGrams: r.defaultGrams,
  servings: _parseServings(r.servingsJson),
  isFavorite: r.isFavorite,
  barcode: r.barcode,
  liquid: r.liquid,
);

List<ServingOption> _parseServings(String json) {
  try {
    final list = jsonDecode(json) as List;
    return list
        .map((e) => ServingOption.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
  } catch (_) {
    return const [];
  }
}

FoodsCompanion _foodToCompanion(Food f) {
  // Normalized ("oatmeal"/"Oatmeal", "high-protein"/"high protein" all
  // hit); the query side normalizes identically, so rows written by any
  // app version keep matching.
  final searchText = Relevance.normalize('${f.name} ${f.brand}');
  final servingsJson = jsonEncode(f.servings.map((s) => s.toJson()).toList());
  return FoodsCompanion.insert(
    id: f.id,
    name: f.name,
    source: f.source.name,
    searchText: searchText,
    brand: Value(f.brand),
    defaultGrams: Value(f.defaultGrams),
    servingsJson: Value(servingsJson),
    kcal: Value(f.per100.kcal),
    proteinG: Value(f.per100.proteinG),
    carbsG: Value(f.per100.carbsG),
    fatG: Value(f.per100.fatG),
    satFatG: Value(f.per100.satFatG),
    sugarsG: Value(f.per100.sugarsG),
    fiberG: Value(f.per100.fiberG),
    sodiumMg: Value(f.per100.sodiumMg),
    vitAMcg: Value(f.per100.vitAMcg),
    vitB1Mg: Value(f.per100.vitB1Mg),
    vitB2Mg: Value(f.per100.vitB2Mg),
    vitB3Mg: Value(f.per100.vitB3Mg),
    vitB6Mg: Value(f.per100.vitB6Mg),
    vitB12Ug: Value(f.per100.vitB12Ug),
    vitCMg: Value(f.per100.vitCMg),
    folateUg: Value(f.per100.folateUg),
    calciumMg: Value(f.per100.calciumMg),
    ironMg: Value(f.per100.ironMg),
    magnesiumMg: Value(f.per100.magnesiumMg),
    potassiumMg: Value(f.per100.potassiumMg),
    zincMg: Value(f.per100.zincMg),
    liquid: Value(f.liquid),
    barcode: Value(f.barcode),
  );
}

LogEntry _rowToLog(LogEntryRow r) => LogEntry(
  id: r.id,
  day: r.day,
  meal: MealTypeX.fromName(r.meal),
  foodId: r.foodId,
  name: r.name,
  brand: r.brand,
  source: FoodSource.fromName(r.source),
  grams: r.grams,
  unit: r.unit,
  servingCount: r.servingCount,
  servingGrams: r.servingGrams,
  servingLabel: r.servingLabel,
  nutr: Nutriments(
    kcal: r.kcal,
    proteinG: r.proteinG,
    carbsG: r.carbsG,
    fatG: r.fatG,
    satFatG: r.satFatG,
    sugarsG: r.sugarsG,
    fiberG: r.fiberG,
    sodiumMg: r.sodiumMg,
    vitCMg: r.vitCMg,
    calciumMg: r.calciumMg,
    ironMg: r.ironMg,
    potassiumMg: r.potassiumMg,
  ),
  photoPath: r.photoPath,
  createdAt: r.createdAt,
  sortOrder: r.sortOrder,
);

LogEntriesCompanion _logToCompanion(LogEntry e) {
  return LogEntriesCompanion.insert(
    id: e.id,
    day: e.day,
    meal: e.meal.name,
    foodId: e.foodId,
    name: e.name,
    grams: e.grams,
    kcal: e.nutr.kcal,
    proteinG: e.nutr.proteinG,
    carbsG: e.nutr.carbsG,
    fatG: e.nutr.fatG,
    createdAt: e.createdAt,
    unit: Value(e.unit),
    brand: Value(e.brand),
    source: e.source.name,
    satFatG: Value(e.nutr.satFatG),
    sugarsG: Value(e.nutr.sugarsG),
    fiberG: Value(e.nutr.fiberG),
    sodiumMg: Value(e.nutr.sodiumMg),
    vitCMg: Value(e.nutr.vitCMg),
    calciumMg: Value(e.nutr.calciumMg),
    ironMg: Value(e.nutr.ironMg),
    potassiumMg: Value(e.nutr.potassiumMg),
    servingCount: Value(e.servingCount),
    servingGrams: Value(e.servingGrams),
    servingLabel: Value(e.servingLabel),
    sortOrder: Value(e.sortOrder),
    photoPath: Value(e.photoPath),
  );
}

// ─── Food repository ────────────────────────────────────────────────────────

class FoodRepository {
  FoodRepository(this._db);

  final AppDatabase _db;

  /// Tiered rank: exact-recipe > exact match > recipe > favourite >
  /// previously-logged (frequency-weighted) > relevance-ordered rest. Tier
  /// dominates (×10000 — tier-0 ceiling is ~2100, so bands can never
  /// cross); [Relevance.textScore] + deterministic name tiebreaks decide
  /// within a band. Single definition shared by local search and remote
  /// merges.
  ///
  /// When a query exactly names a row, your own recipe still tops the
  /// exact catalog rows (searching "Bolognese" should surface YOUR
  /// recipe first) — hence the extra recipe tier on exact match.
  ///
  /// User custom foods get a small within-tier bonus (+500) so a
  /// corrected clone shadows its OFF source with identical text, while
  /// still losing to favourited/logged/recipe rows (higher tiers).
  /// [rankFood] itself stays source-blind (tested) — the bonus lives
  /// here so pure-relevance unit tests don't break.
  static int rankWithHistory(
    Food f,
    List<String> tokens,
    Set<String> historyIds, [
    Map<String, int> historyCounts = const {},
    String? rawQuery,
  ]) {
    final exact = rawQuery != null && Relevance.isExact(rawQuery, f.name);
    final tier = exact
        ? (f.source == FoodSource.recipe ? 5 : 4)
        : f.source == FoodSource.recipe
        ? 3
        : f.isFavorite
        ? 2
        : historyIds.contains(f.id)
        ? 1
        : 0;
    // Frequency bonus: +20 per log, capped at 25 logs (+500). Max
    // tier-0 score is ~2100, so the ceiling (~2600) stays far below the
    // next tier boundary (10000).
    final freq = tier == 1 ? (historyCounts[f.id] ?? 1).clamp(1, 25) * 20 : 0;
    final customBonus = tier == 0 && f.source == FoodSource.custom ? 500 : 0;
    return tier * 10000 + freq + customBonus + rankFood(f, tokens);
  }

  /// Deterministic ordering: score desc, then shorter/more-specific
  /// names, alphabetical, id. Ties must never look random.
  /// Final tiebreak prefers a user custom copy over catalog rows with
  /// identical score+name — the "fix this product" clone wins.
  static int compareFoods(Food a, Food b, int scoreA, int scoreB) {
    if (scoreA != scoreB) return scoreB.compareTo(scoreA);
    if (a.source != b.source) {
      if (a.source == FoodSource.custom) return -1;
      if (b.source == FoodSource.custom) return 1;
    }
    return Relevance.compareNames(a.name, a.id, b.name, b.id);
  }

  Future<List<Food>> search(
    String query, {
    int limit = 40,
    bool includeHistoryBoost = true,
  }) async {
    // Pure-relevance recall in two phases:
    // Q1 (precision) requires EVERY query token (or a stem) to hit, so
    // branded multi-word queries ("musashi protein") always include their
    // exact rows even when the OR set has thousands of partial hits.
    // Q2 (recall) is the broad OR fill and only runs when Q1 is thin, so
    // an extra word ("loaf" in "white toast bread loaf") can never zero
    // results — it just falls back to the partial matches.
    final tokens = Relevance.tokenize(query);
    if (tokens.isEmpty) return [];

    // Per-token OR groups (token + stems), capped at 6 tokens to keep the
    // LIKE fan-out cheap. Flattened = the old OR candidate set.
    final groups = <List<String>>[];
    for (final t in tokens.take(6)) {
      final g = <String>[t];
      for (final s in Relevance.stems(t)) {
        if (!g.contains(s)) g.add(s);
      }
      groups.add(g);
    }
    final variants = groups.expand((g) => g).toSet().toList();
    if (variants.isEmpty) return [];

    Expression<bool> groupOr($FoodsTable f, List<String> g) =>
        g.map((t) => f.searchText.contains(t)).reduce((a, b) => a | b);
    Expression<bool> tokenOr($FoodsTable f) =>
        variants.map((t) => f.searchText.contains(t)).reduce((a, b) => a | b);
    Expression<bool> tokenAnd($FoodsTable f) =>
        groups.map((g) => groupOr(f, g)).reduce((a, b) => a & b);

    // Recently-logged ids + log counts for the history tier (cheap
    // GROUP BY; empty on error rather than failing the whole search).
    Set<String> historyIds = const {};
    Map<String, int> historyCounts = const {};
    if (includeHistoryBoost) {
      try {
        historyCounts = await recentFoodCounts(limit: 300);
        historyIds = historyCounts.keys.toSet();
      } catch (_) {}
    }

    final byId = <String, FoodRow>{};

    // Previously-logged matches get their OWN query: the catalog LIMITs
    // below run before in-memory ranking, so with a ~90k catalog a
    // history item ("Garlic Bread / Coles") can be cut off by hundreds of
    // never-tried rows and never reach the tier sort.
    if (historyIds.isNotEmpty) {
      final historySelect = _db.select(_db.foods)
        ..where((f) => f.id.isIn(historyIds) & tokenOr(f));
      historySelect.limit(30);
      for (final r in await historySelect.get()) {
        byId[r.id] = r;
      }
    }

    // Q1 — precision: every token group must hit. Ordered favourite-first
    // then shortest (most specific) name so an exact branded row
    // ("High Protein | MUSASHI") survives the LIMIT ahead of long generic
    // descriptions ("Bar, high protein, chocolate flavour …").
    final andSelect = _db.select(_db.foods)..where(tokenAnd);
    andSelect
      ..orderBy([
        (f) => OrderingTerm(expression: f.isFavorite, mode: OrderingMode.desc),
        (f) => OrderingTerm(expression: f.searchText.length, mode: OrderingMode.asc),
      ])
      ..limit(200);
    for (final r in await andSelect.get()) {
      byId.putIfAbsent(r.id, () => r);
    }

    // Q2 — recall fill, only when precision was thin. Same ordering so
    // short specific names still beat long partials.
    if (byId.length < limit) {
      final orSelect = _db.select(_db.foods)..where(tokenOr);
      orSelect
        ..orderBy([
          (f) =>
              OrderingTerm(expression: f.isFavorite, mode: OrderingMode.desc),
          (f) => OrderingTerm(
            expression: f.searchText.length,
            mode: OrderingMode.asc,
          ),
        ])
        ..limit(400);
      for (final r in await orSelect.get()) {
        byId.putIfAbsent(r.id, () => r);
      }
    }

    // User recipes must never be buried: the catalog LIMIT above runs
    // before in-memory ranking, so a recipe matching "bolognese" can be
    // cut off by 40+ OFF/chain rows. Fetch matching recipes separately
    // and merge them in — ranking (recipe first) keeps them on top.
    final recipeSelect = _db.select(_db.foods)
      ..where((f) => f.source.equals(FoodSource.recipe.name) & tokenOr(f));
    recipeSelect.limit(20);
    for (final r in await recipeSelect.get()) {
      byId[r.id] = r;
    }

    final results = byId.values.map(_rowToFood).toList()
      ..sort(
        (a, b) => compareFoods(
          a,
          b,
          rankWithHistory(a, tokens, historyIds, historyCounts, query),
          rankWithHistory(b, tokens, historyIds, historyCounts, query),
        ),
      );
    return results.take(limit).toList();
  }

  /// Ids of recently logged foods, newest first. Used to boost history
  /// matches to the top of search results.
  Future<List<String>> recentFoodIds({int limit = 200}) async {
    final rows = await _db
        .customSelect(
          'SELECT food_id, MAX(created_at) AS latest FROM log_entries '
          'GROUP BY food_id ORDER BY latest DESC LIMIT ?',
          variables: [Variable(limit)],
        )
        .get();
    return rows.map((r) => r.data['food_id'] as String).toList();
  }

  /// Log counts per food (id → times logged), newest first. Feeds the
  /// frequency bonus so staples outrank one-offs within the history tier.
  Future<Map<String, int>> recentFoodCounts({int limit = 300}) async {
    final rows = await _db
        .customSelect(
          'SELECT food_id, COUNT(*) AS n, MAX(created_at) AS latest '
          'FROM log_entries GROUP BY food_id ORDER BY latest DESC LIMIT ?',
          variables: [Variable(limit)],
        )
        .get();
    return {
      for (final r in rows)
        r.data['food_id'] as String: (r.data['n'] as int? ?? 1),
    };
  }

  /// Higher score = better. Pure function (tested). Pure relevance:
  /// [Relevance.textScore] decides, plus small favourite/brand bonuses.
  /// Source trust is deliberately NOT scored — a FSANZ generic must never
  /// outrank a branded OFF/chain row it matches worse ("musashi protein"
  /// → Musashi OFF, not FSANZ protein water; "pink lady apples" → the
  /// FSANZ pink-lady row wins on text alone).
  static int rankFood(Food f, List<String> tokens) {
    var score = Relevance.textScore(tokens, f.name, f.brand);
    if (f.isFavorite) score += 50;
    if (f.brand.isNotEmpty) score += 3;
    return score;
  }

  Future<Food?> byId(String id) async {
    final row = await (_db.select(
      _db.foods,
    )..where((f) => f.id.equals(id))).getSingleOrNull();
    return row == null ? null : _rowToFood(row);
  }

  /// Exact barcode lookup for the library quick-filter (indexed column).
  /// Bypasses naming entirely — whoever named the row doesn't matter.
  ///
  /// A user-corrected custom copy shares the OFF barcode by design
  /// (clone flow). When several rows share a barcode, the custom copy
  /// wins so the fix actually shadows the catalog row; otherwise the
  /// oldest row wins deterministically.
  Future<Food?> byBarcode(String code) async {
    final c = code.trim();
    if (c.isEmpty) return null;
    final rows = await (_db.select(
      _db.foods,
    )..where((f) => f.barcode.equals(c))).get();
    if (rows.isEmpty) return null;
    if (rows.length == 1) return _rowToFood(rows.single);
    FoodRow? custom;
    for (final r in rows) {
      if (r.source == FoodSource.custom.name) {
        custom ??= r;
        // Prefer favourited customs, then shortest (most specific) name.
        if (r.isFavorite && !(custom.isFavorite)) custom = r;
      }
    }
    return _rowToFood(custom ?? rows.first);
  }

  /// All rows sharing a barcode (OFF + user custom copies). Used by the
  /// fix-product UI to warn when a custom override already exists.
  Future<List<Food>> byBarcodeAll(String code) async {
    final c = code.trim();
    if (c.isEmpty) return [];
    final rows = await (_db.select(
      _db.foods,
    )..where((f) => f.barcode.equals(c))).get();
    return rows.map(_rowToFood).toList();
  }

  /// Batch fetch preserving caller order; missing ids are skipped.
  Future<List<Food>> byIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final rows = await (_db.select(
      _db.foods,
    )..where((f) => f.id.isIn(ids))).get();
    final map = {for (final r in rows) r.id: _rowToFood(r)};
    return [
      for (final id in ids)
        if (map[id] != null) map[id]!,
    ];
  }

  Future<void> upsertFood(Food f) =>
      _db.into(_db.foods).insertOnConflictUpdate(_foodToCompanion(f));

  Future<void> upsertFoods(List<Food> foods) async {
    await _db.batch((b) {
      for (final f in foods) {
        b.insert(
          _db.foods,
          _foodToCompanion(f),
          onConflict: DoUpdate(
            (_) => _foodToCompanion(f),
            target: [_db.foods.id],
          ),
        );
      }
    });
  }

  /// Returns the subset of [ids] that already exist in the foods table.
  Future<Set<String>> idsFor(Set<String> ids) async {
    if (ids.isEmpty) return {};
    final found = <String>{};
    // Chunk to keep the IN clause within SQLite's variable limit.
    final list = ids.toList();
    for (var i = 0; i < list.length; i += 500) {
      final chunk = list.sublist(
        i,
        i + 500 > list.length ? list.length : i + 500,
      );
      final rows = await (_db.select(
        _db.foods,
      )..where((f) => f.id.isIn(chunk))).get();
      found.addAll(rows.map((r) => r.id));
    }
    return found;
  }

  Future<void> setFavorite(String id, bool fav) =>
      (_db.update(_db.foods)..where((f) => f.id.equals(id))).write(
        FoodsCompanion(isFavorite: Value(fav)),
      );

  Future<List<Food>> recents({int limit = 20}) async {
    final rows = await _db
        .customSelect(
          'SELECT DISTINCT food_id FROM log_entries ORDER BY created_at DESC LIMIT ?',
          variables: [Variable(limit)],
        )
        .get();
    final ids = rows.map((r) => r.data['food_id'] as String).toList();
    if (ids.isEmpty) return [];
    final foods = await (_db.select(
      _db.foods,
    )..where((f) => f.id.isIn(ids))).get();
    final map = {for (final r in foods.map(_rowToFood)) r.id: r};
    return [
      for (final id in ids)
        if (map[id] != null) map[id]!,
    ];
  }

  Stream<List<Food>> watchFavorites() {
    final q = _db.select(_db.foods)..where((f) => f.isFavorite.equals(true));
    return q.watch().map((rows) => rows.map(_rowToFood).toList());
  }
}

// ─── Diary repository ───────────────────────────────────────────────────────

class DiaryRepository {
  DiaryRepository(this._db);

  final AppDatabase _db;

  Stream<List<LogEntry>> watchDay(String day) {
    final q = _db.select(_db.logEntries)
      ..where((l) => l.day.equals(day))
      ..orderBy([
        (l) => OrderingTerm.asc(l.meal),
        (l) => OrderingTerm.asc(l.sortOrder),
        (l) => OrderingTerm.asc(l.createdAt),
      ]);
    return q.watch().map((rows) => rows.map(_rowToLog).toList());
  }

  /// Max sort order currently used within (day, meal), or -1 when empty.
  Future<int> _maxSortOrder(String day, MealType meal) async {
    final row =
        await (_db.selectOnly(_db.logEntries)
              ..addColumns([_db.logEntries.sortOrder.max()])
              ..where(
                _db.logEntries.day.equals(day) &
                    _db.logEntries.meal.equals(meal.name),
              ))
            .getSingle();
    return row.read(_db.logEntries.sortOrder.max()) ?? -1;
  }

  Future<LogEntry> add({
    required String day,
    required MealType meal,
    required Food food,
    required double grams,
    String? photoPath,
    String unit = 'g',
    double? servingCount,
    double? servingGrams,
    String? servingLabel,
  }) async {
    final sortOrder = await _maxSortOrder(day, meal) + 1;
    final entry = LogEntry(
      id: _uuid.v4(),
      day: day,
      meal: meal,
      foodId: food.id,
      name: food.name,
      brand: food.brand,
      source: food.source,
      grams: grams,
      unit: unit,
      servingCount: servingCount,
      servingGrams: servingGrams,
      servingLabel: servingLabel,
      nutr: food.per100.forGrams(grams),
      photoPath: photoPath,
      createdAt: DateTime.now(),
      sortOrder: sortOrder,
    );
    await _db.into(_db.logEntries).insert(_logToCompanion(entry));
    return entry;
  }

  /// Re-insert a snapshot (undo path). Appends at the end of its section
  /// so it can't collide with sort orders assigned since deletion.
  Future<void> restore(LogEntry entry) async {
    final sortOrder = await _maxSortOrder(entry.day, entry.meal) + 1;
    await _db
        .into(_db.logEntries)
        .insert(_logToCompanion(entry.copyWith(sortOrder: sortOrder)));
  }

  /// Update an entry's portion in place: resolved grams, unit, serving
  /// metadata and meal, rescaling the snapshotted nutrition.
  ///
  /// [entry.nutr] holds entry TOTALS (not per-100), so scaling is a simple
  /// ratio multiply — never forGrams() here (that would divide by 100 again).
  Future<void> updatePortion(
    LogEntry entry, {
    required double grams,
    String? unit,
    double? servingCount,
    double? servingGrams,
    String? servingLabel,
    MealType? meal,
  }) {
    final ratio = grams / (entry.grams == 0 ? 1 : entry.grams);
    final n = entry.nutr;
    final scaled = Nutriments(
      kcal: n.kcal * ratio,
      proteinG: n.proteinG * ratio,
      carbsG: n.carbsG * ratio,
      fatG: n.fatG * ratio,
      satFatG: n.satFatG * ratio,
      sugarsG: n.sugarsG * ratio,
      fiberG: n.fiberG * ratio,
      sodiumMg: n.sodiumMg * ratio,
      vitCMg: n.vitCMg * ratio,
      calciumMg: n.calciumMg * ratio,
      ironMg: n.ironMg * ratio,
      potassiumMg: n.potassiumMg * ratio,
    );
    return (_db.update(
      _db.logEntries,
    )..where((l) => l.id.equals(entry.id))).write(
      LogEntriesCompanion(
        grams: Value(grams),
        unit: Value(unit ?? entry.unit),
        kcal: Value(scaled.kcal),
        proteinG: Value(scaled.proteinG),
        carbsG: Value(scaled.carbsG),
        fatG: Value(scaled.fatG),
        satFatG: Value(scaled.satFatG),
        sugarsG: Value(scaled.sugarsG),
        fiberG: Value(scaled.fiberG),
        sodiumMg: Value(scaled.sodiumMg),
        vitCMg: Value(scaled.vitCMg),
        calciumMg: Value(scaled.calciumMg),
        ironMg: Value(scaled.ironMg),
        potassiumMg: Value(scaled.potassiumMg),
        servingCount: Value(servingCount),
        servingGrams: Value(servingGrams),
        servingLabel: Value(servingLabel),
        meal: Value.absentIfNull(meal?.name),
      ),
    );
  }

  /// Move [entry] to [newIndex] within [meal]'s section on its day,
  /// compacting sibling sort orders. Cross-section moves are supported:
  /// pass the target section's [meal].
  Future<void> reorder(
    LogEntry entry, {
    MealType? meal,
    required int newIndex,
  }) async {
    final targetMeal = meal ?? entry.meal;
    final rows =
        await (_db.select(_db.logEntries)
              ..where(
                (l) => l.day.equals(entry.day) & l.meal.equals(targetMeal.name),
              )
              ..orderBy([
                (l) => OrderingTerm.asc(l.sortOrder),
                (l) => OrderingTerm.asc(l.createdAt),
              ]))
            .get();
    final siblings = rows.where((r) => r.id != entry.id).toList();
    final clamped = newIndex.clamp(0, siblings.length);
    // Build the final order: siblings with the moved entry spliced in.
    final order = <String>[];
    for (var i = 0; i < siblings.length; i++) {
      if (i == clamped) order.add(entry.id);
      order.add(siblings[i].id);
    }
    if (clamped >= siblings.length) order.add(entry.id);

    // If the entry moved sections, it needs its meal rewritten too.
    if (targetMeal != entry.meal) {
      await (_db.update(_db.logEntries)..where((l) => l.id.equals(entry.id)))
          .write(LogEntriesCompanion(meal: Value(targetMeal.name)));
    }
    await _db.batch((b) {
      for (var i = 0; i < order.length; i++) {
        b.update(
          _db.logEntries,
          LogEntriesCompanion(sortOrder: Value(i)),
          where: (tbl) => tbl.id.equals(order[i]),
        );
      }
    });
  }

  /// Copy entries onto [targetDay] (e.g. "copy to today"), preserving meals.
  /// Each copy gets a fresh id, appends at the end of its section and keeps
  /// serving metadata + photo reference.
  Future<List<LogEntry>> copyToDay(
    List<LogEntry> entries,
    String targetDay, {
    MealType? mealOverride,
  }) async {
    final copies = <LogEntry>[];
    // Group by target meal so we only query max sort order once per section.
    final byMeal = <MealType, List<LogEntry>>{};
    for (final e in entries) {
      final m = mealOverride ?? e.meal;
      byMeal.putIfAbsent(m, () => []).add(e);
    }
    for (final m in byMeal.keys) {
      var next = await _maxSortOrder(targetDay, m) + 1;
      for (final e in byMeal[m]!) {
        final copy = LogEntry(
          id: _uuid.v4(),
          day: targetDay,
          meal: m,
          foodId: e.foodId,
          name: e.name,
          brand: e.brand,
          source: e.source,
          grams: e.grams,
          unit: e.unit,
          servingCount: e.servingCount,
          servingGrams: e.servingGrams,
          servingLabel: e.servingLabel,
          nutr: e.nutr,
          photoPath: e.photoPath,
          createdAt: DateTime.now(),
          sortOrder: next++,
        );
        await _db.into(_db.logEntries).insert(_logToCompanion(copy));
        copies.add(copy);
      }
    }
    return copies;
  }

  /// Delete many entries at once (multi-select).
  Future<void> deleteMany(Iterable<String> ids) async {
    final list = ids.toList();
    if (list.isEmpty) return;
    await (_db.delete(_db.logEntries)..where((l) => l.id.isIn(list))).go();
  }

  /// Rescale serving count on an entry (context-menu stepper), rewriting
  /// grams + nutrition and keeping serving metadata consistent.
  Future<void> setServingCount(LogEntry entry, double count) async {
    final per = entry.servingGrams;
    if (per == null || per <= 0) return;
    final grams = count * per;
    await updatePortion(
      entry,
      grams: grams,
      unit: 'serving',
      servingCount: count,
      servingGrams: per,
      servingLabel: entry.servingLabel,
    );
  }

  Future<void> updateGrams(LogEntry entry, double newGrams) {
    // entry.nutr holds TOTALS — scale by ratio, not forGrams().
    final ratio = newGrams / (entry.grams == 0 ? 1 : entry.grams);
    final n = entry.nutr;
    final scaled = Nutriments(
      kcal: n.kcal * ratio,
      proteinG: n.proteinG * ratio,
      carbsG: n.carbsG * ratio,
      fatG: n.fatG * ratio,
      satFatG: n.satFatG * ratio,
      sugarsG: n.sugarsG * ratio,
      fiberG: n.fiberG * ratio,
      sodiumMg: n.sodiumMg * ratio,
    );
    return (_db.update(
      _db.logEntries,
    )..where((l) => l.id.equals(entry.id))).write(
      LogEntriesCompanion(
        grams: Value(newGrams),
        kcal: Value(scaled.kcal),
        proteinG: Value(scaled.proteinG),
        carbsG: Value(scaled.carbsG),
        fatG: Value(scaled.fatG),
        satFatG: Value(scaled.satFatG),
        sugarsG: Value(scaled.sugarsG),
        fiberG: Value(scaled.fiberG),
        sodiumMg: Value(scaled.sodiumMg),
      ),
    );
  }

  Future<void> updateMeal(String id, MealType meal) =>
      (_db.update(_db.logEntries)..where((l) => l.id.equals(id))).write(
        LogEntriesCompanion(meal: Value(meal.name)),
      );

  Future<void> delete(String id) =>
      (_db.delete(_db.logEntries)..where((l) => l.id.equals(id))).go();
}

// ─── Recipe repository ──────────────────────────────────────────────────────

class RecipeRepository {
  RecipeRepository(this._db);

  final AppDatabase _db;

  Stream<List<Recipe>> watchAll() {
    final q = _db.select(_db.recipes)
      ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    return q.watch().asyncMap((rows) async {
      final out = <Recipe>[];
      for (final r in rows) {
        final items = await (_db.select(
          _db.recipeItems,
        )..where((i) => i.recipeId.equals(r.id))).get();
        out.add(await _withLiveNested(_recipeFromRows(r, items), {}));
      }
      return out;
    });
  }

  static Recipe _recipeFromRows(RecipeRow r, List<RecipeItem> items) => Recipe(
    id: r.id,
    name: r.name,
    servings: r.servings,
    createdAt: r.createdAt,
    ingredients: items
        .map(
          (i) => RecipeIngredient(
            foodId: i.foodId,
            name: i.name,
            brand: i.brand,
            grams: i.grams,
            per100: Nutriments(
              kcal: i.kcal,
              proteinG: i.proteinG,
              carbsG: i.carbsG,
              fatG: i.fatG,
            ),
            qty: i.qty == 0 ? i.grams : i.qty,
            unit: i.unit.isEmpty ? 'g' : i.unit,
          ),
        )
        .toList(),
  );

  Future<Recipe?> _loadSnapshot(String recipeId) async {
    final row = await (_db.select(
      _db.recipes,
    )..where((r) => r.id.equals(recipeId))).getSingleOrNull();
    if (row == null) return null;
    final items = await (_db.select(
      _db.recipeItems,
    )..where((i) => i.recipeId.equals(recipeId))).get();
    return _recipeFromRows(row, items);
  }

  Future<Recipe?> byId(String recipeId) async {
    final snapshot = await _loadSnapshot(recipeId);
    if (snapshot == null) return null;
    return _withLiveNested(snapshot, {});
  }

  /// Replaces nested recipe ingredients' snapshot per100 with the child's
  /// current live per100 (recursive, cycle-safe). Deleted children keep
  /// their snapshot so parents never break.
  Future<Recipe> _withLiveNested(Recipe recipe, Set<String> visited) async {
    if (recipe.ingredients.isEmpty) return recipe;
    final chain = {...visited, recipe.id};
    var changed = false;
    final resolved = <RecipeIngredient>[];
    for (final ing in recipe.ingredients) {
      final refId = ing.recipeRefId;
      if (refId == null || chain.contains(refId)) {
        resolved.add(ing);
        continue;
      }
      final childSnapshot = await _loadSnapshot(refId);
      if (childSnapshot == null) {
        resolved.add(ing);
        continue;
      }
      final liveChild = await _withLiveNested(childSnapshot, chain);
      final livePer100 = _per100OfRecipe(liveChild);
      if (livePer100 == null) {
        resolved.add(ing);
        continue;
      }
      changed = true;
      resolved.add(
        RecipeIngredient(
          foodId: ing.foodId,
          name: liveChild.name,
          brand: ing.brand,
          grams: ing.grams,
          per100: livePer100,
          qty: ing.qty,
          unit: ing.unit,
        ),
      );
    }
    if (!changed) return recipe;
    return Recipe(
      id: recipe.id,
      name: recipe.name,
      servings: recipe.servings,
      ingredients: resolved,
      createdAt: recipe.createdAt,
    );
  }

  /// Current per-100 of a (possibly nested-resolved) recipe, or null when
  /// it has no gram weight. NOTE: [total] holds TOTALS, so per-100 is
  /// total*100/grams (not forGrams, which expects a per-100 input).
  static Nutriments? _per100OfRecipe(Recipe recipe) {
    final totalGrams = recipe.ingredients.fold<double>(
      0,
      (a, i) => a + i.grams,
    );
    if (totalGrams <= 0) return null;
    final total = Nutriments.sum(recipe.ingredients.map((i) => i.nutr));
    final f = 100 / totalGrams;
    return Nutriments(
      kcal: total.kcal * f,
      proteinG: total.proteinG * f,
      carbsG: total.carbsG * f,
      fatG: total.fatG * f,
      satFatG: total.satFatG * f,
      sugarsG: total.sugarsG * f,
      fiberG: total.fiberG * f,
      sodiumMg: total.sodiumMg * f,
    );
  }

  /// All recipe ids transitively referenced by [recipeId] (cycle-safe).
  Future<Set<String>> _collectTransitiveRecipeIds(
    String recipeId,
    Set<String> visited,
  ) async {
    if (!visited.add(recipeId)) return {};
    final snapshot = await _loadSnapshot(recipeId);
    if (snapshot == null) return {};
    final out = <String>{};
    for (final ing in snapshot.ingredients) {
      final refId = ing.recipeRefId;
      if (refId == null) continue;
      out.add(refId);
      out.addAll(await _collectTransitiveRecipeIds(refId, visited));
    }
    return out;
  }

  /// Returns an error message when saving [ingredients] under [existingId]
  /// would create a reference loop, else null.
  Future<String?> validateNoCycle({
    required String? existingId,
    required List<RecipeIngredient> ingredients,
  }) async {
    if (existingId == null) return null;
    for (final ing in ingredients) {
      final refId = ing.recipeRefId;
      if (refId == null) continue;
      if (refId == existingId) return 'A recipe can’t include itself.';
      final transitive = await _collectTransitiveRecipeIds(refId, {});
      if (transitive.contains(existingId)) {
        return 'That would create a loop — a recipe can’t include itself indirectly.';
      }
    }
    return null;
  }

  /// A recipe as a loggable Food: per-100g values scaled from per-serving.
  /// Sync core so pickers can render recipes without per-row futures.
  static Food? recipeToFood(Recipe recipe) {
    if (recipe.ingredients.isEmpty) return null;
    final double gps = recipe.gramsPerServing <= 0
        ? 100.0
        : recipe.gramsPerServing;
    final double per100factor = 100 / gps;
    final ps = recipe.perServing;
    return Food(
      id: 'recipe:${recipe.id}',
      name: recipe.name,
      source: FoodSource.recipe,
      per100: Nutriments(
        kcal: ps.kcal * per100factor,
        proteinG: ps.proteinG * per100factor,
        carbsG: ps.carbsG * per100factor,
        fatG: ps.fatG * per100factor,
      ),
      defaultGrams: gps,
      servings: [ServingOption(label: '1 serving', grams: gps)],
    );
  }

  /// Async wrapper resolving the recipe first (live nested totals).
  Future<Food?> recipeAsFood(String recipeId) async {
    final recipe = await byId(recipeId);
    if (recipe == null) return null;
    return recipeToFood(recipe);
  }

  Future<String> save({
    required String? existingId,
    required String name,
    required int servings,
    required List<RecipeIngredient> ingredients,
  }) async {
    final cycleError = await validateNoCycle(
      existingId: existingId,
      ingredients: ingredients,
    );
    if (cycleError != null) throw StateError(cycleError);
    final id = existingId ?? _uuid.v4();
    await _db.transaction(() async {
      if (existingId == null) {
        await _db
            .into(_db.recipes)
            .insert(
              RecipesCompanion.insert(
                id: id,
                name: name,
                servings: Value(servings),
                createdAt: DateTime.now(),
              ),
            );
      } else {
        await (_db.update(_db.recipes)..where((r) => r.id.equals(id))).write(
          RecipesCompanion(name: Value(name), servings: Value(servings)),
        );
      }
      await (_db.delete(
        _db.recipeItems,
      )..where((i) => i.recipeId.equals(id))).go();
      for (final i in ingredients) {
        await _db
            .into(_db.recipeItems)
            .insert(
              RecipeItemsCompanion.insert(
                id: _uuid.v4(),
                recipeId: id,
                foodId: i.foodId,
                name: i.name,
                grams: i.grams,
                brand: Value(i.brand),
                kcal: Value(i.per100.kcal),
                proteinG: Value(i.per100.proteinG),
                carbsG: Value(i.per100.carbsG),
                fatG: Value(i.per100.fatG),
                qty: Value(i.qty),
                unit: Value(i.unit),
              ),
            );
      }
    });
    await _syncRecipeFoodRow(id);
    await _resyncParentsRecursive(id, {});
    return id;
  }

  /// Recipes live in the foods table too so search/recents find them.
  Future<void> _syncRecipeFoodRow(String recipeId) async {
    final food = await recipeAsFood(recipeId);
    if (food == null) return;
    await _db.into(_db.foods).insertOnConflictUpdate(_foodToCompanion(food));
  }

  /// After a child recipe changes, refresh every ancestor's foods row so
  /// search tiles and portion math never serve stale parent macros.
  Future<void> _resyncParentsRecursive(
    String childId,
    Set<String> visited,
  ) async {
    if (!visited.add(childId)) return;
    final parentRows = await (_db.select(
      _db.recipeItems,
    )..where((i) => i.foodId.equals('recipe:$childId'))).get();
    final parentIds = parentRows.map((r) => r.recipeId).toSet();
    for (final pid in parentIds) {
      await _syncRecipeFoodRow(pid);
      await _resyncParentsRecursive(pid, visited);
    }
  }

  Future<void> delete(String id) async {
    await (_db.delete(
      _db.recipeItems,
    )..where((i) => i.recipeId.equals(id))).go();
    await (_db.delete(_db.recipes)..where((r) => r.id.equals(id))).go();
    await (_db.delete(_db.foods)..where((f) => f.id.equals('recipe:$id'))).go();
  }
}

// ─── Profile repository ─────────────────────────────────────────────────────

class ProfileRepository {
  ProfileRepository(this._db);

  final AppDatabase _db;

  Stream<Profile?> watchProfile() {
    return (_db.select(_db.profiles)..where((p) => p.id.equals(1)))
        .watchSingleOrNull()
        .map((row) => row == null ? null : _mapProfile(row));
  }

  static Profile _mapProfile(ProfileRow r) => Profile(
    name: r.name,
    sex: r.sex == 'female' ? Sex.female : Sex.male,
    ageYears: r.ageYears,
    heightCm: r.heightCm,
    weightKg: r.weightKg,
    activity: ActivityLevel.values.firstWhere(
      (a) => a.name == r.activity,
      orElse: () => ActivityLevel.light,
    ),
    goal: GoalType.values.firstWhere(
      (g) => g.name == r.goal,
      orElse: () => GoalType.maintain,
    ),
    weeklyRateKg: r.weeklyRateKg,
    customKcalTarget: r.customKcalTarget,
    proteinPct: r.proteinPct,
    carbsPct: r.carbsPct,
    fatPct: r.fatPct,
  );

  Future<void> save(Profile p, {bool onboarded = true}) {
    return _db
        .into(_db.profiles)
        .insertOnConflictUpdate(
          ProfilesCompanion.insert(
            ageYears: p.ageYears,
            heightCm: p.heightCm,
            weightKg: p.weightKg,
            id: const Value(1),
            name: Value(p.name),
            sex: p.sex.name,
            activity: p.activity.name,
            goal: p.goal.name,
            weeklyRateKg: Value(p.weeklyRateKg),
            customKcalTarget: Value(p.customKcalTarget),
            proteinPct: Value(p.proteinPct),
            carbsPct: Value(p.carbsPct),
            fatPct: Value(p.fatPct),
            onboarded: Value(onboarded),
          ),
        );
  }
}

// ─── Settings repository ────────────────────────────────────────────────────

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  Future<String?> get(String key) async {
    final row = await (_db.select(
      _db.settings,
    )..where((s) => s.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> set(String key, String value) => _db
      .into(_db.settings)
      .insertOnConflictUpdate(SettingsCompanion.insert(key: key, value: value));
}

// ─── Seed import ────────────────────────────────────────────────────────────

const String kSeedVersion = '6';

class SeedImporter {
  SeedImporter(this._repo, this._settings, {this.onProgress});

  final FoodRepository _repo;
  final SettingsRepository _settings;

  /// (stageLabel, done, total) — chunked so the UI can show live counts.
  final void Function(String stage, int done, int total)? onProgress;

  Future<bool> needsImport() async =>
      await _settings.get('seed_version') != kSeedVersion;

  Future<int> importIfNeeded() async {
    if (!await needsImport()) return 0;
    var count = await importChainPack();
    count += await importBundledJson();
    count += await importOffCatalog();
    await _settings.set('seed_version', kSeedVersion);
    return count;
  }

  /// The big one: full OFF AU/NZ product catalog (~90k items).
  Future<int> importOffCatalog() async {
    final raw = await rootBundle.loadString('assets/seed/catalog_off.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final foods = list.map(_foodFromCompact).toList();
    await _upsertChunked(
      foods,
      chunk: 800,
      stage: 'Open Food Facts catalog',
      onProgress: onProgress,
    );
    return foods.length;
  }

  Future<int> importBundledJson() async {
    final raw = await rootBundle.loadString('assets/seed/seed_foods.json');
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    final foods = list.map(_foodFromCompact).toList();
    await _upsertChunked(foods);
    return foods.length;
  }

  Future<int> importChainPack() async {
    final foods = kChainPack.map(_foodFromCompact).toList();
    await _upsertChunked(foods);
    return foods.length;
  }

  /// Compact seed schema:
  /// {i,n,b,s,k,p,c,f,sf,sg,fb,na,dg,sv:[{l,g}],bc?,lq?,va,b1,b2,b3,b6,w12,vc,fu,ca,fe,mg,k,zn}
  static Food _foodFromCompact(Map<String, dynamic> j) {
    double d(String key, [double fallback = 0]) =>
        (j[key] as num?)?.toDouble() ?? fallback;
    final sv = (j['sv'] as List?) ?? const [];
    return Food(
      id: j['i'] as String,
      name: j['n'] as String,
      brand: (j['b'] as String?) ?? '',
      source: FoodSource.fromName(j['s'] as String?),
      per100: Nutriments(
        kcal: d('k'),
        proteinG: d('p'),
        carbsG: d('c'),
        fatG: d('f'),
        satFatG: d('sf'),
        sugarsG: d('sg'),
        fiberG: d('fb'),
        sodiumMg: d('na'),
        vitAMcg: d('va'),
        vitB1Mg: d('b1'),
        vitB2Mg: d('b2'),
        vitB3Mg: d('b3'),
        vitB6Mg: d('b6'),
        vitB12Ug: d('w12'),
        vitCMg: d('vc'),
        folateUg: d('fu'),
        calciumMg: d('ca'),
        ironMg: d('fe'),
        magnesiumMg: d('mg'),
        potassiumMg: d('k2'),
        zincMg: d('zn'),
      ),
      defaultGrams: d('dg', 100),
      servings: sv.map((e) {
        final m = (e as Map).cast<String, dynamic>();
        return ServingOption(
          label: m['l'] as String,
          grams: (m['g'] as num).toDouble(),
        );
      }).toList(),
      barcode: j['bc'] as String?,
      liquid: j['lq'] == true,
    );
  }

  Future<void> _upsertChunked(
    List<Food> foods, {
    int chunk = 300,
    String stage = '',
    void Function(String, int, int)? onProgress,
  }) async {
    for (var i = 0; i < foods.length; i += chunk) {
      await _repo.upsertFoods(
        foods.sublist(i, i + chunk > foods.length ? foods.length : i + chunk),
      );
      onProgress?.call(stage, math.min(i + chunk, foods.length), foods.length);
      // Yield to the platform so the splash keeps animating.
      await Future<void>.delayed(Duration.zero);
    }
  }
}

// ─── OFF catalog background updater ─────────────────────────────────────────

/// Manual updater for the Open Food Facts AU/NZ catalog.
/// Fetches latest products from the OFF API and upserts into local DB.
class OffCatalogUpdater {
  OffCatalogUpdater(this._repo, this._settings, {this.onProgress});

  final FoodRepository _repo;
  final SettingsRepository _settings;

  /// (stageLabel, done, total)
  final void Function(String stage, int done, int total)? onProgress;

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {'User-Agent': 'YourCals/0.1 (personal calorie tracker)'},
    ),
  );

  static const _pageSize = 1000;
  static const _settingsKey = 'off_catalog_last_update';

  Future<DateTime?> get lastUpdate async {
    final ts = await _settings.get(_settingsKey);
    return ts != null ? DateTime.tryParse(ts) : null;
  }

  /// Result of a catalog update: how many rows were genuinely new
  /// vs already present (updated in place).
  Future<OffUpdateResult> update({
    void Function(String stage, int done, int total)? onProgress,
  }) async {
    var page = 1;
    var totalCount = 0;
    final allFoods = <Food>[];

    try {
      while (true) {
        onProgress?.call('Fetching OFF catalog', totalCount, 0);

        final res = await _dio.get<Map<String, dynamic>>(
          'https://world.openfoodfacts.org/api/v2/search',
          queryParameters: {
            'countries_tags': 'en:australia,en:new-zealand',
            'fields': 'code,product_name,brands,nutriments,serving_quantity',
            'page_size': '$_pageSize',
            'page': '$page',
          },
        );

        final data = res.data;
        if (data == null) break;

        final products = (data['products'] as List?) ?? const [];
        if (products.isEmpty) break;

        for (final p in products) {
          final food = _parseProduct((p as Map).cast<String, dynamic>());
          if (food != null) allFoods.add(food);
        }

        totalCount += products.length;
        onProgress?.call('Fetching OFF catalog', totalCount, totalCount);

        // Less than a full page means we've reached the end
        if (products.length < _pageSize) break;
        page++;

        // Rate limit: OFF allows ~10 req/min
        await Future<void>.delayed(const Duration(milliseconds: 1200));
      }

      // Diff against existing rows so "updated" means content actually
      // changed — previously every fetched row was counted as updated,
      // which is why repeat runs always reported the same number.
      final existingById = {
        for (final f in await _repo.byIds(allFoods.map((f) => f.id).toList()))
          f.id: f,
      };
      final toWrite = <Food>[];
      var changed = 0;
      for (final f in allFoods) {
        final old = existingById[f.id];
        if (old == null) {
          toWrite.add(f);
        } else if (!_sameCatalogContent(old, f)) {
          // Preserve the user's favourite flag across catalog refreshes.
          toWrite.add(old.isFavorite ? f.copyWith(isFavorite: true) : f);
          changed++;
        }
      }
      final inserted = toWrite.length - changed;
      final unchanged = allFoods.length - toWrite.length;
      onProgress?.call('Saving to catalog', 0, toWrite.length);
      for (var i = 0; i < toWrite.length; i += 800) {
        final chunk = toWrite.sublist(
          i,
          i + 800 > toWrite.length ? toWrite.length : i + 800,
        );
        await _repo.upsertFoods(chunk);
        onProgress?.call(
          'Saving to catalog',
          math.min(i + 800, toWrite.length),
          toWrite.length,
        );
        await Future<void>.delayed(Duration.zero);
      }

      // Record update time
      await _settings.set(_settingsKey, DateTime.now().toIso8601String());
      return OffUpdateResult(
        fetched: allFoods.length,
        inserted: inserted,
        updated: changed,
        unchanged: unchanged,
      );
    } catch (e) {
      // Partial results may have been saved; still record the attempt
      if (allFoods.isNotEmpty) {
        await _repo.upsertFoods(allFoods);
        await _settings.set(_settingsKey, DateTime.now().toIso8601String());
      }
      rethrow; // Propagate error to controller for UI display
    }
  }

  static Food? _parseProduct(Map<String, dynamic> p) {
    try {
      final name = (p['product_name'] as String?)?.trim() ?? '';
      final resolvedName = name.isEmpty
          ? ((p['generic_name'] as String?)?.trim() ?? '')
          : name;
      if (resolvedName.isEmpty) return null;
      final brand = _parseBrandField(p['brands']);

      final nutr =
          (p['nutriments'] as Map?)?.cast<String, dynamic>() ?? const {};
      double? n(String key) => (nutr[key] as num?)?.toDouble();

      var kcal = n('energy-kcal_100g');
      if (kcal == null) {
        final kJ = n('energy_100g');
        if (kJ != null) kcal = kJ / 4.184;
      }
      if (kcal == null || kcal <= 0) return null;

      double? servingQ;
      final rawServing = p['serving_quantity'];
      if (rawServing is num) {
        servingQ = rawServing.toDouble();
      } else if (rawServing is String) {
        final m = RegExp(r'[\d.]+').firstMatch(rawServing);
        if (m != null) servingQ = double.tryParse(m.group(0)!);
      }
      final grams = (servingQ != null && servingQ > 0 && servingQ <= 1000)
          ? servingQ
          : 100.0;

      final code = p['code']?.toString() ?? resolvedName.toLowerCase();
      return Food(
        id: 'off:$code',
        name: _titleCase(resolvedName),
        brand: brand,
        source: FoodSource.off,
        per100: Nutriments(
          kcal: kcal,
          proteinG: math.max(0, n('proteins_100g') ?? 0),
          carbsG: math.max(0, n('carbohydrates_100g') ?? 0),
          fatG: math.max(0, n('fat_100g') ?? 0),
          satFatG: math.max(0, n('saturated-fat_100g') ?? 0),
          sugarsG: math.max(0, n('sugars_100g') ?? 0),
          fiberG: math.max(0, n('fiber_100g') ?? 0),
          sodiumMg: math.max(0, (n('sodium_100g') ?? 0) * 1000),
        ),
        defaultGrams: grams,
      );
    } catch (_) {
      return null;
    }
  }

  /// api/v2 + CGI return `brands` as a comma-string; search-a-licious
  /// returns a JSON array. Accept both so catalog refreshes never drop
  /// rows on a format change.
  static String _parseBrandField(dynamic raw) {
    if (raw is List) {
      for (final b in raw) {
        final s = b?.toString().trim() ?? '';
        if (s.isNotEmpty) return s;
      }
      return '';
    }
    if (raw is String) return raw.split(',').first.trim();
    if (raw != null) {
      final s = raw.toString().trim();
      if (s.isNotEmpty && s != 'null') return s;
    }
    return '';
  }

  static String _titleCase(String s) => s.length <= 3
      ? s
      : s
            .split(' ')
            .map(
              (w) => w.isEmpty
                  ? w
                  : w[0].toUpperCase() + w.substring(1).toLowerCase(),
            )
            .join(' ');
}

/// Result of a catalog update: how many rows were genuinely new
/// vs content-changed vs identical (skipped).
class OffUpdateResult {
  const OffUpdateResult({
    required this.fetched,
    required this.inserted,
    required this.updated,
    this.unchanged = 0,
  });

  final int fetched;
  final int inserted;
  final int updated;

  /// Rows fetched but byte-identical to the DB (not rewritten).
  final int unchanged;
}

// ─── Activity / exercise repositories ───────────────────────────────────────

Activity _rowToActivity(ActivityRow r) => Activity(
  id: r.id,
  name: r.name,
  category: r.category,
  met: r.met,
  metOlderAdult: r.metOlderAdult,
  isFavorite: r.isFavorite,
  isCustom: r.isCustom,
);

ActivitiesCompanion _activityToCompanion(Activity a) {
  final searchText = Relevance.normalize('${a.name} ${a.category}');
  return ActivitiesCompanion.insert(
    id: a.id,
    name: a.name,
    searchText: searchText,
    category: Value(a.category),
    met: Value(a.met),
    metOlderAdult: Value(a.metOlderAdult),
    // isFavorite deliberately absent: seed refreshes must not unfavorite.
    // Ids are namespaced (act_* seed vs custom_* user rows) so the
    // isCustom flag below can never clobber a user row.
    isCustom: Value(a.isCustom),
  );
}

ExerciseEntry _rowToExercise(ExerciseEntryRow r) => ExerciseEntry(
  id: r.id,
  day: r.day,
  activityId: r.activityId,
  name: r.name,
  minutes: r.minutes,
  weightKg: r.weightKg,
  kcal: r.kcal,
  manualKcal: r.manualKcal,
  metUsed: r.metUsed,
  createdAt: r.createdAt,
  sortOrder: r.sortOrder,
);

ExerciseEntriesCompanion _exerciseToCompanion(ExerciseEntry e) {
  return ExerciseEntriesCompanion.insert(
    id: e.id,
    day: e.day,
    activityId: e.activityId,
    name: e.name,
    createdAt: e.createdAt,
    minutes: Value(e.minutes),
    weightKg: Value(e.weightKg),
    kcal: Value(e.kcal),
    manualKcal: Value(e.manualKcal),
    metUsed: Value(e.metUsed),
    sortOrder: Value(e.sortOrder),
  );
}

class ActivityRepository {
  ActivityRepository(this._db);

  final AppDatabase _db;

  Future<List<Activity>> search(String query, {int limit = 40}) async {
    final variants = Relevance.variantsForSql(query);
    if (variants.isEmpty) return [];
    final tokens = Relevance.tokenize(query);

    Expression<bool> tokenOr($ActivitiesTable a) =>
        variants.map((t) => a.searchText.contains(t)).reduce((a, b) => a | b);

    Set<String> historyIds = const {};
    try {
      historyIds = (await recentActivityIds(limit: 300)).toSet();
    } catch (_) {}

    final byId = <String, ActivityRow>{};

    // Previously-logged activities get their own query so the catalog
    // LIMIT below can never cut them before the history-first merge.
    if (historyIds.isNotEmpty) {
      final historySelect = _db.select(_db.activities)
        ..where((a) => a.id.isIn(historyIds) & tokenOr(a));
      historySelect.limit(20);
      for (final r in await historySelect.get()) {
        byId[r.id] = r;
      }
    }

    final select = _db.select(_db.activities)..where(tokenOr);
    select
      ..orderBy([
        (a) => OrderingTerm(expression: a.isFavorite, mode: OrderingMode.desc),
        (a) => OrderingTerm.asc(a.name),
      ])
      ..limit(limit * 3);
    for (final r in await select.get()) {
      byId.putIfAbsent(r.id, () => r);
    }

    // Relevance first, then favourites/history, then deterministic
    // name order — ties must never look random.
    final scored = byId.values.map(_rowToActivity).toList()
      ..sort((a, b) {
        final s = Relevance.textScore(
          tokens,
          b.name,
          b.category,
        ).compareTo(Relevance.textScore(tokens, a.name, a.category));
        if (s != 0) return s;
        final fa = (a.isFavorite ? 2 : 0) + (historyIds.contains(a.id) ? 1 : 0);
        final fb = (b.isFavorite ? 2 : 0) + (historyIds.contains(b.id) ? 1 : 0);
        if (fa != fb) return fb.compareTo(fa);
        return Relevance.compareNames(a.name, a.id, b.name, b.id);
      });
    return scored.take(limit).toList();
  }

  Future<Activity?> byId(String id) async {
    final row = await (_db.select(
      _db.activities,
    )..where((a) => a.id.equals(id))).getSingleOrNull();
    return row == null ? null : _rowToActivity(row);
  }

  Future<void> upsertActivity(Activity a) =>
      _db.into(_db.activities).insertOnConflictUpdate(_activityToCompanion(a));

  Future<void> upsertActivities(List<Activity> activities) async {
    await _db.batch((b) {
      for (final a in activities) {
        b.insert(
          _db.activities,
          _activityToCompanion(a),
          onConflict: DoUpdate(
            (_) => _activityToCompanion(a),
            target: [_db.activities.id],
          ),
        );
      }
    });
  }

  Future<void> setFavorite(String id, bool fav) =>
      (_db.update(_db.activities)..where((a) => a.id.equals(id))).write(
        ActivitiesCompanion(isFavorite: Value(fav)),
      );

  /// Removes bundled seed rows (keeps user customs). Used by catalog
  /// reseeds that regenerate ids.
  Future<void> deleteSeedRows() async {
    await (_db.delete(
      _db.activities,
    )..where((a) => a.isCustom.equals(false))).go();
  }

  Stream<List<Activity>> watchFavorites() {
    final q = _db.select(_db.activities)
      ..where((a) => a.isFavorite.equals(true))
      ..orderBy([(a) => OrderingTerm.asc(a.name)]);
    return q.watch().map((rows) => rows.map(_rowToActivity).toList());
  }

  /// Ids of recently logged activities, newest first. Used to boost
  /// history matches to the top of activity search results.
  Future<List<String>> recentActivityIds({int limit = 200}) async {
    final rows = await _db
        .customSelect(
          'SELECT activity_id, MAX(created_at) AS latest FROM exercise_entries '
          'GROUP BY activity_id ORDER BY latest DESC LIMIT ?',
          variables: [Variable(limit)],
        )
        .get();
    return rows.map((r) => r.data['activity_id'] as String).toList();
  }

  /// Distinct activities from exercise history with recency metadata.
  Future<List<({Activity activity, DateTime lastLogged, int count})>>
  historyDistinct({int limit = 100}) async {
    final rows = await _db
        .customSelect(
          'SELECT activity_id, MAX(created_at) AS latest, COUNT(*) AS n '
          'FROM exercise_entries GROUP BY activity_id '
          'ORDER BY latest DESC LIMIT ?',
          variables: [Variable(limit)],
        )
        .get();
    if (rows.isEmpty) return [];
    final out = <({Activity activity, DateTime lastLogged, int count})>[];
    for (final r in rows) {
      final id = r.data['activity_id'] as String;
      final activity = await byId(id);
      if (activity == null) continue;
      final raw = r.data['latest'];
      final lastLogged = raw is DateTime
          ? raw
          : DateTime.tryParse('$raw') ?? DateTime.now();
      out.add((
        activity: activity,
        lastLogged: lastLogged,
        count: (r.data['n'] as int?) ?? 1,
      ));
    }
    return out;
  }
}

class ExerciseRepository {
  ExerciseRepository(this._db);

  final AppDatabase _db;

  Stream<List<ExerciseEntry>> watchDay(String day) {
    final q = _db.select(_db.exerciseEntries)
      ..where((e) => e.day.equals(day))
      ..orderBy([
        (e) => OrderingTerm.asc(e.sortOrder),
        (e) => OrderingTerm.asc(e.createdAt),
      ]);
    return q.watch().map((rows) => rows.map(_rowToExercise).toList());
  }

  Future<int> _maxSortOrder(String day) async {
    final row =
        await (_db.selectOnly(_db.exerciseEntries)
              ..addColumns([_db.exerciseEntries.sortOrder.max()])
              ..where(_db.exerciseEntries.day.equals(day)))
            .getSingle();
    return row.read(_db.exerciseEntries.sortOrder.max()) ?? -1;
  }

  /// Logs a bout. [kcal] is snapshotted with the given weight/age so
  /// later profile changes never rewrite history.
  Future<ExerciseEntry> add({
    required String day,
    required Activity activity,
    required double minutes,
    required double weightKg,
    required int ageYears,
    double? manualKcal,
  }) async {
    final metUsed = ageYears >= olderAdultAge
        ? (activity.metOlderAdult ?? activity.met)
        : activity.met;
    final entry = ExerciseEntry(
      id: _uuid.v4(),
      day: day,
      activityId: activity.id,
      name: activity.name,
      minutes: minutes,
      weightKg: weightKg,
      kcal: ActivityMath.burnKcal(
        met: activity.met,
        metOlderAdult: activity.metOlderAdult,
        weightKg: weightKg,
        minutes: minutes,
        ageYears: ageYears,
      ),
      manualKcal: manualKcal,
      metUsed: metUsed,
      createdAt: DateTime.now(),
      sortOrder: await _maxSortOrder(day) + 1,
    );
    await _db.into(_db.exerciseEntries).insert(_exerciseToCompanion(entry));
    return entry;
  }

  /// Re-insert a snapshot (undo path), appended at the end of the day.
  Future<void> restore(ExerciseEntry entry) async {
    final sortOrder = await _maxSortOrder(entry.day) + 1;
    await _db
        .into(_db.exerciseEntries)
        .insert(
          _exerciseToCompanion(
            ExerciseEntry(
              id: _uuid.v4(),
              day: entry.day,
              activityId: entry.activityId,
              name: entry.name,
              minutes: entry.minutes,
              weightKg: entry.weightKg,
              kcal: entry.kcal,
              manualKcal: entry.manualKcal,
              metUsed: entry.metUsed,
              createdAt: DateTime.now(),
              sortOrder: sortOrder,
            ),
          ),
        );
  }

  /// Retimes a bout, rescaling the MET estimate linearly. A manual
  /// override is left untouched (the watch number stays truth).
  Future<void> updateMinutes(ExerciseEntry entry, double minutes) async {
    final mins = minutes.clamp(0, 1440).toDouble();
    final ratio = entry.minutes > 0 ? mins / entry.minutes : 1.0;
    await (_db.update(
      _db.exerciseEntries,
    )..where((e) => e.id.equals(entry.id))).write(
      ExerciseEntriesCompanion(
        minutes: Value(mins),
        kcal: Value(entry.kcal * ratio),
      ),
    );
  }

  /// Sets (or clears, with null) the watch-override calories.
  Future<void> setOverride(ExerciseEntry entry, double? manualKcal) async {
    await (_db.update(_db.exerciseEntries)..where((e) => e.id.equals(entry.id)))
        .write(ExerciseEntriesCompanion(manualKcal: Value(manualKcal)));
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.exerciseEntries)..where((e) => e.id.equals(id))).go();
  }
}

// ─── Weight repository (Goals weigh-ins) ────────────────────────────────────

WeightEntry _rowToWeight(WeightEntryRow r) =>
    WeightEntry(id: r.id, weightKg: r.weightKg, createdAt: r.createdAt);

class WeightRepository {
  WeightRepository(this._db);

  final AppDatabase _db;

  /// All weigh-ins, oldest first (graph order).
  Stream<List<WeightEntry>> watchAll() {
    final q = _db.select(_db.weightEntries)
      ..orderBy([(w) => OrderingTerm.asc(w.createdAt)]);
    return q.watch().map((rows) => rows.map(_rowToWeight).toList());
  }

  Future<WeightEntry> add(double weightKg) async {
    final entry = WeightEntry(
      id: _uuid.v4(),
      weightKg: weightKg,
      createdAt: DateTime.now(),
    );
    await _db
        .into(_db.weightEntries)
        .insert(
          WeightEntriesCompanion.insert(
            id: entry.id,
            weightKg: entry.weightKg,
            createdAt: entry.createdAt,
          ),
        );
    return entry;
  }

  /// Backdated weigh-in (AI graph import). Stored at noon to avoid
  /// day-boundary timezone shifts on the graph axis.
  Future<WeightEntry> addAt(double weightKg, DateTime day) async {
    final entry = WeightEntry(
      id: _uuid.v4(),
      weightKg: weightKg,
      createdAt: DateTime(day.year, day.month, day.day, 12),
    );
    await _db
        .into(_db.weightEntries)
        .insert(
          WeightEntriesCompanion.insert(
            id: entry.id,
            weightKg: entry.weightKg,
            createdAt: entry.createdAt,
          ),
        );
    return entry;
  }

  /// Calendar-day keys (yyyy-MM-dd) that already have a weigh-in.
  /// The table is tiny (one row per weigh-in), so a single read is fine.
  Future<Set<String>> existingDayKeys() async {
    final rows = await _db.select(_db.weightEntries).get();
    return {
      for (final r in rows)
        '${r.createdAt.year.toString().padLeft(4, '0')}-'
            '${r.createdAt.month.toString().padLeft(2, '0')}-'
            '${r.createdAt.day.toString().padLeft(2, '0')}',
    };
  }

  /// Bulk import skipping already-logged days. Returns (inserted, skipped).
  Future<({int inserted, int skipped})> addMany(
    Iterable<({DateTime date, double weightKg})> points,
  ) async {
    final existing = await existingDayKeys();
    var inserted = 0, skipped = 0;
    for (final p in points) {
      final key =
          '${p.date.year.toString().padLeft(4, '0')}-'
          '${p.date.month.toString().padLeft(2, '0')}-'
          '${p.date.day.toString().padLeft(2, '0')}';
      if (existing.contains(key)) {
        skipped++;
        continue;
      }
      existing.add(key);
      await addAt(p.weightKg, p.date);
      inserted++;
    }
    return (inserted: inserted, skipped: skipped);
  }

  Future<void> delete(String id) =>
      (_db.delete(_db.weightEntries)..where((w) => w.id.equals(id))).go();
}

/// First-run import of the bundled activity catalog. Versioned separately
/// from the food seed so catalog refreshes never re-import 21 MB of food.
class ActivitySeedImporter {
  ActivitySeedImporter(this._repo, this._settings, {this.onProgress});

  final ActivityRepository _repo;
  final SettingsRepository _settings;

  final void Function(String stage, int done, int total)? onProgress;

  static const versionKey = 'activity_seed_version';

  /// v2: condensed hand-named catalog (new ids throughout).
  static const currentVersion = '2';

  Future<bool> needsImport() async =>
      await _settings.get(versionKey) != currentVersion;

  Future<int> importIfNeeded() async {
    if (!await needsImport()) return 0;
    // v2 renames/regenerates every seed id: drop stale seed rows first so
    // old long-name entries can't linger as duplicates. User customs
    // (custom_* ids) and exercise history snapshots are untouched; seed
    // favourites are reset and can be re-starred.
    await _repo.deleteSeedRows();
    final raw = await rootBundle.loadString('assets/seed/activities.json');
    final doc = jsonDecode(raw) as Map<String, dynamic>;
    final list = (doc['activities'] as List).cast<Map<String, dynamic>>();
    final activities = list.map(_activityFromCompact).toList();
    for (var i = 0; i < activities.length; i += 300) {
      await _repo.upsertActivities(
        activities.sublist(
          i,
          i + 300 > activities.length ? activities.length : i + 300,
        ),
      );
      onProgress?.call(
        'Activity catalog',
        math.min(i + 300, activities.length),
        activities.length,
      );
      await Future<void>.delayed(Duration.zero);
    }
    await _settings.set(versionKey, currentVersion);
    return activities.length;
  }

  /// Compact seed schema: {i,n,c,m,o?} = id, name, category, MET,
  /// older-adult MET60 (optional).
  static Activity _activityFromCompact(Map<String, dynamic> j) => Activity(
    id: j['i'] as String,
    name: j['n'] as String,
    category: (j['c'] as String?) ?? '',
    met: (j['m'] as num).toDouble(),
    metOlderAdult: (j['o'] as num?)?.toDouble(),
  );
}

/// True when two catalog rows carry the same user-visible content.
/// Favorites/isFavorite are excluded (preserved separately).
bool _sameCatalogContent(Food a, Food b) {
  const eps = 1e-9;
  bool close(double x, double y) => (x - y).abs() < eps;
  final an = a.per100;
  final bn = b.per100;
  return a.name == b.name &&
      a.brand == b.brand &&
      a.source == b.source &&
      close(a.defaultGrams, b.defaultGrams) &&
      close(an.kcal, bn.kcal) &&
      close(an.proteinG, bn.proteinG) &&
      close(an.carbsG, bn.carbsG) &&
      close(an.fatG, bn.fatG) &&
      close(an.satFatG, bn.satFatG) &&
      close(an.sugarsG, bn.sugarsG) &&
      close(an.fiberG, bn.fiberG) &&
      close(an.sodiumMg, bn.sodiumMg);
}
