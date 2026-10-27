import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:your_cals/data/db/database.dart';
import 'package:your_cals/data/repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seed import loads all bundled foods', () async {
    final db = AppDatabase.withExecutor(
      NativeDatabase.memory(),
    );
    final repo = FoodRepository(db);
    final settings = SettingsRepository(db);
    final importer = SeedImporter(repo, settings);

    final chainCount = await importer.importChainPack();
    expect(chainCount, 135);

    // FSANZ seed
    final seedCount = await importer.importBundledJson();
    expect(seedCount, greaterThan(5000));

    // OFF AU/NZ catalog (~68k) — the heavy one.
    final offCount = await importer.importOffCatalog();
    expect(offCount, greaterThan(60000));

    final total = await db.select(db.foods).get();
    expect(total.length, chainCount + seedCount + offCount);

    // Micros + liquid flag must actually persist through the companion.
    final liquids = await db.customSelect(
        'SELECT * FROM foods WHERE liquid = 1 LIMIT 50').get();
    expect(liquids, isNotEmpty, reason: 'catalog should contain beverages');

    final withVitC = await db.customSelect(
        'SELECT * FROM foods WHERE vit_c_mg > 0 LIMIT 200').get();
    expect(withVitC.length, greaterThan(100),
        reason: 'FSANZ foods carry vitamin C');

    await db.close();
  });
}

void microsSmoke() {
  // sanity: orange juice from catalog should be liquid with vitC
}
