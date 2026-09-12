import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models.dart';

/// Settings for this browser/device. Does not grant server-side permissions.
class ShopSettings {
  late SharedPreferences _preferences;
  Map<String, dynamic>? _pin;
  List<CustomPaletteColor>? palette;
  List<double>? prices;

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();
    final pinJson = _preferences.getString('shop.adminPin.v1');
    _pin = pinJson == null ? null : jsonDecode(pinJson) as Map<String, dynamic>;
    final paletteJson = _preferences.getString('shop.palette.v1');
    palette = paletteJson == null
        ? null
        : (jsonDecode(paletteJson) as List)
            .map((item) => CustomPaletteColor.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList();
    final pricesJson = _preferences.getString('shop.prices.v1');
    prices = pricesJson == null
        ? null
        : (jsonDecode(pricesJson) as List).map((value) => (value as num).toDouble()).toList();
  }

  String _digest(String salt, String pin) => sha256.convert(utf8.encode('$salt:$pin')).toString();

  bool verifyPin(String pin) {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) return false;
    // Compatibility with the original access until the owner changes it.
    if (_pin == null) return pin == '2024';
    return _digest(_pin!['salt'] as String, pin) == _pin!['digest'];
  }

  Future<void> savePin(String pin) async {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) throw ArgumentError('PIN inválido');
    final random = Random.secure();
    final salt = base64Encode(List.generate(24, (_) => random.nextInt(256)));
    final record = {'salt': salt, 'digest': _digest(salt, pin)};
    if (!await _preferences.setString('shop.adminPin.v1', jsonEncode(record))) {
      throw StateError('No se pudo guardar el PIN');
    }
    _pin = record;
  }

  Future<void> savePalette(List<CustomPaletteColor> colors) async {
    if (!await _preferences.setString('shop.palette.v1', jsonEncode(colors.map((c) => c.toJson()).toList()))) {
      throw StateError('No se pudo guardar la paleta');
    }
    palette = List.of(colors);
  }

  Future<void> savePrices(List<double> values) async {
    if (values.length != 3 || values.any((value) => !value.isFinite || value <= 0)) {
      throw ArgumentError('Los precios deben ser mayores que cero');
    }
    if (!await _preferences.setString('shop.prices.v1', jsonEncode(values))) {
      throw StateError('No se pudieron guardar los precios');
    }
    prices = List.of(values);
  }
}
