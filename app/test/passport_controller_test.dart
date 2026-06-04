import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stamp_rally/features/events/models/event.dart';
import 'package:stamp_rally/features/passport/models/passport.dart';
import 'package:stamp_rally/features/passport/providers/passport_controller.dart';
import 'package:stamp_rally/features/passport/providers/passport_store.dart';
import 'package:stamp_rally/shared/utils/stamp_signer.dart';
import 'package:stamp_rally/shared/utils/stamp_token.dart';

void main() {
  test('successful stamp import rotates the passport display nonce', () async {
    final store = _MemoryPassportStore();
    final controller = PassportController(store);
    final seed = base64Encode(
      sha256.convert(utf8.encode('nonce-rotation-test-seed')).bytes,
    );
    final publicKey = await StampSigner.publicKeyBase64FromSeed(seed);
    final event = Event(
      id: 'event-1',
      name: 'Test Event',
      description: 'Test event',
      checkpoints: const [
        Checkpoint(
          id: 'checkpoint-1',
          eventId: 'event-1',
          name: 'Registration',
          description: 'Registration desk',
          order: 1,
        ),
      ],
      requiredStamps: 1,
      prizeMessage: 'Done',
      publicKeys: {'key-1': publicKey},
      createdAt: DateTime.utc(2026, 6, 4),
    );

    controller.joinEvent(event);
    final originalPassport = controller.state!;
    final token = await _signedToken(
      seed: seed,
      eventId: event.id,
      passportId: originalPassport.id,
    );

    final result = await controller.importStamp(event: event, token: token);

    expect(result.isSuccess, isTrue);
    expect(controller.state!.stamps, hasLength(1));
    expect(
      controller.state!.displayNonce,
      isNot(originalPassport.displayNonce),
    );
    expect(store.savedPassport!.displayNonce, controller.state!.displayNonce);
  });
}

Future<StampToken> _signedToken({
  required String seed,
  required String eventId,
  required String passportId,
}) async {
  final unsigned = StampToken(
    tokenId: 'token-1',
    eventId: eventId,
    passportId: passportId,
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

  return StampToken(
    tokenId: unsigned.tokenId,
    eventId: unsigned.eventId,
    passportId: unsigned.passportId,
    checkpointId: unsigned.checkpointId,
    operatorId: unsigned.operatorId,
    issuedAt: unsigned.issuedAt,
    keyId: unsigned.keyId,
    signature: signature,
  );
}

class _MemoryPassportStore extends PassportStore {
  Passport? savedPassport;

  @override
  Passport? load() => savedPassport;

  @override
  Future<void> save(Passport passport) async {
    savedPassport = passport;
  }

  @override
  Future<void> clear() async {
    savedPassport = null;
  }
}
