import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/passport.dart';

final passportStoreProvider = Provider<PassportStore>((ref) {
  throw StateError('passportStoreProvider must be overridden at app startup.');
});

class PassportStore {
  static const _boxName = 'stamp_rally_passport';
  static const _passportKey = 'active_passport';

  late final Box<String> _box;

  Future<void> open() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Passport? load() {
    final raw = _box.get(_passportKey);
    if (raw == null) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return null;
    }

    return Passport.fromJson(Map<String, Object?>.from(decoded));
  }

  Future<void> save(Passport passport) {
    return _box.put(_passportKey, jsonEncode(passport.toJson()));
  }

  Future<void> clear() {
    return _box.delete(_passportKey);
  }
}
