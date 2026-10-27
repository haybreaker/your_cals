/// Core nutrition facts, always normalized per 100 g/ml of food.
class Nutriments {
  const Nutriments({
    this.kcal = 0,
    this.proteinG = 0,
    this.carbsG = 0,
    this.fatG = 0,
    this.satFatG = 0,
    this.sugarsG = 0,
    this.fiberG = 0,
    this.sodiumMg = 0,
    this.vitAMcg = 0,
    this.vitB1Mg = 0,
    this.vitB2Mg = 0,
    this.vitB3Mg = 0,
    this.vitB6Mg = 0,
    this.vitB12Ug = 0,
    this.vitCMg = 0,
    this.folateUg = 0,
    this.calciumMg = 0,
    this.ironMg = 0,
    this.magnesiumMg = 0,
    this.potassiumMg = 0,
    this.zincMg = 0,
  });

  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final double satFatG;
  final double sugarsG;
  final double fiberG;
  final double sodiumMg;

  // Micronutrients per 100 g
  final double vitAMcg;
  final double vitB1Mg;
  final double vitB2Mg;
  final double vitB3Mg;
  final double vitB6Mg;
  final double vitB12Ug;
  final double vitCMg;
  final double folateUg;
  final double calciumMg;
  final double ironMg;
  final double magnesiumMg;
  final double potassiumMg;
  final double zincMg;

  bool get hasMicros =>
      vitCMg > 0 ||
      calciumMg > 0 ||
      ironMg > 0 ||
      potassiumMg > 0 ||
      vitB12Ug > 0 ||
      vitAMcg > 0;

  bool get isEmpty => kcal == 0 && proteinG == 0 && carbsG == 0 && fatG == 0;

  Nutriments forGrams(double grams) {
    final f = grams / 100.0;
    return Nutriments(
      kcal: kcal * f,
      proteinG: proteinG * f,
      carbsG: carbsG * f,
      fatG: fatG * f,
      satFatG: satFatG * f,
      sugarsG: sugarsG * f,
      fiberG: fiberG * f,
      sodiumMg: sodiumMg * f,
      vitAMcg: vitAMcg * f,
      vitB1Mg: vitB1Mg * f,
      vitB2Mg: vitB2Mg * f,
      vitB3Mg: vitB3Mg * f,
      vitB6Mg: vitB6Mg * f,
      vitB12Ug: vitB12Ug * f,
      vitCMg: vitCMg * f,
      folateUg: folateUg * f,
      calciumMg: calciumMg * f,
      ironMg: ironMg * f,
      magnesiumMg: magnesiumMg * f,
      potassiumMg: potassiumMg * f,
      zincMg: zincMg * f,
    );
  }

  static Nutriments sum(Iterable<Nutriments> list) => list.fold(
        const Nutriments(),
        (a, b) => Nutriments(
          kcal: a.kcal + b.kcal,
          proteinG: a.proteinG + b.proteinG,
          carbsG: a.carbsG + b.carbsG,
          fatG: a.fatG + b.fatG,
          satFatG: a.satFatG + b.satFatG,
          sugarsG: a.sugarsG + b.sugarsG,
          fiberG: a.fiberG + b.fiberG,
          sodiumMg: a.sodiumMg + b.sodiumMg,
        ),
      );

  Map<String, double> toMap() => {
        'kcal': kcal,
        'protein': proteinG,
        'carbs': carbsG,
        'fat': fatG,
        'satFat': satFatG,
        'sugars': sugarsG,
        'fiber': fiberG,
        'sodium': sodiumMg,
        'vitA': vitAMcg,
        'vitB1': vitB1Mg,
        'vitB2': vitB2Mg,
        'vitB3': vitB3Mg,
        'vitB6': vitB6Mg,
        'vitB12': vitB12Ug,
        'vitC': vitCMg,
        'folate': folateUg,
        'calcium': calciumMg,
        'iron': ironMg,
        'magnesium': magnesiumMg,
        'potassium': potassiumMg,
        'zinc': zincMg,
      };

  factory Nutriments.fromMap(Map<String, dynamic> m) => Nutriments(
        kcal: (m['kcal'] as num?)?.toDouble() ?? 0,
        proteinG: (m['protein'] as num?)?.toDouble() ?? 0,
        carbsG: (m['carbs'] as num?)?.toDouble() ?? 0,
        fatG: (m['fat'] as num?)?.toDouble() ?? 0,
        satFatG: (m['satFat'] as num?)?.toDouble() ?? 0,
        sugarsG: (m['sugars'] as num?)?.toDouble() ?? 0,
        fiberG: (m['fiber'] as num?)?.toDouble() ?? 0,
        sodiumMg: (m['sodium'] as num?)?.toDouble() ?? 0,
        vitAMcg: (m['vitA'] as num?)?.toDouble() ?? 0,
        vitB1Mg: (m['vitB1'] as num?)?.toDouble() ?? 0,
        vitB2Mg: (m['vitB2'] as num?)?.toDouble() ?? 0,
        vitB3Mg: (m['vitB3'] as num?)?.toDouble() ?? 0,
        vitB6Mg: (m['vitB6'] as num?)?.toDouble() ?? 0,
        vitB12Ug: (m['vitB12'] as num?)?.toDouble() ?? 0,
        vitCMg: (m['vitC'] as num?)?.toDouble() ?? 0,
        folateUg: (m['folate'] as num?)?.toDouble() ?? 0,
        calciumMg: (m['calcium'] as num?)?.toDouble() ?? 0,
        ironMg: (m['iron'] as num?)?.toDouble() ?? 0,
        magnesiumMg: (m['magnesium'] as num?)?.toDouble() ?? 0,
        potassiumMg: (m['potassium'] as num?)?.toDouble() ?? 0,
        zincMg: (m['zinc'] as num?)?.toDouble() ?? 0,
      );
}

enum FoodSource {
  afcd('AFCD', 'FSANZ reference'),
  ausnut('AUSNUT', 'FSANZ survey'),
  npc('NPC', 'FSANZ NPC'),
  chain('Menu', 'Published menu'),
  off('OFF', 'Open Food Facts'),
  ai('AI estimate', 'Gemini'),
  custom('Custom', 'You'),
  recipe('Recipe', 'Yours');

  const FoodSource(this.label, this.hint);
  final String label;
  final String hint;

  bool get verified =>
      this == afcd || this == ausnut || this == npc || this == chain;

  static FoodSource fromName(String? s) =>
      FoodSource.values.firstWhere((e) => e.name == s, orElse: () => FoodSource.custom);
}

/// A named portion option, e.g. "1 slice (30 g)".
class ServingOption {
  const ServingOption({required this.label, required this.grams});
  final String label;
  final double grams;

  Map<String, dynamic> toJson() => {'label': label, 'grams': grams};

  factory ServingOption.fromJson(Map<String, dynamic> j) => ServingOption(
        label: j['label'] as String,
        grams: (j['grams'] as num).toDouble(),
      );
}

enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeX on MealType {
  String get label => switch (this) {
        MealType.breakfast => 'Breakfast',
        MealType.lunch => 'Lunch',
        MealType.dinner => 'Dinner',
        MealType.snack => 'Snacks',
      };

  static MealType forNow([DateTime? now]) {
    final h = (now ?? DateTime.now()).hour;
    if (h < 10) return MealType.breakfast;
    if (h < 14) return MealType.lunch;
    if (h < 20) return MealType.dinner;
    return MealType.snack;
  }

  static MealType fromName(String? s) =>
      MealType.values.firstWhere((e) => e.name == s, orElse: () => MealType.snack);
}
