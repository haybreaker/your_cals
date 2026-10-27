import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:your_cals/data/db/database.dart';
import 'package:your_cals/data/repositories.dart';
import 'package:your_cals/domain/activity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ActivityRepository activities;
  late ExerciseRepository repo;

  const gardening = Activity(
    id: 'act_garden',
    name: 'Gardening, general',
    category: 'Garden & Lawn',
    met: 3.8,
    metOlderAdult: 4.1,
  );

  setUp(() async {
    db = AppDatabase.withExecutor(NativeDatabase.memory());
    activities = ActivityRepository(db);
    repo = ExerciseRepository(db);
    await activities.upsertActivity(gardening);
  });

  tearDown(() => db.close());

  test('add snapshots MET burn with logging-day weight/age', () async {
    // 3.8 MET x 70 kg x 3 h = 798.
    final e = await repo.add(
      day: '2026-09-03',
      activity: gardening,
      minutes: 180,
      weightKg: 70,
      ageYears: 40,
    );
    expect(e.kcal, closeTo(798, 1));
    expect(e.metUsed, 3.8);
    expect(e.effectiveKcal, closeTo(798, 1));
    expect(e.sortOrder, 0);

    final day = await repo.watchDay('2026-09-03').first;
    expect(day.length, 1);
    expect(day.first.name, 'Gardening, general');
  });

  test('older adults snapshot the OA-adjusted burn', () async {
    // 4.1 MET60+ x 0.810 x 70 kg x 1 h = ~232.5.
    final e = await repo.add(
      day: '2026-09-03',
      activity: gardening,
      minutes: 60,
      weightKg: 70,
      ageYears: 65,
    );
    expect(e.kcal, closeTo(232.5, 1));
    expect(e.metUsed, 4.1);
  });

  test('manual override wins; retiming rescales the estimate only', () async {
    final e = await repo.add(
      day: '2026-09-03',
      activity: gardening,
      minutes: 60,
      weightKg: 70,
      ageYears: 40,
      manualKcal: 400,
    );
    expect(e.effectiveKcal, 400);

    await repo.updateMinutes(e, 120);
    final day = await repo.watchDay('2026-09-03').first;
    // Estimate doubled (266 -> 532) but the watch number stays truth.
    expect(day.first.kcal, closeTo(532, 1));
    expect(day.first.effectiveKcal, 400);

    await repo.setOverride(e, null);
    final cleared = await repo.watchDay('2026-09-03').first;
    expect(cleared.first.effectiveKcal, closeTo(532, 1));
  });

  test('delete + restore round-trips for undo', () async {
    final e = await repo.add(
      day: '2026-09-03',
      activity: gardening,
      minutes: 30,
      weightKg: 70,
      ageYears: 40,
    );
    await repo.delete(e.id);
    expect(await repo.watchDay('2026-09-03').first, isEmpty);
    await repo.restore(e);
    final day = await repo.watchDay('2026-09-03').first;
    expect(day.length, 1);
    expect(day.first.minutes, 30);
  });

  test('historyDistinct surfaces logged activities (history tab)', () async {
    expect(await activities.historyDistinct(), isEmpty);
    await repo.add(
      day: '2026-09-03',
      activity: gardening,
      minutes: 30,
      weightKg: 70,
      ageYears: 40,
    );
    await repo.add(
      day: '2026-09-03',
      activity: gardening,
      minutes: 60,
      weightKg: 70,
      ageYears: 40,
    );
    final history = await activities.historyDistinct();
    expect(history.length, 1);
    expect(history.first.activity.id, 'act_garden');
    expect(history.first.count, 2);
  });

  test('favorites survive catalog upserts', () async {
    await activities.setFavorite('act_garden', true);
    // Seed refresh rewrites the same row.
    await activities.upsertActivity(gardening);
    final favs = await activities.watchFavorites().first;
    expect(favs.map((a) => a.id), ['act_garden']);
  });

  test('search matches name and category, favorites first', () async {
    await activities.upsertActivity(const Activity(
      id: 'act_run',
      name: 'Running, 6 mph',
      category: 'Running',
      met: 9.8,
    ));
    await activities.setFavorite('act_run', true);
    final hits = await activities.search('run');
    expect(hits.map((a) => a.id), ['act_run']);
    final garden = await activities.search('garden lawn');
    expect(garden.map((a) => a.id), ['act_garden']);
  });
}
