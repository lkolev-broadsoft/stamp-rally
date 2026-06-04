import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stamp_rally/shared/utils/stamp_signer.dart';
import 'package:stamp_rally/shared/utils/stamp_token.dart';

void main() {
  test('signed stamp token verifies with matching public key', () async {
    final seed = base64Encode(
      sha256.convert(utf8.encode('stamp-rally-test-seed')).bytes,
    );
    final publicKey = await StampSigner.publicKeyBase64FromSeed(seed);
    final unsigned = StampToken(
      tokenId: 'token-1',
      eventId: 'event-1',
      passportId: 'passport-1',
      checkpointId: 'checkpoint-1',
      operatorId: 'operator-1',
      issuedAt: DateTime.utc(2026, 6, 4, 10, 15),
      keyId: 'key-1',
      signature: '',
    );
    final signature = await StampSigner.signPayload(
      payload: unsigned.unsignedPayload(),
      privateSeedBase64: seed,
    );
    final token = StampToken(
      tokenId: unsigned.tokenId,
      eventId: unsigned.eventId,
      passportId: unsigned.passportId,
      checkpointId: unsigned.checkpointId,
      operatorId: unsigned.operatorId,
      issuedAt: unsigned.issuedAt,
      keyId: unsigned.keyId,
      signature: signature,
    );

    final parsed = StampToken.fromRawJson(token.toRawJson());
    final verified = await StampSigner.verifyPayload(
      payload: parsed.unsignedPayload(),
      signatureBase64: parsed.signature,
      publicKeyBase64: publicKey,
    );

    expect(verified, isTrue);
  });
}
