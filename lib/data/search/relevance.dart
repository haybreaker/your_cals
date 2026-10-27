import 'dart:math' as math;

/// Shared text-relevance machinery for food + activity search.
///
/// Industry consensus (MFP "Best Match", Lose It! blends, Cronometer):
/// rank by word-similarity × personal log frequency × source trust.
/// This file owns the similarity half as pure, unit-tested functions;
/// the repositories layer tiers + frequency on top.
///
/// Design notes:
/// - Matching is bag-of-words (order-independent) with a bonus when the
///   full phrase appears in order — "protein musashi" ≡ "musashi protein".
/// - Everything is normalized (case, punctuation) so "High Protein
///   MUSASHI", "high-protein musashi" and "musashi high protein" all hit.
/// - Plural folding is stem-lite (trailing-s strip): "oats" ↔ "oat".
/// - Scores are ints; higher = better. Point values preserve the legacy
///   rankFood ordering (exact > starts-with > word-start > contains).
abstract final class Relevance {
  /// Lowercase, punctuation → space, collapse whitespace.
  /// Apostrophes are REMOVED not spaced ("McDonald's" → "mcdonalds",
  /// not "mcdonald s") so possessive brands still match the typed query.
  static String normalize(String s) {
    var t = s.toLowerCase();
    t = t.replaceAll(RegExp(r"['’]"), '');
    t = t.replaceAll(RegExp(r'''[\/_,.\-()&+:"!?;%$#@*]'''), ' ');
    t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
    return t;
  }

  /// Query → match tokens. Single-char tokens are noise ("1", "a")
  /// and are dropped — they caused alphabetical-looking floods.
  static List<String> tokenize(String raw) =>
      normalize(raw).split(' ').where((t) => t.length >= 2).toList();

  /// Plural folding: "oats" → "oat", "bars" → "bar".
  /// Returns every distinct alternate ("berries" → ["berrie", "berry"] —
  /// plain strip-s comes first so "cookies" keeps "cookie").
  static List<String> stems(String token) {
    final out = <String>[];
    if (token.length > 3 && token.endsWith('s') && !token.endsWith('ss')) {
      out.add(token.substring(0, token.length - 1));
    }
    if (token.length > 4 && token.endsWith('ies')) {
      final y = '${token.substring(0, token.length - 3)}y';
      if (!out.contains(y)) out.add(y);
    }
    return out;
  }

  /// First alternate, or the token itself when nothing folds.
  /// "glass" stays "glass".
  static String stem(String token) {
    final all = stems(token);
    return all.isEmpty ? token : all.first;
  }

  /// SQL candidate variants: raw tokens (max 6) plus stem fallbacks
  /// where different, capped so the LIKE fan-out stays cheap.
  static List<String> variantsForSql(String rawQuery) {
    final out = <String>[];
    for (final t in tokenize(rawQuery).take(6)) {
      out.add(t);
      for (final s in stems(t)) {
        if (out.length >= 8) break;
        if (!out.contains(s)) out.add(s);
      }
      if (out.length >= 8) break;
    }
    return out;
  }

  static bool _wordStart(String haystack, String token) =>
      RegExp('\\b${RegExp.escape(token)}').hasMatch(haystack);

  /// Best single-token hit without stemming.
  static int _direct(String token, String nameN, String brandN) {
    var best = 0;
    if (nameN.startsWith(token)) {
      best = math.max(best, 120);
    } else if (_wordStart(nameN, token)) {
      best = math.max(best, 80);
    } else if (nameN.contains(token)) {
      best = math.max(best, 40);
    }
    // Brand matches count, but a name hit always outranks a brand hit.
    if (brandN.isNotEmpty) {
      if (brandN.startsWith(token)) {
        best = math.max(best, 30);
      } else if (_wordStart(brandN, token)) {
        best = math.max(best, 20);
      } else if (brandN.contains(token)) {
        best = math.max(best, 10);
      }
    }
    return best;
  }

  /// One token's score: direct hit, else best stemmed hit at half value.
  static int tokenScore(String token, String nameN, String brandN) {
    final direct = _direct(token, nameN, brandN);
    if (direct > 0) return direct;
    var best = 0;
    for (final s in stems(token)) {
      best = math.max(best, _direct(s, nameN, brandN));
    }
    return best ~/ 2;
  }

  /// Normalized full-text equality ("musashi high protein" ≡
  /// "Musashi High Protein") — the MFP-style exact-match signal.
  static bool isExact(String rawQuery, String name) {
    final q = normalize(rawQuery);
    return q.isNotEmpty && q == normalize(name);
  }

  /// Full text score for one item: per-token best hits, a bonus when
  /// the whole phrase appears in order, and a bonus when every token
  /// hits somewhere (multi-word precision without hard AND).
  static int textScore(List<String> tokens, String name, String brand) {
    if (tokens.isEmpty) return 0;
    final nameN = normalize(name);
    final brandN = normalize(brand);
    var score = 0;
    var matched = 0;
    for (final raw in tokens) {
      final t = normalize(raw);
      if (t.isEmpty) continue;
      // Whole-name equality outranks even prefix matches — but only for
      // single-token queries. For multi-token queries a row equalling
      // ONE token while missing the rest ("Hamburger" for
      // "mcdonalds hamburger") must not beat a row matching ALL tokens.
      if (tokens.length == 1 && nameN == t) score += 150;
      final hit = tokenScore(t, nameN, brandN);
      if (hit > 0) matched++;
      score += hit;
    }
    if (tokens.length > 1) {
      final phrase = tokens.map(normalize).join(' ');
      if (phrase.isNotEmpty && nameN.contains(phrase)) score += 300;
      if (matched == tokens.length) score += 150;
    }
    return score;
  }

  /// Deterministic final tiebreak: shorter (more specific) names first,
  /// then alphabetical, then id. Ties must never look random.
  static int compareNames(String aName, String aId, String bName, String bId) {
    final an = normalize(aName);
    final bn = normalize(bName);
    if (an.length != bn.length) return an.length.compareTo(bn.length);
    final c = an.compareTo(bn);
    if (c != 0) return c;
    return aId.compareTo(bId);
  }
}
