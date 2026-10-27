import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:your_cals/data/db/database.dart';
import 'package:your_cals/data/repositories.dart';
import 'package:your_cals/domain/food.dart';
import 'package:your_cals/domain/nutriments.dart';

Food _food(
  String id,
  String name, {
  String brand = '',
  FoodSource source = FoodSource.ausnut,
}) => Food(
  id: id,
  name: name,
  brand: brand,
  source: source,
  per100: const Nutriments(kcal: 100, proteinG: 10),
);

/// 150 FSANZ-style generics that all match "high" AND "protein".
/// Under the old OR + LIMIT 120 ordered by favourite, these buried the
/// OFF Musashi row (imported last) before in-memory ranking ever saw it.
List<Food> _distractors() => [
  for (var i = 0; i < 150; i++)
    _food('fsanz:$i', 'Bar, high protein, flavour $i'),
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late FoodRepository repo;

  setUp(() async {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    repo = FoodRepository(db);
    await repo.upsertFoods([
      ..._distractors(),
      _food(
        'off:9314549902208',
        'High Protein',
        brand: 'MUSASHI',
        source: FoodSource.off,
      ),
      _food('chain:white-toast', 'White Toast Bread', brand: 'Tip Top'),
      _food(
        'chain:mcd-fish',
        'Fish Hamburger',
        brand: "McDonald's",
        source: FoodSource.chain,
      ),
      _food('ausnut:hamburger', 'Hamburger'),
      _food('ausnut:pink-lady', 'Apple, pink lady, unpeeled, raw'),
      _food(
        'off:apple-juice',
        'Apple Juice',
        brand: 'Golden Circle',
        source: FoodSource.off,
      ),
    ]);
  });

  tearDown(() async => db.close());

  test('High Protein surfaces the OFF Musashi row, not just FSANZ', () async {
    final res = await repo.search('High Protein');
    final idx = res.indexWhere((f) => f.id == 'off:9314549902208');
    expect(idx, isNot(-1), reason: 'OFF Musashi must be in the results');
    expect(idx, lessThan(5), reason: 'OFF Musashi must rank near the top');
  });

  test('High Protein - MUSASHI finds the exact branded row', () async {
    final res = await repo.search('High Protein - MUSASHI');
    expect(res, isNotEmpty);
    expect(res.first.id, 'off:9314549902208');
  });

  test('extra word never zeroes results (white toast bread loaf)', () async {
    final res = await repo.search('white toast bread loaf');
    expect(
      res.map((f) => f.id),
      contains('chain:white-toast'),
    );
  });

  test('mcdonalds hamburger prefers the chain row over generic', () async {
    final res = await repo.search('mcdonalds hamburger');
    expect(res, isNotEmpty);
    expect(res.first.id, 'chain:mcd-fish');
  });

  test('pink lady apples prefers the FSANZ row on text alone', () async {
    final res = await repo.search('pink lady apples');
    expect(res, isNotEmpty);
    expect(res.first.id, 'ausnut:pink-lady');
  });
}
