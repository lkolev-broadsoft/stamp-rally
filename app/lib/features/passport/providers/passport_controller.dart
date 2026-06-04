import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/utils/stamp_signer.dart';
import '../../../shared/utils/stamp_token.dart';
import '../../events/models/event.dart';
import '../models/passport.dart';
import 'passport_store.dart';

final passportControllerProvider =
    StateNotifierProvider<PassportController, Passport?>((ref) {
  return PassportController(ref.watch(passportStoreProvider));
});

class PassportController extends StateNotifier<Passport?> {
  PassportController(this._store) : super(_withDisplayNonce(_store.load())) {
    final passport = state;
    if (passport != null) {
      unawaited(_store.save(passport));
    }
  }

  static const _uuid = Uuid();
  final PassportStore _store;

  static Passport? _withDisplayNonce(Passport? passport) {
    if (passport == null || passport.displayNonce.isNotEmpty) {
      return passport;
    }

    return passport.copyWith(displayNonce: _uuid.v4());
  }

  void joinEvent(Event event) {
    final current = state;
    if (current != null && current.eventId == event.id) {
      return;
    }

    final passport = Passport(
      id: _uuid.v4(),
      eventId: event.id,
      participantName: 'jPrime visitor',
      displayNonce: _uuid.v4(),
      stamps: const [],
      startedAt: DateTime.now().toUtc(),
    );
    state = passport;
    unawaited(_store.save(passport));
  }

  void rotateDisplayNonce() {
    final passport = state;
    if (passport == null) {
      return;
    }

    final updatedPassport = passport.copyWith(displayNonce: _uuid.v4());
    state = updatedPassport;
    unawaited(_store.save(updatedPassport));
  }

  Future<ImportStampResult> importStamp({
    required Event event,
    required StampToken token,
  }) async {
    final passport = state;
    if (passport == null) {
      return const ImportStampResult(
        status: ImportStampStatus.noPassport,
        message: 'Join the event before importing stamps.',
      );
    }

    if (token.eventId != event.id || token.eventId != passport.eventId) {
      return const ImportStampResult(
        status: ImportStampStatus.wrongEvent,
        message: 'This stamp belongs to another event.',
      );
    }

    if (token.passportId != passport.id) {
      return const ImportStampResult(
        status: ImportStampStatus.wrongPassport,
        message: 'This stamp was issued for another passport.',
      );
    }

    if (passport.hasToken(token.tokenId) ||
        passport.hasStampFor(token.checkpointId)) {
      return const ImportStampResult(
        status: ImportStampStatus.duplicate,
        message: 'This checkpoint is already stamped.',
      );
    }

    if (event.checkpointById(token.checkpointId) == null) {
      return const ImportStampResult(
        status: ImportStampStatus.unknownCheckpoint,
        message: 'This checkpoint is not part of the event.',
      );
    }

    final publicKey = event.publicKeys[token.keyId];
    if (publicKey == null) {
      return const ImportStampResult(
        status: ImportStampStatus.unknownKey,
        message: 'This stamp was signed by an unknown key.',
      );
    }

    final isValid = await StampSigner.verifyPayload(
      payload: token.unsignedPayload(),
      signatureBase64: token.signature,
      publicKeyBase64: publicKey,
    );

    if (!isValid) {
      return const ImportStampResult(
        status: ImportStampStatus.invalidSignature,
        message: 'The stamp signature is invalid.',
      );
    }

    final updatedPassport = passport.copyWith(
      displayNonce: _uuid.v4(),
      stamps: [
        ...passport.stamps,
        token.toStamp(importedAt: DateTime.now().toUtc()),
      ],
    );
    state = updatedPassport;
    unawaited(_store.save(updatedPassport));

    return const ImportStampResult(
      status: ImportStampStatus.imported,
      message: 'Stamp imported.',
    );
  }
}

enum ImportStampStatus {
  imported,
  noPassport,
  wrongEvent,
  wrongPassport,
  duplicate,
  unknownCheckpoint,
  unknownKey,
  invalidSignature,
  invalidPayload,
}

class ImportStampResult {
  const ImportStampResult({
    required this.status,
    required this.message,
  });

  final ImportStampStatus status;
  final String message;

  bool get isSuccess => status == ImportStampStatus.imported;
}
