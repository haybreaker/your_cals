import 'package:flutter_test/flutter_test.dart';
import 'package:your_cals/ui/recipes/recipes_page.dart'
    show mergeManualOrder;

void main() {
  group('mergeManualOrder (custom recipe order)', () {
    test('null local passes incoming through as a copy', () {
      final incoming = ['a', 'b', 'c'];
      final out = mergeManualOrder(null, incoming);
      expect(out, ['a', 'b', 'c']);
      expect(identical(out, incoming), isFalse);
    });

    test('keeps manual relative order', () {
      expect(
        mergeManualOrder(['c', 'a', 'b'], ['a', 'b', 'c']),
        ['c', 'a', 'b'],
      );
    });

    test('appends brand-new ids at the end', () {
      expect(
        mergeManualOrder(['b', 'a'], ['a', 'b', 'c']),
        ['b', 'a', 'c'],
      );
    });

    test('drops deleted ids', () {
      expect(
        mergeManualOrder(['c', 'gone', 'a'], ['a', 'b', 'c']),
        ['c', 'a', 'b'],
      );
    });
  });
}
