import 'package:flutter_test/flutter_test.dart';
import 'package:your_cals/domain/food.dart';
import 'package:your_cals/domain/nutriments.dart';
import 'package:your_cals/domain/profile.dart';

void main() {
  group('Nutriments', () {
    test('scales per-100g values to grams', () {
      const n = Nutriments(kcal: 250, proteinG: 30, carbsG: 10, fatG: 8);
      final half = n.forGrams(50);
      expect(half.kcal, 125);
      expect(half.proteinG, 15);
      expect(half.carbsG, 5);
      expect(half.fatG, 4);
    });

    test('sums collections', () {
      const a = Nutriments(kcal: 100, proteinG: 5);
      const b = Nutriments(kcal: 50, proteinG: 2.5, sodiumMg: 200);
      final s = Nutriments.sum([a, b]);
      expect(s.kcal, 150);
      expect(s.proteinG, 7.5);
      expect(s.sodiumMg, 200);
    });

    test('json round trip', () {
      const n = Nutriments(
          kcal: 120,
          proteinG: 4,
          carbsG: 20,
          fatG: 2,
          satFatG: 0.5,
          sugarsG: 3,
          fiberG: 1.2,
          sodiumMg: 90);
      final back = Nutriments.fromMap(n.toMap());
      expect(back.kcal, 120);
      expect(back.sodiumMg, 90);
    });
  });

  group('Goals (Mifflin-St Jeor)', () {
    test('male maintenance TDEE is sane', () {
      const p = Profile(
        sex: Sex.male,
        ageYears: 30,
        heightCm: 180,
        weightKg: 80,
        activity: ActivityLevel.moderate,
        goal: GoalType.maintain,
        weeklyRateKg: 0,
      );
      // BMR = 10*80 + 6.25*180 - 5*30 + 5 = 1780
      expect(p.goals.bmr, closeTo(1780, 1));
      expect(p.goals.tdee, closeTo(1780 * 1.55, 1));
      expect(p.goals.kcalTarget, closeTo(1780 * 1.55, 1));
    });

    test('female BMR offset', () {
      const p = Profile(
        sex: Sex.female,
        ageYears: 30,
        heightCm: 165,
        weightKg: 60,
        activity: ActivityLevel.light,
        goal: GoalType.maintain,
        weeklyRateKg: 0,
      );
      // BMR = 600 + 1031.25 - 150 - 161 = 1320.25
      expect(p.goals.bmr, closeTo(1320.25, 1));
    });

    test('0.5kg/wk loss ≈ 550 kcal deficit', () {
      const maintain = Profile(
        sex: Sex.male,
        ageYears: 30,
        heightCm: 180,
        weightKg: 80,
        activity: ActivityLevel.moderate,
        goal: GoalType.maintain,
        weeklyRateKg: 0,
      );
      const lose = Profile(
        sex: Sex.male,
        ageYears: 30,
        heightCm: 180,
        weightKg: 80,
        activity: ActivityLevel.moderate,
        goal: GoalType.lose,
        weeklyRateKg: 0.5,
      );
      expect(maintain.goals.kcalTarget - lose.goals.kcalTarget, closeTo(550, 1));
    });

    test('aggressive cuts track down and arm the low-target caution', () {
      const p = Profile(
        sex: Sex.female,
        ageYears: 60,
        heightCm: 150,
        weightKg: 45,
        activity: ActivityLevel.sedentary,
        goal: GoalType.lose,
        weeklyRateKg: 1.0,
      );
      // No hard floor by design: the target keeps tracking down for
      // light/older profiles (LowTargetNote shows the ≤1200 caution).
      final t = p.goals.kcalTarget;
      expect(t, greaterThan(0));
      expect(t, lessThan(Goals.lowTargetNote));
    });

    test('custom target overrides calculation', () {
      const p = Profile(
        sex: Sex.male,
        ageYears: 30,
        heightCm: 180,
        weightKg: 80,
        activity: ActivityLevel.moderate,
        goal: GoalType.maintain,
        weeklyRateKg: 0,
        customKcalTarget: 3000,
      );
      expect(p.goals.kcalTarget, 3000);
    });
  });

  group('Recipe scaling', () {
    test('per-serving nutrition divides by servings', () {
      final r = Recipe(
        id: 'r1',
        name: 'Stir fry',
        servings: 2,
        createdAt: DateTime.now(),
        ingredients: [
          RecipeIngredient(
            foodId: 'f1',
            name: 'Chicken',
            brand: '',
            grams: 400,
            per100: const Nutriments(kcal: 165, proteinG: 31),
          ),
          RecipeIngredient(
            foodId: 'f2',
            name: 'Rice',
            brand: '',
            grams: 300,
            per100: const Nutriments(kcal: 130, carbsG: 28),
          ),
        ],
      );
      // Total = 400*1.65 + 300*1.30 = 660 + 390 = 1050 kcal
      expect(r.total.kcal, 1050);
      expect(r.perServing.kcal, 525);
      expect(r.totalGrams, 700);
      expect(r.gramsPerServing, 350);
    });
  });

  group('Food', () {
    test('allServings includes default and plain 100g once', () {
      final f = Food(
        id: 'x',
        name: 'Pie',
        source: FoodSource.chain,
        per100: const Nutriments(kcal: 273),
        defaultGrams: 160,
        servings: [const ServingOption(label: '1 pie', grams: 160)],
      );
      final labels = f.allServings.map((s) => s.label).toList();
      expect(labels.where((l) => l == '100 g'), hasLength(1));
      expect(f.allServings.first.label, contains('160'));
    });
  });
}
