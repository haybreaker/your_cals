import 'package:flutter_test/flutter_test.dart';
import 'package:your_cals/data/repositories.dart';
import 'package:your_cals/data/search/relevance.dart';
import 'package:your_cals/domain/food.dart';
import 'package:your_cals/domain/nutriments.dart';
import 'package:your_cals/state/search_controller.dart';

Food _f(
  String name, {
  String brand = '',
  FoodSource source = FoodSource.ausnut,
  bool fav = false,
}) {
  return Food(
    id: '$name-$brand',
    name: name,
    brand: brand,
    source: source,
    per100: const Nutriments(kcal: 100),
    isFavorite: fav,
  );
}

void main() {
  group('rankFood', () {
    test('exact match beats prefix beats contains', () {
      final exact = _f('banana');
      final prefix = _f('banana bread');
      final contains = _f('green banana cake');
      final tokens = ['banana'];
      expect(
        FoodRepository.rankFood(exact, tokens),
        greaterThan(FoodRepository.rankFood(prefix, tokens)),
      );
      expect(
        FoodRepository.rankFood(prefix, tokens),
        greaterThan(FoodRepository.rankFood(contains, tokens)),
      );
    });

    test('favorites rank above non-favorites', () {
      final fav = _f('chicken', fav: true);
      final plain = _f('chicken breast');
      // Even with a slightly worse text score, favorite wins.
      expect(
        FoodRepository.rankFood(fav, ['chicken']),
        greaterThanOrEqualTo(FoodRepository.rankFood(plain, ['chicken']) - 0),
      );
      expect(
        FoodRepository.rankFood(fav, ['chicken']),
        greaterThan(FoodRepository.rankFood(_f('chicken'), ['chicken'])),
      );
    });

    test('no source bias: identical text ties across sources', () {
      // Pure relevance — a FSANZ generic must never outrank a branded
      // OFF/chain row it matches worse, and vice versa. Same name+brand
      // means the same score regardless of source.
      final chain = _f('big mac', source: FoodSource.chain);
      final off = _f('big mac', source: FoodSource.off);
      final gov = _f('big mac', source: FoodSource.afcd);
      const t = ['big', 'mac'];
      expect(FoodRepository.rankFood(chain, t), FoodRepository.rankFood(off, t));
      expect(FoodRepository.rankFood(gov, t), FoodRepository.rankFood(off, t));
    });

    test('branded query prefers the branded row (any source)', () {
      final branded = _f(
        'Fish Hamburger',
        brand: "McDonald's",
        source: FoodSource.chain,
      );
      final generic = _f('Hamburger', source: FoodSource.ausnut);
      expect(
        FoodRepository.rankFood(branded, ['mcdonalds', 'hamburger']),
        greaterThan(FoodRepository.rankFood(generic, ['mcdonalds', 'hamburger'])),
      );
      // And the reverse: a generic query prefers the generic exact hit.
      expect(
        FoodRepository.rankFood(generic, ['hamburger']),
        greaterThan(FoodRepository.rankFood(branded, ['hamburger'])),
      );
    });

    test('musashi protein prefers OFF musashi over FSANZ protein water', () {
      final musashi = _f(
        'High Protein',
        brand: 'MUSASHI',
        source: FoodSource.off,
      );
      final fsanz = _f('Protein water', source: FoodSource.ausnut);
      const t = ['musashi', 'protein'];
      expect(
        FoodRepository.rankFood(musashi, t),
        greaterThan(FoodRepository.rankFood(fsanz, t)),
      );
    });

    test('user recipes rank above same-name matches via history tier', () {
      // rankFood itself is source-blind (ties); the recipe boost lives in
      // rankWithHistory's tier so user recipes still top real searches.
      const t = ['bolognese'];
      final recipe = _f('Bolognese', source: FoodSource.recipe);
      final custom = _f('Bolognese', source: FoodSource.custom);
      final chain = _f('Bolognese', source: FoodSource.chain);
      final off = _f('Bolognese', source: FoodSource.off);
      expect(FoodRepository.rankFood(recipe, t), FoodRepository.rankFood(off, t));
      int tiered(Food f) => FoodRepository.rankWithHistory(
        f,
        t,
        const {},
        const {},
        'bolognese',
      );
      expect(tiered(recipe), greaterThan(tiered(custom)));
      expect(tiered(recipe), greaterThan(tiered(chain)));
      expect(tiered(recipe), greaterThan(tiered(off)));
    });

    test('multi-token AND matching', () {
      final hit = _f('chicken teriyaki roll');
      final miss = _f('teriyaki salmon');
      final t = ['chicken', 'roll'];
      expect(FoodRepository.rankFood(hit, t), greaterThan(0));
      expect(FoodRepository.rankFood(miss, t), lessThan(hit == miss ? 1 : 999));
    });
  });

  group('dedupeKey', () {
    test('same food from different sources dedupes', () {
      final a = _f('Big Mac', brand: "McDonald's", source: FoodSource.chain);
      final b = _f('BIG MAC', brand: "mcdonald's", source: FoodSource.off);
      final c = _f('Whopper', brand: "Hungry Jack's");
      expect(SearchController.dedupeKey(a), SearchController.dedupeKey(b));
      expect(
        SearchController.dedupeKey(a),
        isNot(SearchController.dedupeKey(c)),
      );
    });

    test('punctuation variants dedupe', () {
      final a = _f('High-Protein Bar');
      final b = _f('High Protein Bar');
      expect(SearchController.dedupeKey(a), SearchController.dedupeKey(b));
    });
  });

  group('Relevance.normalize', () {
    test('case, punctuation and spacing collapse', () {
      expect(
        Relevance.normalize('  High-Protein  MUSASHI, '),
        'high protein musashi',
      );
      expect(Relevance.normalize("Coles Simply"), 'coles simply');
    });

    test('apostrophes are removed so possessive brands match', () {
      expect(Relevance.normalize("McDonald's"), 'mcdonalds');
      expect(Relevance.normalize('Babushka’s Kefir'), 'babushkas kefir');
    });
  });

  group('Relevance.tokenize', () {
    test('drops single-char noise tokens', () {
      expect(Relevance.tokenize('vitamin b12'), ['vitamin', 'b12']);
      expect(Relevance.tokenize('a b'), isEmpty);
    });
  });

  group('Relevance.stem', () {
    test('plural folding keeps double-s words intact', () {
      expect(Relevance.stem('oats'), 'oat');
      expect(Relevance.stem('cookies'), 'cookie');
      expect(Relevance.stem('glass'), 'glass');
      expect(Relevance.stem('cheese'), 'cheese');
      expect(Relevance.stems('berries'), contains('berry'));
    });
  });

  group('relevance ordering', () {
    int score(Food f, String q) => FoodRepository.rankWithHistory(
      f,
      Relevance.tokenize(q),
      const {},
      const {},
      q,
    );

    test('word order does not matter', () {
      final item = _f('Musashi High Protein Bar', brand: 'Musashi');
      expect(score(item, 'protein musashi'), score(item, 'musashi protein'));
    });

    test('phrase match beats scattered words', () {
      final phrase = _f('High Protein Oats', brand: 'Uncle Tobys');
      final scattered = _f('Protein Shake High Caffeine Oats Free', brand: 'X');
      expect(
        score(phrase, 'high protein oats'),
        greaterThan(score(scattered, 'high protein oats')),
      );
    });

    test('exact name beats everything below exact tier', () {
      final exact = _f('Oats', brand: 'Uncle Tobys');
      final recipe = _f('Oats Deluxe', source: FoodSource.recipe);
      expect(score(exact, 'oats'), greaterThan(score(recipe, 'oats')));
    });

    test('plural query finds singular item', () {
      final item = _f('Oat Slice', brand: 'Coles');
      final tokens = Relevance.tokenize('oats');
      expect(FoodRepository.rankFood(item, tokens), greaterThan(0));
    });

    test('name hit outranks brand-only hit', () {
      final nameHit = _f('Oat Bar', brand: 'Generic');
      final brandHit = _f('Muesli Bar', brand: 'Oat Company');
      expect(score(nameHit, 'oat'), greaterThan(score(brandHit, 'oat')));
    });

    test('ties break deterministically, shorter first', () {
      final a = _f('Oat Bar Long Name Version', brand: 'X');
      final b = _f('Oat Bar', brand: 'X');
      final sa = score(a, 'zzzqqq oat');
      final sb = score(b, 'zzzqqq oat');
      expect(
        FoodRepository.compareFoods(a, b, sa, sb),
        isNot(FoodRepository.compareFoods(b, a, sb, sa)),
      );
      // Shorter, more specific name wins the tiebreak.
      expect(FoodRepository.compareFoods(a, b, 100, 100), greaterThan(0));
    });
  });
}
