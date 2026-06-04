import 'dart:collection';
import 'dart:convert';

import 'package:cryptography/cryptography.dart';

class StampSigner {
  static final Ed25519 _algorithm = Ed25519();

  static Future<String> publicKeyBase64FromSeed(String seedBase64) async {
    final seed = base64Decode(seedBase64);
    final keyPair = await _algorithm.newKeyPairFromSeed(seed);
    final publicKey = await keyPair.extractPublicKey();
    return base64Encode(publicKey.bytes);
  }

  static Future<String> signPayload({
    required Map<String, Object?> payload,
    required String privateSeedBase64,
  }) async {
    final keyPair = await _algorithm.newKeyPairFromSeed(
      base64Decode(privateSeedBase64),
    );
    final signature = await _algorithm.sign(
      utf8.encode(canonicalJson(payload)),
      keyPair: keyPair,
    );
    return base64Encode(signature.bytes);
  }

  static Future<bool> verifyPayload({
    required Map<String, Object?> payload,
    required String signatureBase64,
    required String publicKeyBase64,
  }) async {
    final publicKey = SimplePublicKey(
      base64Decode(publicKeyBase64),
      type: KeyPairType.ed25519,
    );
    final signature = Signature(
      base64Decode(signatureBase64),
      publicKey: publicKey,
    );

    return _algorithm.verify(
      utf8.encode(canonicalJson(payload)),
      signature: signature,
    );
  }

  static String canonicalJson(Map<String, Object?> payload) {
    return jsonEncode(_sortJson(payload));
  }

  static Object? _sortJson(Object? value) {
    if (value is Map) {
      final sorted = SplayTreeMap<String, Object?>();
      for (final entry in value.entries) {
        sorted[entry.key as String] = _sortJson(entry.value);
      }
      return sorted;
    }

    if (value is List) {
      return value.map(_sortJson).toList(growable: false);
    }

    return value;
  }
}
