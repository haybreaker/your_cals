import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:your_cals/domain/food.dart';
import 'package:your_cals/domain/nutriments.dart';
import 'package:your_cals/state/providers.dart';
import 'package:your_cals/ui/diary/diary_page.dart';

LogEntry _entry(String name) => LogEntry(
      id: 'e-$name',
      day: '2026-09-03',
      meal: MealType.breakfast,
      foodId: 'f-$name',
      name: name,
      brand: '',
      source: FoodSource.custom,
      grams: 100,
      unit: 'g',
      nutr: const Nutriments(kcal: 150),
      createdAt: DateTime(2026),
    );

void main() {
  test('selection controller: toggleAndEnter / toggle / exit semantics', () {
    final c = DiarySelectionController();

    // Hold on A from normal → A selected, multi-select on.
    c.toggleAndEnter('a');
    expect(c.state.isMultiSelect, isTrue);
    expect(c.state.selectedIds, {'a'});

    // Hold on B while selecting → B added.
    c.toggleAndEnter('b');
    expect(c.state.selectedIds, {'a', 'b'});

    // Hold on A again → removed (but selection continues).
    c.toggleAndEnter('a');
    expect(c.state.selectedIds, {'b'});

    // toggle only works in multi-select.
    c.exit();
    expect(c.state.mode, DiaryListMode.normal);
    c.toggle('a');
    expect(c.state.selectedIds, isEmpty);

    // exitIfMultiSelect is a no-op in normal mode.
    c.exitIfMultiSelect();
    expect(c.state.mode, DiaryListMode.normal);
  });

  testWidgets('hold-and-lift selects the tile; taps toggle the checkmark',
      (tester) async {
    final entry = _entry('Toast');

    late ProviderContainer container;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return EntryTile(
                  key: ValueKey(entry.id),
                  entry: entry,
                  sectionEntries: [entry],
                );
              },
            ),
          ),
        ),
      ),
    );
    final element = tester.element(find.byType(EntryTile));
    container = ProviderScope.containerOf(element);

    final tile = find.byWidgetPredicate((w) => w is EntryTile);

    // Long-press hold (no movement), lift → multi-select, tile checked.
    final gesture = await tester.startGesture(tester.getCenter(tile));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 150));
    await gesture.up();
    await tester.pumpAndSettle();

    var state = container.read(diarySelectionProvider);
    expect(state.isMultiSelect, isTrue);
    expect(state.selectedIds, {entry.id});
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    // Tap → deselected (still in multi-select).
    await tester.tap(tile, warnIfMissed: false);
    await tester.pumpAndSettle();
    state = container.read(diarySelectionProvider);
    expect(state.selectedIds, isEmpty);
    expect(state.isMultiSelect, isTrue);
    expect(find.byIcon(Icons.check_rounded), findsNothing);

    // Tap again → re-selected.
    await tester.tap(tile, warnIfMissed: false);
    await tester.pumpAndSettle();
    state = container.read(diarySelectionProvider);
    expect(state.selectedIds, {entry.id});

    // Done → back to normal.
    container.read(diarySelectionProvider.notifier).exit();
    await tester.pumpAndSettle();
    state = container.read(diarySelectionProvider);
    expect(state.mode, DiaryListMode.normal);
  });

  testWidgets('deliberate drag cancels selection instead of selecting',
      (tester) async {
    final entry = _entry('Toast');

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: EntryTile(
              key: ValueKey(entry.id),
              entry: entry,
              sectionEntries: [entry],
            ),
          ),
        ),
      ),
    );
    final element = tester.element(find.byType(EntryTile));
    final container = ProviderScope.containerOf(element);

    final tile = find.byWidgetPredicate((w) => w is EntryTile);

    // Long-press, then DRAG a long distance (>24px), lift.
    final gesture = await tester.startGesture(tester.getCenter(tile));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 150));
    await gesture.moveBy(const Offset(0, 300));
    await tester.pump(const Duration(milliseconds: 150));
    await gesture.up();
    await tester.pumpAndSettle();

    final state = container.read(diarySelectionProvider);
    expect(state.mode, DiaryListMode.normal,
        reason: 'a deliberate drag must not enter multi-select');
    expect(state.selectedIds, isEmpty);
  });
}
