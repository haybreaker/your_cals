import 'nutriments.dart';

/// A searchable/loggable food. Nutrition is stored per-100g; [defaultGrams]
/// is the suggested single-serving weight.
class Food {
  const Food({
    required this.id,
    required this.name,
    this.brand = '',
    required this.source,
    required this.per100,
    this.defaultGrams = 100,
    this.servings = const [],
    this.isFavorite = false,
    this.barcode,
    this.liquid = false,
  });

  final String id;
  final String name;
  final String brand;
  final FoodSource source;
  final Nutriments per100;
  final double defaultGrams;
  final List<ServingOption> servings;
  final bool isFavorite;
  final String? barcode;

  /// True for beverages — portion editor defaults to ml.
  final bool liquid;

  String get displayName => brand.isEmpty ? name : '$name · $brand';

  List<ServingOption> get allServings {
    final list = [
      if (defaultGrams > 0 && defaultGrams != 100)
        ServingOption(
            label: '1 serving (${_fmt(defaultGrams)} g)', grams: defaultGrams),
      ...servings,
    ];
    // INVARIANT: never empty, and a plain 100 g option exists exactly once
    // (the portion editor's grams fallback).
    if (!list.any((s) => s.grams == 100)) {
      list.add(const ServingOption(label: '100 g', grams: 100));
    }
    return list;
  }

  Food copyWith({bool? isFavorite}) => Food(
        id: id,
        name: name,
        brand: brand,
        source: source,
        per100: per100,
        defaultGrams: defaultGrams,
        servings: servings,
        isFavorite: isFavorite ?? this.isFavorite,
        barcode: barcode,
        liquid: liquid,
      );

  static String _fmt(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    var s = v.toStringAsFixed(2);
    while (s.contains('.') && s.endsWith('0')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'source': source.name,
        'per100': per100.toMap(),
        'defaultGrams': defaultGrams,
        'servings': servings.map((s) => s.toJson()).toList(),
        'barcode': barcode,
      };

  factory Food.fromJson(Map<String, dynamic> j) => Food(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        brand: j['brand'] as String? ?? '',
        source: FoodSource.fromName(j['source'] as String?),
        per100: Nutriments.fromMap((j['per100'] as Map).cast<String, dynamic>()),
        defaultGrams: (j['defaultGrams'] as num?)?.toDouble() ?? 100,
        servings: ((j['servings'] as List?) ?? const [])
            .map((s) => ServingOption.fromJson((s as Map).cast<String, dynamic>()))
            .toList(),
        barcode: j['barcode'] as String?,
      );
}

/// One logged eating occasion. Nutrition totals are snapshotted at log time
/// so history never shifts when database entries change.
class LogEntry {
  const LogEntry({
    required this.id,
    required this.day,
    required this.meal,
    required this.foodId,
    required this.name,
    required this.brand,
    required this.source,
    required this.grams,
    this.unit = 'g',
    this.servingCount,
    this.servingGrams,
    this.servingLabel,
    required this.nutr,
    this.photoPath,
    required this.createdAt,
    this.sortOrder = 0,
  });

  final String id;
  final String day; // yyyy-MM-dd
  final MealType meal;
  final String foodId;
  final String name;
  final String brand;
  final FoodSource source;
  final double grams;

  /// 'g' | 'ml' | 'serving' — display unit the user entered.
  final String unit;

  /// Number of serves when logged in serving mode (v3); null when the entry
  /// was made in g/ml or predates serving persistence.
  final double? servingCount;

  /// Grams per serve used at log time, so steppers can rescale reliably.
  final double? servingGrams;

  /// Label of the serving option chosen, e.g. '1 slice (30 g)'.
  final String? servingLabel;
  final Nutriments nutr;
  final String? photoPath;
  final DateTime createdAt;

  /// Manual ordering within (day, meal).
  final int sortOrder;

