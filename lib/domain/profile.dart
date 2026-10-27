import 'weight.dart';

enum Sex { male, female }

enum ActivityLevel {
  sedentary(1.2, 'Mostly sitting'),
  light(1.375, 'Light exercise'),
  moderate(1.55, 'Active most days'),
  high(1.725, 'Hard training');

  const ActivityLevel(this.factor, this.label);
  final double factor;
  final String label;
}

enum GoalType { lose, maintain, gain }

class Profile {
  const Profile({
    this.name = '',
    required this.sex,
    required this.ageYears,
    required this.heightCm,
    required this.weightKg,
    required this.activity,
    required this.goal,
    required this.weeklyRateKg,
    this.customKcalTarget,
    this.proteinPct = 0.30,
    this.carbsPct = 0.40,
    this.fatPct = 0.30,
  });

  final String name;
  final Sex sex;
  final int ageYears;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activity;
  final GoalType goal;
  final double weeklyRateKg; // kg/week for lose/gain
  final int? customKcalTarget;
  final double proteinPct;
  final double carbsPct;
  final double fatPct;

  Goals get goals => Goals.fromProfile(this);

  Profile copyWith({
    String? name,
    Sex? sex,
    int? ageYears,
    double? heightCm,
    double? weightKg,
    ActivityLevel? activity,
    GoalType? goal,
    double? weeklyRateKg,
    int? customKcalTarget,
    double? proteinPct,
    double? carbsPct,
    double? fatPct,
  }) => Profile(
    name: name ?? this.name,
    sex: sex ?? this.sex,
    ageYears: ageYears ?? this.ageYears,
    heightCm: heightCm ?? this.heightCm,
    weightKg: weightKg ?? this.weightKg,
    activity: activity ?? this.activity,
    goal: goal ?? this.goal,
    weeklyRateKg: weeklyRateKg ?? this.weeklyRateKg,
    customKcalTarget: customKcalTarget ?? this.customKcalTarget,
    proteinPct: proteinPct ?? this.proteinPct,
    carbsPct: carbsPct ?? this.carbsPct,
    fatPct: fatPct ?? this.fatPct,
  );
}

class Goals {
  const Goals({
    required this.bmr,
    required this.tdee,
    required this.kcalTarget,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final double bmr;
  final double tdee;
  final int kcalTarget;
  final double proteinG;
  final double carbsG;
  final double fatG;

  /// Mifflin-St Jeor BMR × activity factor, adjusted by goal rate.
  ///
  /// 1 kg body fat ≈ 7700 kcal → daily delta = rate*7700/7.
  factory Goals.fromProfile(Profile p) {
    final bmr =
        10 * p.weightKg +
        6.25 * p.heightCm -
        5 * p.ageYears +
        (p.sex == Sex.male ? 5 : -161);
    final tdee = bmr * p.activity.factor;

    final dailyDelta = p.goal == GoalType.maintain
        ? 0.0
        : (p.goal == GoalType.lose ? -1 : 1) * (p.weeklyRateKg * 7700 / 7);

    var target = tdee + dailyDelta;
    // No safety floor: light/older users can have genuinely low targets
    // that track down with weigh-ins. The UI shows a soft caution note
    // under 1200 kcal instead of clamping.
    if (p.customKcalTarget != null) target = p.customKcalTarget!.toDouble();

    return Goals(
      bmr: bmr,
      tdee: tdee,
      kcalTarget: target.round(),
      proteinG: _round5(target * p.proteinPct / 4),
      carbsG: _round5(target * p.carbsPct / 4),
      fatG: _round5(target * p.fatPct / 9),
    );
  }

  static double _round5(double v) => (v / 5).round() * 5.0;

  /// Targets in effect on [day]: the latest weigh-in on/before that day
  /// wins, falling back to the profile setup weight when nothing was
  /// logged yet. Weigh-ins move the live target forward without ever
  /// rewriting what past days were judged against.
  factory Goals.effectiveForDay(
    Profile p,
    List<WeightEntry> weighIns,
    DateTime day,
  ) {
    final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);
    WeightEntry? latest;
    for (final w in weighIns) {
      if (w.createdAt.isAfter(endOfDay)) continue;
      if (latest == null || w.createdAt.isAfter(latest.createdAt)) {
        latest = w;
      }
    }
    return Goals.fromProfile(
      latest == null ? p : p.copyWith(weightKg: latest.weightKg),
    );
  }

  /// Soft caution threshold (informational note, never a clamp).
  static const lowTargetNote = 1200;
}
