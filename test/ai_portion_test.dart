import 'package:flutter_test/flutter_test.dart';
import 'package:your_cals/core/format.dart';
import 'package:your_cals/data/ai/gemini_client.dart';
import 'package:your_cals/domain/nutriments.dart';
import 'package:your_cals/domain/portion.dart';
import 'package:your_cals/state/providers.dart';

DetectedItem _item({double grams = 100}) => DetectedItem(
      name: 'Grilled salmon',
      grams: grams,
      confidence: 0.9,
      per100: const Nutriments(kcal: 200, proteinG: 20, carbsG: 0, fatG: 12),
    );

void main() {
  group('formatQty/parseQty (2dp inputs)', () {
    test('trims trailing zeros', () {
      expect(formatQty(2), '2');
      expect(formatQty(1.5), '1.5');
      expect(formatQty(1.50), '1.5');
      expect(formatQty(0.125), '0.13');
    });

    test('parses dot and comma decimals', () {
      expect(parseQty('1.5'), 1.5);
      expect(parseQty('1,5'), 1.5);
      expect(parseQty('abc'), isNull);
      expect(parseQty('-3'), isNull);
    });
  });

  group('NutrimentsLike scales AI items with edited grams (Bug 1)', () {
    test('AI-only kcal doubles when grams double', () {
      final detected = _item(grams: 100);
      expect(NutrimentsLike(null, detected, 100).kcal, 200);
      expect(NutrimentsLike(null, detected, 200).kcal, 400);
      expect(NutrimentsLike(null, detected, 200).protein, 40);
    });
  });

  group('PendingItem portion edits stay immutable', () {
    test('copyWith preserves the detected item and updates grams', () {
      final original = PendingItem(
        detected: _item(),
        grams: 100,
        matchedFood: null,
      );
      final edited = original.copyWith(
        grams: PortionMath.resolveGrams(
          unit: PortionUnit.serving,
          qty: 1.5,
          servingGrams: 200,
        ),
        qty: 1.5,
        unit: PortionUnit.serving,
      );
      expect(original.grams, 100); // untouched
      expect(edited.grams, 300);
      expect(edited.nutr.kcal, 600);
    });
  });
}
