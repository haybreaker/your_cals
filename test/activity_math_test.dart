import 'package:flutter_test/flutter_test.dart';
import 'package:your_cals/domain/activity.dart';

void main() {
  group('ActivityMath.burnKcal (Compendium: MET x kg x h)', () {
    test('mowing: 5.5 MET x 82 kg x 1 h = ~451', () {
      expect(
        ActivityMath.burnKcal(
            met: 5.5, weightKg: 82, minutes: 60, ageYears: 30),
        closeTo(451, 1),
      );
    });

    test('walking 3 mph: 3.5 MET x 75 kg x 0.75 h = ~197', () {
      expect(
        ActivityMath.burnKcal(
            met: 3.5, weightKg: 75, minutes: 45, ageYears: 30),
        closeTo(196.9, 1),
      );
    });

    test('running 6 mph is a 10 MET activity', () {
      expect(
        ActivityMath.burnKcal(
            met: 10, weightKg: 70, minutes: 30, ageYears: 30),
        closeTo(350, 1),
      );
    });

    test('guards: zero/negative inputs burn nothing', () {
      expect(
          ActivityMath.burnKcal(
              met: 5, weightKg: 70, minutes: 0, ageYears: 30),
          0);
      expect(
          ActivityMath.burnKcal(
              met: 5, weightKg: 0, minutes: 30, ageYears: 30),
          0);
    });

    test('older adults use MET60+ x 0.810 conversion', () {
      // Same inputs, 65yo with an OA-specific value burns less.
      final adult = ActivityMath.burnKcal(
          met: 4.0, metOlderAdult: 3.6, weightKg: 70, minutes: 60, ageYears: 40);
      final older = ActivityMath.burnKcal(
          met: 4.0, metOlderAdult: 3.6, weightKg: 70, minutes: 60, ageYears: 65);
      expect(adult, closeTo(280, 1));
      expect(older, closeTo(3.6 * 0.810 * 70, 1));
      expect(older, lessThan(adult));
    });

    test('older adults fall back to adult MET x 0.810 when OA missing', () {
      expect(
        ActivityMath.burnKcal(
            met: 4.0, weightKg: 70, minutes: 60, ageYears: 65),
        closeTo(4.0 * 0.810 * 70, 1),
      );
    });
  });

  group('Exercise bonus threshold model', () {
    test('below budget earns nothing (ring unchanged)', () {
      // BMR 1400, moderate 1.55 -> assumed 770. Gardening 840? no:
      // 3 MET x 70 kg x 2 h = 420 < 770.
      final day = ActivityMath.resolve(
        kcalTarget: 2000,
        bmr: 1400,
        activityFactor: 1.55,
        loggedKcal: 420,
      );
      expect(day.assumedKcal, closeTo(770, 1));
      expect(day.bonusKcal, 0);
      expect(day.hasBonus, isFalse);
      expect(day.effectiveTarget, 2000);
    });

    test('above budget earns the difference (mother gardening)', () {
      // 5 MET x 70 kg x 3 h = 1050; assumed 770 -> +280 bonus.
      final day = ActivityMath.resolve(
        kcalTarget: 2000,
        bmr: 1400,
        activityFactor: 1.55,
        loggedKcal: 1050,
      );
      expect(day.bonusKcal, closeTo(280, 1));
      expect(day.hasBonus, isTrue);
      expect(day.effectiveTarget, closeTo(2280, 1));
    });

    test('exactly at budget earns nothing', () {
      final day = ActivityMath.resolve(
        kcalTarget: 2000,
        bmr: 1400,
        activityFactor: 1.55,
        loggedKcal: 770,
      );
      expect(day.bonusKcal, 0);
      expect(day.hasBonus, isFalse);
    });

    test('sedentary factor still leaves a small budget', () {
      expect(
        ActivityMath.assumedActivityKcal(bmr: 1500, activityFactor: 1.2),
        closeTo(300, 1),
      );
    });
  });

  group('ExerciseEntry effective kcal', () {
    test('manual override wins over the estimate', () {
      final e = ExerciseEntry(
        id: 'x',
        day: '2026-01-01',
        activityId: 'jog',
        name: 'Jogging',
        minutes: 30,
        weightKg: 80,
        kcal: 280,
        manualKcal: 400,
        metUsed: 7,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(e.effectiveKcal, 400);
      expect(e.isOverride, isTrue);
    });
  });
}
