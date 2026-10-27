import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the condensed activity catalog: size, id stability, short
/// metric-only display names, and load-bearing Compendium reference values
/// (MET typos change kcal).
void main() {
  test('activities.json is a valid condensed catalog', () {
    final raw = File('assets/seed/activities.json').readAsStringSync();
    final doc = jsonDecode(raw) as Map<String, dynamic>;
    final list = (doc['activities'] as List).cast<Map<String, dynamic>>();

    expect(list.length, greaterThanOrEqualTo(80));

    final ids = list.map((a) => a['i'] as String).toList();
    expect(ids.toSet().length, ids.length, reason: 'duplicate ids');

    final imperial = RegExp(
        r'mph|mile|pounds?|\blbs?\b|inch|feet|\bfoot\b|yard|watts?|taylor|&amp|  ',
        caseSensitive: false);
    for (final a in list) {
      final name = a['n'] as String;
      expect(name.isNotEmpty, isTrue);
      expect(name.length, lessThanOrEqualTo(48),
          reason: 'too long: $name');
      expect(imperial.hasMatch(name), isFalse,
          reason: 'imperial/artifact: $name');
      expect((a['m'] as num).toDouble(), greaterThan(0));
      final o = (a['o'] as num?)?.toDouble();
      if (o != null) expect(o, greaterThan(0));
    }

    double metOf(String name) => (list
            .firstWhere((a) => a['n'] == name)['m'] as num)
        .toDouble();

    // Sourced anchors: condensed rows inherit their compendium values.
    expect(metOf('Running (10 km/h)'), 9.8);
    expect(metOf('Mowing (push mower)'), 5.5);
    expect(metOf('Swimming (moderate laps)'), 5.8);
    expect(metOf('Yoga'), 2.5);
    expect(metOf('Wii Fit (easy / balance games)'), 2.3);
    expect(metOf('Wii Fit (moderate / aerobic games)'), 3.8);

    // Mother-critical rows exist with OA values.
    final gardenEasy = list.firstWhere(
        (a) => a['n'] == 'Gardening (easy / weeding, potting)');
    expect(gardenEasy['o'], isNotNull);
    expect(
        list.any((a) =>
            (a['c'] as String) == 'Garden & Lawn' &&
            (a['o'] as num?) != null),
        isTrue,
        reason: 'need OA-valued gardening rows');

    // Exergaming granularity (easy vs moderate).
    expect(
        list
            .where((a) => (a['c'] as String) == 'Exergaming')
            .length,
        greaterThanOrEqualTo(3));
  });
}
