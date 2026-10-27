import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:your_cals/data/db/database.dart';
import 'package:your_cals/data/repositories.dart';
import 'package:your_cals/domain/food.dart';
import 'package:your_cals/domain/nutriments.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late RecipeRepository repo;

  setUp(() async {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repo = RecipeRepository(db);
  });

  tearDown(() => db.close());

  RecipeIngredient ing(
    String name, {
    String foodId = 'f:x',
    double grams = 100,
    double kcalPer100 = 100,
    double qty = 100,
    String unit = 'g',
  }) =>
      RecipeIngredient(
        foodId: foodId,
        name: name,
        brand: '',
        grams: grams,
        per100: Nutriments(kcal: kcalPer100),
        qty: qty,
        unit: unit,
      );

  test('qty/unit round-trips through save/byId', () async {
    final id = await repo.save(
      existingId: null,
      name: 'Sauce',
      servings: 2,
      ingredients: [
        ing('Olive oil', grams: 30, kcalPer100: 800, qty: 2, unit: 'tbsp'),
      ],
    );
    final loaded = await repo.byId(id);
    expect(loaded, isNotNull);
    final line = loaded!.ingredients.single;
    expect(line.qty, 2);
    expect(line.unit, 'tbsp');
    expect(line.grams, 30);
  });

  test('nested totals resolve live when child changes', () async {
    final sauceId = await repo.save(
      existingId: null,
      name: 'Mince sauce',
      servings: 2,
      ingredients: [ing('Beef', grams: 200, kcalPer100: 200)],
    );
    // Sauce total 400 kcal, 200 g → per100 200 kcal.
    final sauceFood = await repo.recipeAsFood(sauceId);
    expect(sauceFood!.per100.kcal, closeTo(200, 0.5));

    final bolId = await repo.save(
      existingId: null,
      name: 'Bolognese',
      servings: 2,
      ingredients: [
        RecipeIngredient(
          foodId: 'recipe:$sauceId',
          name: 'Mince sauce',
          brand: '',
          // 1 serving of sauce = 100 g (sauce is 200 g / 2 serves).
          grams: 100,
          per100: sauceFood.per100,
          qty: 1,
          unit: 'serving',
        ),
        ing('Pasta', grams: 100, kcalPer100: 150),
      ],
    );
    var bol = await repo.byId(bolId);
    // 200 (sauce serving) + 150 (pasta) = 350 total.
    expect(bol!.total.kcal, closeTo(350, 0.5));

    // Enrich the sauce (same weight, richer beef) → parent follows live.
    // Sauce per100 goes 200 → 400, so the 100 g portion goes 200 → 400.
    await repo.save(
      existingId: sauceId,
      name: 'Mince sauce',
      servings: 2,
      ingredients: [ing('Beef', grams: 200, kcalPer100: 400)],
    );
    bol = await repo.byId(bolId);
    expect(bol!.total.kcal, closeTo(550, 0.5));
  });

  test('matching recipes survive catalog limits and rank first', () async {
    final foodRepo = FoodRepository(db);
    // Flood the catalog with OFF matches so a naive LIMIT 40 would bury us.
    await foodRepo.upsertFoods(List.generate(
      45,
      (i) => Food(
        id: 'off:bolognese-$i',
        name: 'Bolognese Sauce Can $i',
        brand: 'Brand $i',
        source: FoodSource.off,
        per100: const Nutriments(kcal: 80),
      ),
    ));
    final sauceId = await repo.save(
      existingId: null,
      name: 'Bolognese',
      servings: 2,
      ingredients: [ing('Beef', grams: 200, kcalPer100: 200)],
    );
    final results = await foodRepo.search('Bolognese');
    expect(results.map((f) => f.id), contains('recipe:$sauceId'));
    expect(results.first.id, 'recipe:$sauceId');
  });

  test('self reference and indirect loops are rejected', () async {
    final aId = await repo.save(
      existingId: null,
      name: 'A',
      servings: 1,
      ingredients: [ing('X', grams: 50)],
    );
    final bId = await repo.save(
      existingId: null,
      name: 'B',
      servings: 1,
      ingredients: [
        RecipeIngredient(
          foodId: 'recipe:$aId',
          name: 'A',
          brand: '',
          grams: 50,
          per100: const Nutriments(kcal: 100),
          qty: 1,
          unit: 'serving',
        ),
      ],
    );

    // Direct self-include.
    expect(
      () => repo.save(
        existingId: aId,
        name: 'A',
        servings: 1,
        ingredients: [
          RecipeIngredient(
            foodId: 'recipe:$aId',
            name: 'A',
            brand: '',
            grams: 50,
            per100: const Nutriments(kcal: 100),
          ),
        ],
      ),
      throwsA(isA<StateError>()),
    );

    // Indirect A → B → A loop.
    expect(
      () => repo.save(
        existingId: aId,
        name: 'A',
        servings: 1,
        ingredients: [
          RecipeIngredient(
            foodId: 'recipe:$bId',
            name: 'B',
            brand: '',
            grams: 50,
            per100: const Nutriments(kcal: 100),
          ),
        ],
      ),
      throwsA(isA<StateError>()),
    );
  });
}