  LogEntry copyWith({
    double? grams,
    String? unit,
    double? servingCount,
    double? servingGrams,
    String? servingLabel,
    Nutriments? nutr,
    MealType? meal,
    int? sortOrder,
  }) =>
      LogEntry(
        id: id,
        day: day,
        meal: meal ?? this.meal,
        foodId: foodId,
        name: name,
        brand: brand,
        source: source,
        grams: grams ?? this.grams,
        unit: unit ?? this.unit,
        servingCount: servingCount ?? this.servingCount,
        servingGrams: servingGrams ?? this.servingGrams,
        servingLabel: servingLabel ?? this.servingLabel,
        nutr: nutr ?? this.nutr,
        photoPath: photoPath,
        createdAt: createdAt,
        sortOrder: sortOrder ?? this.sortOrder,
      );

  /// True when the entry carries serving info the UI can act on (steppers,
  /// serves-first tile labels).
  bool get hasServings =>
      servingCount != null &&
      servingGrams != null &&
      servingGrams! > 0 &&
      unit == 'serving';

  /// Human label of the consumed amount, honouring the entry's unit.
  /// Serves-first when available, grams in brackets secondary.
  String get amountLabel => hasServings
      ? '${_fmtCount(servingCount!)} × $_serveName (${grams.round()} g)'
      : switch (unit) {
          'ml' => '${grams.round()} ml',
          _ => '${grams.round()} g',
        };

  /// Just the count + name, e.g. "2 long blacks" (no grams).
  String get servesLabel {
    final name = hasServings ? _serveName : '';
    return '${_fmtCount(servingCount!)} $name'.trim();
  }
  /// Just the grams, e.g. "(332 g)".
  String get gramsLabel => '(${grams.round()} ${unit == 'ml' ? 'ml' : 'g'})';

  String get _serveName {
    final l = servingLabel;
    if (l == null || l.trim().isEmpty) return 'serve';
    // '1 slice (30 g)' → 'slice'; '100 g' → '100 g'.
    final stripped = l
        .replaceFirst(RegExp(r'^\s*1\s+'), '')
        .replaceFirst(RegExp(r'\s*\([^)]*\)\s*$'), '')
        .trim();
    return stripped.isEmpty ? l.trim() : stripped;
  }

  static String _fmtCount(double v) {
    if (v == v.roundToDouble()) return v.round().toString();
    var s = v.toStringAsFixed(2);
    while (s.contains('.') && s.endsWith('0')) {
      s = s.substring(0, s.length - 1);
    }
    return s;
  }
}

class RecipeIngredient {
  const RecipeIngredient({
    required this.foodId,
    required this.name,
    required this.brand,
    required this.grams,
    required this.per100,
    double? qty,
    String? unit,
    this.source = FoodSource.custom,
  })  : qty = qty ?? grams,
        unit = unit ?? 'g';

  final String foodId;
  final String name;
  final String brand;

  /// Resolved gram weight used for nutrition math.
  final double grams;
  final Nutriments per100;

  /// User-entered amount + unit (e.g. 1.5 tbsp). [grams] is the resolved
  /// canonical value; [qty]/[unit] preserve display/edit intent.
  final double qty;
  final String unit;

  /// Transient source for editor display (not persisted in recipe_items;
  /// re-enriched via foods lookup on load).
  final FoodSource source;

  /// True when this ingredient references another recipe (`recipe:<id>`).
  bool get isRecipeRef => foodId.startsWith('recipe:');

  /// Recipe id without the `recipe:` prefix, or null for plain foods.
  String? get recipeRefId =>
      isRecipeRef ? foodId.substring('recipe:'.length) : null;

  Nutriments get nutr => per100.forGrams(grams);
}

class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.servings,
    required this.ingredients,
    required this.createdAt,
  });

  final String id;
  final String name;
  final int servings;
  final List<RecipeIngredient> ingredients;
  final DateTime createdAt;

  Nutriments get total => Nutriments.sum(ingredients.map((i) => i.nutr));

  Nutriments get perServing {
    final t = total;
    final f = servings <= 0 ? 1 : servings;
    return Nutriments(
      kcal: t.kcal / f,
      proteinG: t.proteinG / f,
      carbsG: t.carbsG / f,
      fatG: t.fatG / f,
      satFatG: t.satFatG / f,
      sugarsG: t.sugarsG / f,
      fiberG: t.fiberG / f,
      sodiumMg: t.sodiumMg / f,
    );
  }

  double get totalGrams => ingredients.fold(0, (a, i) => a + i.grams);
  double get gramsPerServing =>
      servings <= 0 ? totalGrams : totalGrams / servings;
}
