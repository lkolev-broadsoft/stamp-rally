import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/utils/stamp_signer.dart';
import '../../operator/models/operator.dart';
import '../models/event.dart';

const demoEventId = 'jprime-2026-stamp-rally';

final demoOperatorsProvider = Provider<List<Operator>>((ref) {
  return _demoOperatorSeeds
      .map(
        (seed) => Operator(
          id: seed.operatorId,
          eventId: demoEventId,
          checkpointId: seed.checkpointId,
          name: seed.name,
          pin: seed.pin,
          keyId: seed.keyId,
          privateSeedBase64: _seedFromLabel(seed.seedLabel),
        ),
      )
      .toList(growable: false);
});

final demoEventProvider = FutureProvider<Event>((ref) async {
  final operators = ref.watch(demoOperatorsProvider);
  final publicKeys = <String, String>{};

  for (final operator in operators) {
    publicKeys[operator.keyId] = await StampSigner.publicKeyBase64FromSeed(
      operator.privateSeedBase64,
    );
  }

  return Event(
    id: demoEventId,
    name: 'jPrime 2026 Stamp Rally',
    description: 'Collect booth stamps during the conference.',
    requiredStamps: 3,
    prizeMessage: 'Prize unlocked. Show this screen at the check-in desk.',
    createdAt: DateTime.utc(2026, 6, 3),
    publicKeys: publicKeys,
    checkpoints: const [
      Checkpoint(
        id: 'registration',
        eventId: demoEventId,
        name: 'Registration',
        description: 'Start the rally at check-in.',
        order: 1,
      ),
      Checkpoint(
        id: 'community',
        eventId: demoEventId,
        name: 'Community Booth',
        description: 'Meet the community partners.',
        order: 2,
      ),
      Checkpoint(
        id: 'sponsor',
        eventId: demoEventId,
        name: 'Sponsor Booth',
        description: 'Visit a sponsor station.',
        order: 3,
      ),
      Checkpoint(
        id: 'feedback',
        eventId: demoEventId,
        name: 'Feedback Desk',
        description: 'Close the loop with feedback.',
        order: 4,
      ),
    ],
  );
});

String _seedFromLabel(String label) {
  return base64Encode(sha256.convert(utf8.encode(label)).bytes);
}

const _demoOperatorSeeds = [
  _DemoOperatorSeed(
    operatorId: 'operator-registration',
    checkpointId: 'registration',
    keyId: 'registration-key',
    pin: '1001',
    name: 'Registration',
    seedLabel: 'stamp-rally:jprime-2026:registration',
  ),
  _DemoOperatorSeed(
    operatorId: 'operator-community',
    checkpointId: 'community',
    keyId: 'community-key',
    pin: '1002',
    name: 'Community Booth',
    seedLabel: 'stamp-rally:jprime-2026:community',
  ),
  _DemoOperatorSeed(
    operatorId: 'operator-sponsor',
    checkpointId: 'sponsor',
    keyId: 'sponsor-key',
    pin: '1003',
    name: 'Sponsor Booth',
    seedLabel: 'stamp-rally:jprime-2026:sponsor',
  ),
];

class _DemoOperatorSeed {
  const _DemoOperatorSeed({
    required this.operatorId,
    required this.checkpointId,
    required this.keyId,
    required this.pin,
    required this.name,
    required this.seedLabel,
  });

  final String operatorId;
  final String checkpointId;
  final String keyId;
  final String pin;
  final String name;
  final String seedLabel;
}
