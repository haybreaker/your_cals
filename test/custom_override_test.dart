import 'package:flutter_test/flutter_test.dart';
import 'package:your_cals/data/ai/gemini_client.dart';
import 'package:your_cals/data/repositories.dart';
import 'package:your_cals/data/search/relevance.dart';
import 'package:your_cals/domain/food.dart';
import 'package:your_cals/domain/nutriments.dart';

Food _f(
  String id,
  String name, {
  String brand = '',
  FoodSource source = FoodSource.off,
}) {
  return Food(
    id: id,
    name: name,
    brand: brand,
    source: source,
    per100: const Nutriments(kcal: 100, proteinG: 5),
  );
}

void main() {
  group('custom copy shadows OFF in search', () {
    test('rankWithHistory prefers custom over identical OFF text', () {
      final off = _f('off:1', 'Chicken Stock', source: FoodSource.off);
      final custom = _f('custom:1', 'Chicken Stock',
          source: FoodSource.custom);
      final tokens = Relevance.tokenize('chicken stock');
      final sOff = FoodRepository.rankWithHistory(
          off, tokens, const {}, const {}, 'chicken stock');
      final sCustom = FoodRepository.rankWithHistory(
          custom, tokens, const {}, const {}, 'chicken stock');
      // Exact query puts both in the exact tier; the tiebreak (not the
      // score) prefers the custom copy.
      expect(
        FoodRepository.compareFoods(custom, off, sCustom, sOff),
        lessThan(0),
      );
    });

    test('rankWithHistory custom bonus stays below history/recipe tiers', () {
      final custom = _f('custom:1', 'Bolognese Special Mix',
          source: FoodSource.custom);
      final recipe = _f('recipe:1', 'Bolognese Special Mix',
          source: FoodSource.recipe);
      const q = 'bolognese special';
      final t = Relevance.tokenize(q);
      final sCustom =
          FoodRepository.rankWithHistory(custom, t, const {}, const {}, q);
      final sRecipe =
          FoodRepository.rankWithHistory(recipe, t, const {}, const {}, q);
      expect(sRecipe, greaterThan(sCustom));
    });

    test('rankFood stays source-blind (no custom bias in pure relevance)',
        () {
      const t = ['bolognese'];
      final custom = _f('c', 'Bolognese', source: FoodSource.custom);
      final off = _f('o', 'Bolognese', source: FoodSource.off);
      expect(FoodRepository.rankFood(custom, t),
          FoodRepository.rankFood(off, t));
    });
  });

  group('parseLabelNutrition', () {
    test('parses per-100 panel', () {
      final data = {
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text':
                      '{"has_panel": true, "product_name": "Oats", "brand": "Uncle", '
                      '"serving_size": 40, "serving_unit": "g", "is_liquid": false, '
                      '"energy_kcal_per_100g": 350, "protein_g_per_100g": 12, '
                      '"fat_g_per_100g": 6, "sat_fat_g_per_100g": 1, '
                      '"carbs_g_per_100g": 60, "sugars_g_per_100g": 2, '
                      '"fiber_g_per_100g": 8, "sodium_mg_per_100g": 5}'
                }
              ]
            }
          }
        ]
      };
      final label = GeminiClient.parseLabelNutrition(data);
      expect(label.productName, 'Oats');
      expect(label.per100.kcal, 350);
      expect(label.per100.proteinG, 12);
      expect(label.servingSize, 40);
      expect(label.servingUnit, 'g');
    });

    test('converts kJ-as-kcal slips', () {
      final data = {
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'text':
                      '{"has_panel": true, "energy_kcal_per_100g": 4184, '
                      '"protein_g_per_100g": 1}'
                }
              ]
            }
          }
        ]
      };
      final label = GeminiClient.parseLabelNutrition(data);
      expect(label.per100.kcal, closeTo(1000, 0.5));
    });

    test('throws when no panel', () {
      final data = {
        'candidates': [
          {
            'content': {
              'parts': [
                {'text': '{"has_panel": false, "energy_kcal_per_100g": 0}'}
              ]
            }
          }
        ]
      };
      expect(() => GeminiClient.parseLabelNutrition(data),
          throwsA(isA<GeminiException>()));
    });
  });
}
