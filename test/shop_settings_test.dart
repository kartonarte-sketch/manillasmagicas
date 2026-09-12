import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manillasmagicas/models.dart';
import 'package:manillasmagicas/services/shop_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('changed PIN survives reload and rejects the previous PIN', () async {
    final settings = ShopSettings();
    await settings.load();
    expect(settings.verifyPin('2024'), isTrue);
    await settings.savePin('7391');
    final restored = ShopSettings();
    await restored.load();
    expect(restored.verifyPin('7391'), isTrue);
    expect(restored.verifyPin('2024'), isFalse);
    expect(restored.verifyPin('abcd'), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('shop.adminPin.v1'), isNot(contains('7391')));
  });

  test('palette additions, edits and deletions survive reload, including empty palette', () async {
    final settings = ShopSettings();
    await settings.load();
    await settings.savePalette([
      CustomPaletteColor(id: 'one', name: 'Azul', color: Colors.blue),
      CustomPaletteColor(id: 'two', name: 'Rojo', color: Colors.red),
    ]);
    await settings.savePalette([
      CustomPaletteColor(id: 'two', name: 'Rosa', color: Colors.pink),
    ]);
    final restored = ShopSettings();
    await restored.load();
    expect(restored.palette!.single.name, 'Rosa');
    expect(restored.palette!.single.color.toARGB32(), Colors.pink.toARGB32());
    await restored.savePalette([]);
    await settings.load();
    expect(settings.palette, isEmpty);
  });

  test('custom prices survive reload and reject invalid values', () async {
    final settings = ShopSettings();
    await settings.load();
    await settings.savePrices([4500, 6000, 7500]);
    final restored = ShopSettings();
    await restored.load();
    expect(restored.prices, [4500, 6000, 7500]);
    await expectLater(restored.savePrices([0, 10, 20]), throwsArgumentError);
    await expectLater(restored.savePin('12ab'), throwsArgumentError);
  });
}
