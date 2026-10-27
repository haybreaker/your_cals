// Exercise logging domain: MET-based burn math (Compendium of Physical
// Activities, 2024) plus the TDEE-threshold bonus model.
//
// Gold-standard formula: kcal = MET × weightKg × hours. For adults 60+ the
// 2024 Older-Adult Compendium defines MET60+ with a 0.810 kcal/kg/h
// conversion; where an OA-specific value is missing we approximate with
// the adult MET × 0.810 conversion.
//
// Bonus model: the profile's activity factor already bakes assumed daily
// movement into the calorie target (assumed = BMR × (factor − 1)). Logged
// exercise only earns extra when it exceeds that budget:
// bonus = max(0, logged − assumed). Below the budget the ring/target do
// not change at all.
//
// Deliberate simplification: gross MET includes ~1 MET of resting overlap
// already counted in BMR. The threshold absorbs this, and gross matches
// the Lose It / watch mental model users compare against.

/// Age from which Older-Adult MET values apply.
const int olderAdultAge = 60;

/// Older-Adult kcal conversion (MET60+ × 0.810 × kg × h).
const double olderAdultKcalPerMetKgH = 0.810;

/// A loggable activity from the bundled catalog or user-added custom rows.
class Activity {
  const Activity({
    required this.id,
    required this.name,
    this.category = '',
    required this.met,
    this.metOlderAdult,
    this.isFavorite = false,
    this.isCustom = false,
  });

  final String id;
  final String name;
  final String category;
  final double met;

  /// 2024 Older-Adult Compendium value, null when unavailable (falls back
  /// to [met] × [olderAdultKcalPerMetKgH]).
  final double? metOlderAdult;
  final bool isFavorite;
  final bool isCustom;

  String get displayName =>
      category.isEmpty ? name : '$name · $category';

  /// Intensity band label for UI chips.
  String get intensity => met < 3
      ? 'Light'
      : met < 6
          ? 'Moderate'
          : 'Vigorous';

  Activity copyWith({bool? isFavorite}) => Activity(
        id: id,
        name: name,
        category: category,
        met: met,
        metOlderAdult: metOlderAdult,
        isFavorite: isFavorite ?? this.isFavorite,
        isCustom: isCustom,
      );
}

/// One logged exercise bout. [kcal] is snapshotted at log time (with that
/// day's weight) so history never shifts — same invariant as food entries.
/// [manualKcal] is the watch-override; when set it wins over the estimate.
class ExerciseEntry {
  const ExerciseEntry({
    required this.id,
    required this.day,
    required this.activityId,
    required this.name,
    required this.minutes,
    required this.weightKg,
    required this.kcal,
    this.manualKcal,
    required this.metUsed,
    required this.createdAt,
    this.sortOrder = 0,
  });

  final String id;
  final String day; // yyyy-MM-dd
  final String activityId;
  final String name;
  final double minutes;
  final double weightKg;
  final double kcal;
  final double? manualKcal;
  final double metUsed;
  final DateTime createdAt;
  final int sortOrder;

  /// Effective burn: manual override wins, else the MET estimate.
  double get effectiveKcal => manualKcal ?? kcal;

  bool get isOverride => manualKcal != null;
}

/// Pure activity math (unit tested).
abstract final class ActivityMath {
  /// Gross burn estimate for [minutes] at [met], adjusted for older
  /// adults when [ageYears] >= [olderAdultAge].
  static double burnKcal({
    required double met,
    double? metOlderAdult,
    required double weightKg,
    required double minutes,
    required int ageYears,
  }) {
    if (minutes <= 0 || weightKg <= 0 || met <= 0) return 0;
    final hours = minutes / 60.0;
    if (ageYears >= olderAdultAge) {
      final m = (metOlderAdult != null && metOlderAdult > 0)
          ? metOlderAdult
          : met;
      return m * olderAdultKcalPerMetKgH * weightKg * hours;
    }
    return met * weightKg * hours;
  }

  /// Daily movement budget already baked into the TDEE target.
  static double assumedActivityKcal({
    required double bmr,
    required double activityFactor,
  }) =>
      (bmr * (activityFactor - 1)).clamp(0, double.infinity).toDouble();

  /// Extra allowance earned: only the logged burn above the assumed
  /// budget counts. Never negative.
  static double bonusKcal({
    required double loggedKcal,
    required double assumedKcal,
  }) =>
      (loggedKcal - assumedKcal).clamp(0, double.infinity).toDouble();

  /// Full day resolution used by the diary hero.
  static ExerciseDay resolve({
    required double kcalTarget,
    required double bmr,
    required double activityFactor,
    required double loggedKcal,
  }) {
    final assumed = assumedActivityKcal(
        bmr: bmr, activityFactor: activityFactor);
    final bonus =
        bonusKcal(loggedKcal: loggedKcal, assumedKcal: assumed);
    return ExerciseDay(
      assumedKcal: assumed,
      loggedKcal: loggedKcal,
      bonusKcal: bonus,
      effectiveTarget: kcalTarget + bonus,
    );
  }
}

/// Resolved daily exercise state for one diary day.
class ExerciseDay {
  const ExerciseDay({
    required this.assumedKcal,
    required this.loggedKcal,
    required this.bonusKcal,
    required this.effectiveTarget,
  });

  final double assumedKcal;
  final double loggedKcal;
  final double bonusKcal;
  final double effectiveTarget;

  bool get hasBonus => bonusKcal > 0.5;
}
