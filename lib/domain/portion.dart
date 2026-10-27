
enum PortionUnit { g, ml, serving, tsp, tbsp, cup, oz }

extension PortionUnitX on PortionUnit {
  String get label => switch (this) {
        PortionUnit.g => 'g',
        PortionUnit.ml => 'ml',
        PortionUnit.serving => 'serv',
        PortionUnit.tsp => 'tsp',
        PortionUnit.tbsp => 'tbsp',
        PortionUnit.cup => 'cup',
        PortionUnit.oz => 'oz',
      };

  String get name2 => name;

  /// Fixed kitchen conversions to grams (density assumption 1:1).
  double get gramsPerUnit => switch (this) {
        PortionUnit.g => 1,
        PortionUnit.ml => 1,
        PortionUnit.serving => 0, // resolved via servingGrams at call site
        PortionUnit.tsp => 5,
        PortionUnit.tbsp => 15,
        PortionUnit.cup => 240,
        PortionUnit.oz => 28.35,
      };

  static PortionUnit fromName(String? s) => PortionUnit.values
      .firstWhere((e) => e.name == s, orElse: () => PortionUnit.g);
}

/// Pure portion math (unit tested).
abstract final class PortionMath {
  /// Resolves a user amount into the gram weight used for nutrition math.
  /// ml maps 1:1 to grams (standard density assumption). Kitchen units use
  /// fixed conversions: tsp 5g, tbsp 15g, cup 240g, oz 28.35g.
  static double resolveGrams({
    required PortionUnit unit,
    required double qty,
    required double servingGrams,
  }) =>
      switch (unit) {
        PortionUnit.g => qty,
        PortionUnit.ml => qty,
        PortionUnit.serving => qty * servingGrams,
        PortionUnit.tsp => qty * 5,
        PortionUnit.tbsp => qty * 15,
        PortionUnit.cup => qty * 240,
        PortionUnit.oz => qty * 28.35,
      };

  /// Converts an amount between units, keeping total grams stable.
  static ({double qty, PortionUnit unit}) convert({
    required double qty,
    required PortionUnit from,
    required PortionUnit to,
    required double servingGrams,
  }) {
    final grams = resolveGrams(
        unit: from, qty: qty, servingGrams: servingGrams);
    final double newQty = switch (to) {
      PortionUnit.g => grams,
      PortionUnit.ml => grams,
      PortionUnit.serving =>
        servingGrams <= 0 ? 0.0 : grams / servingGrams,
      PortionUnit.tsp => grams / 5,
      PortionUnit.tbsp => grams / 15,
      PortionUnit.cup => grams / 240,
      PortionUnit.oz => grams / 28.35,
    };
    return (qty: newQty, unit: to);
  }
}
