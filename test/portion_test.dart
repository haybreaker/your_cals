import 'package:flutter_test/flutter_test.dart';
import 'package:your_cals/domain/portion.dart';

void main() {
  group('PortionMath', () {
    test('g and ml map 1:1', () {
      expect(
        PortionMath.resolveGrams(
            unit: PortionUnit.g, qty: 250, servingGrams: 100),
        250,
      );
      expect(
        PortionMath.resolveGrams(
            unit: PortionUnit.ml, qty: 250, servingGrams: 100),
        250,
      );
    });

    test('servings multiply the serving gram weight', () {
      expect(
        PortionMath.resolveGrams(
            unit: PortionUnit.serving, qty: 1.5, servingGrams: 214),
        321,
      );
      expect(
        PortionMath.resolveGrams(
            unit: PortionUnit.serving, qty: 2, servingGrams: 60),
        120,
      );
    });

    test('convert keeps total grams stable across units', () {
      // 2 servings × 100 g = 200 g → 200 g in g-mode
      final toG = PortionMath.convert(
        qty: 2, from: PortionUnit.serving, to: PortionUnit.g, servingGrams: 100,
      );
      expect(toG.qty, 200);

      // 300 g → 3 servings of 100 g
      final toServ = PortionMath.convert(
        qty: 300, from: PortionUnit.g, to: PortionUnit.serving, servingGrams: 100,
      );
      expect(toServ.qty, 3);
    });

    test('zero serving weight does not divide by zero', () {
      final r = PortionMath.convert(
        qty: 100, from: PortionUnit.g, to: PortionUnit.serving, servingGrams: 0,
      );
      expect(r.qty, 0);
    });

    test('kitchen units use fixed conversions', () {
      expect(
        PortionMath.resolveGrams(
            unit: PortionUnit.tsp, qty: 2, servingGrams: 100),
        10,
      );
      expect(
        PortionMath.resolveGrams(
            unit: PortionUnit.tbsp, qty: 1.5, servingGrams: 100),
        22.5,
      );
      expect(
        PortionMath.resolveGrams(
            unit: PortionUnit.cup, qty: 2, servingGrams: 100),
        480,
      );
      expect(
        PortionMath.resolveGrams(
            unit: PortionUnit.oz, qty: 1, servingGrams: 100),
        closeTo(28.35, 0.001),
      );
    });

    test('convert keeps grams stable into kitchen units', () {
      final toTbsp = PortionMath.convert(
        qty: 30, from: PortionUnit.g, to: PortionUnit.tbsp, servingGrams: 100,
      );
      expect(toTbsp.qty, 2);

      final toG = PortionMath.convert(
        qty: 2, from: PortionUnit.cup, to: PortionUnit.g, servingGrams: 100,
      );
      expect(toG.qty, 480);
    });
  });
}
