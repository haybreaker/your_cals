import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:your_cals/data/db/database.dart';
import 'package:your_cals/data/repositories.dart';
import 'package:your_cals/domain/food.dart';
import 'package:your_cals/domain/nutriments.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DiaryRepository repo;

  setUp(() async {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repo = DiaryRepository(db);
  });

  tearDown(() => db.close());

  Food food(String name, {double kcal = 100}) => Food(
        id: 'f:$name',
        name: name,
        source: FoodSource.custom,
        per100: Nutriments(kcal: kcal),
      );

  test('add persists serving metadata and sortOrder', () async {
    final a = await repo.add(
      day: '2026-09-03',
      meal: MealType.breakfast,
      food: food('Biscuit'),
      grams: 30,
      unit: 'serving',
      servingCount: 2,
      servingGrams: 15,
      servingLabel: '1 biscuit (15 g)',
    );
    final b = await repo.add(
      day: '2026-09-03',
      meal: MealType.breakfast,
      food: food('Coffee'),
      grams: 250,
    );

    expect(a.servingCount, 2);
    expect(a.servingGrams, 15);
    expect(a.servingLabel, '1 biscuit (15 g)');
    expect(a.sortOrder, 0);
    expect(b.sortOrder, 1);

    final day = await repo.watchDay('2026-09-03').first;
    expect(day.map((e) => e.name), ['Biscuit', 'Coffee']);
  });

  test('labels: serves first with grams in brackets', () {
    final entry = LogEntry(
      id: 'x',
      day: '2026-09-03',
      meal: MealType.breakfast,
      foodId: 'f',
      name: 'Long black',
      brand: '',
      source: FoodSource.custom,
      grams: 332,
      unit: 'serving',
      servingCount: 2,
      servingGrams: 166,
      servingLabel: '1 long black (166 g)',
      nutr: const Nutriments(kcal: 5),
      createdAt: DateTime(2026),
    );

    expect(entry.hasServings, isTrue);
    expect(entry.servesLabel, '2 long black');
    expect(entry.amountLabel, contains('332 g'));
  });

  test('reorder within section compacts sort orders', () async {
    final a = await repo.add(
        day: 'd', meal: MealType.lunch, food: food('A'), grams: 100);
    final b = await repo.add(
        day: 'd', meal: MealType.lunch, food: food('B'), grams: 100);
    final c = await repo.add(
        day: 'd', meal: MealType.lunch, food: food('C'), grams: 100);

    // Move C to the top.
    await repo.reorder(c, newIndex: 0);

    final day = await repo.watchDay('d').first;
    expect(day.map((e) => e.name), ['C', 'A', 'B']);
    expect(day.map((e) => e.sortOrder), [0, 1, 2]);

    // Move C (index 0) below B (index 2).
    await repo.reorder(c, newIndex: 2);
    final day2 = await repo.watchDay('d').first;
    expect(day2.map((e) => e.name), ['A', 'B', 'C']);
    expect(b.sortOrder, 1); // sanity: original entry data unchanged

    // Move A to the end.
    await repo.reorder(a, newIndex: 99);
    final day3 = await repo.watchDay('d').first;
    expect(day3.map((e) => e.name), ['B', 'C', 'A']);
  });

  test('reorder across sections changes meal', () async {
    final a = await repo.add(
        day: 'd', meal: MealType.breakfast, food: food('A'), grams: 100);
    await repo.add(
        day: 'd', meal: MealType.lunch, food: food('B'), grams: 100);

    // Drag A into lunch, above B.
    await repo.reorder(a, meal: MealType.lunch, newIndex: 0);

    final lunch = (await repo.watchDay('d').first)
        .where((e) => e.meal == MealType.lunch)
        .toList();
    expect(lunch.map((e) => e.name), ['A', 'B']);
    expect(lunch.map((e) => e.sortOrder), [0, 1]);
  });

  test('copyToDay preserves servings, meal and nutrition', () async {
    final original = await repo.add(
      day: '2026-09-02',
      meal: MealType.dinner,
      food: food('Chicken', kcal: 200),
      grams: 300,
      unit: 'serving',
      servingCount: 2,
      servingGrams: 150,
      servingLabel: '1 breast (150 g)',
    );

    final copies = await repo.copyToDay([original], '2026-09-03');
    expect(copies, hasLength(1));
    final c = copies.first;
    expect(c.id, isNot(original.id));
    expect(c.day, '2026-09-03');
    expect(c.meal, MealType.dinner);
    expect(c.servingCount, 2);
    expect(c.nutr.kcal, original.nutr.kcal);

    final day = await repo.watchDay('2026-09-03').first;
    expect(day, hasLength(1));
  });

  test('updatePortion rescales nutrition and rewrites serving fields',
      () async {
    final entry = await repo.add(
      day: 'd',
      meal: MealType.snack,
      food: food('Biscuits', kcal: 480),
      grams: 30,
      unit: 'serving',
      servingCount: 3,
      servingGrams: 10,
      servingLabel: '1 biscuit (10 g)',
    );
    expect(entry.nutr.kcal, closeTo(144, 0.1));

    await repo.updatePortion(
      entry,
      grams: 20,
      unit: 'serving',
      servingCount: 2,
      servingGrams: 10,
      servingLabel: '1 biscuit (10 g)',
    );

    final updated = (await repo.watchDay('d').first).first;
    expect(updated.grams, 20);
    expect(updated.servingCount, 2);
    expect(updated.nutr.kcal, closeTo(96, 0.1));
  });

  test('setServingCount steps grams by per-serve weight', () async {
    final entry = await repo.add(
      day: 'd',
      meal: MealType.snack,
      food: food('Crackers', kcal: 500),
      grams: 30,
      unit: 'serving',
      servingCount: 3,
      servingGrams: 10,
      servingLabel: '1 cracker (10 g)',
    );

    await repo.setServingCount(entry, 4);
    final updated = (await repo.watchDay('d').first).first;
    expect(updated.grams, 40);
    expect(updated.servingCount, 4);
    expect(updated.nutr.kcal, closeTo(200, 0.1));
  });

  test('deleteMany removes all listed entries', () async {
    final a = await repo.add(
        day: 'd', meal: MealType.snack, food: food('A'), grams: 100);
    final b = await repo.add(
        day: 'd', meal: MealType.snack, food: food('B'), grams: 100);
    await repo.add(
        day: 'd', meal: MealType.snack, food: food('C'), grams: 100);

    await repo.deleteMany([a.id, b.id]);
    final day = await repo.watchDay('d').first;
    expect(day.map((e) => e.name), ['C']);
  });

  test('restore appends at the end of the section', () async {
    final a = await repo.add(
        day: 'd', meal: MealType.snack, food: food('A'), grams: 100);
    await repo.add(
        day: 'd', meal: MealType.snack, food: food('B'), grams: 100);
    await repo.delete(a.id);

    await repo.restore(a);
    final day = await repo.watchDay('d').first;
    expect(day.map((e) => e.name), ['B', 'A']);
    expect(day.last.sortOrder, greaterThan(day.first.sortOrder));
  });

  test('fresh schema is v6 with serving + recipe qty + activity tables',
      () async {
    final v = await db.customSelect('PRAGMA user_version').getSingle();
    expect(v.data['user_version'], 6);

    final cols = await db
        .customSelect('PRAGMA table_info(log_entries)')
        .get();
    final names = cols.map((c) => c.data['name']).toSet();
    expect(names, containsAll([
      'serving_count',
      'serving_grams',
      'serving_label',
      'sort_order',
    ]));

    final rcols = await db
        .customSelect('PRAGMA table_info(recipe_items)')
        .get();
    final rnames = rcols.map((c) => c.data['name']).toSet();
    expect(rnames, containsAll(['qty', 'unit']));

    final acols =
        await db.customSelect('PRAGMA table_info(activities)').get();
    expect(
        acols.map((c) => c.data['name']).toSet(),
        containsAll([
          'id',
          'name',
          'category',
          'met',
          'met_older_adult',
          'search_text',
          'is_favorite',
          'is_custom',
        ]));

    final ecols =
        await db.customSelect('PRAGMA table_info(exercise_entries)').get();
    expect(
        ecols.map((c) => c.data['name']).toSet(),
        containsAll([
          'id',
          'day',
          'activity_id',
          'minutes',
          'weight_kg',
          'kcal',
          'manual_kcal',
          'created_at',
        ]));
  });
}
