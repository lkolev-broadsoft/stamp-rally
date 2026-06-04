import '../../events/models/event.dart';

enum VerificationMethod {
  signedToken,
  manualCode,
}

class Stamp {
  const Stamp({
    required this.id,
    required this.eventId,
    required this.passportId,
    required this.checkpointId,
    required this.operatorId,
    required this.issuedAt,
    required this.importedAt,
    required this.verificationMethod,
    required this.keyId,
    required this.signature,
  });

  final String id;
  final String eventId;
  final String passportId;
  final String checkpointId;
  final String? operatorId;
  final DateTime issuedAt;
  final DateTime importedAt;
  final VerificationMethod verificationMethod;
  final String? keyId;
  final String? signature;

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'passportId': passportId,
      'checkpointId': checkpointId,
      'operatorId': operatorId,
      'issuedAt': issuedAt.toIso8601String(),
      'importedAt': importedAt.toIso8601String(),
      'verificationMethod': verificationMethod.name,
      'keyId': keyId,
      'signature': signature,
    };
  }

  factory Stamp.fromJson(Map<String, Object?> json) {
    return Stamp(
      id: json['id']! as String,
      eventId: json['eventId']! as String,
      passportId: json['passportId']! as String,
      checkpointId: json['checkpointId']! as String,
      operatorId: json['operatorId'] as String?,
      issuedAt: DateTime.parse(json['issuedAt']! as String),
      importedAt: DateTime.parse(json['importedAt']! as String),
      verificationMethod: VerificationMethod.values.byName(
        json['verificationMethod']! as String,
      ),
      keyId: json['keyId'] as String?,
      signature: json['signature'] as String?,
    );
  }
}

class Passport {
  const Passport({
    required this.id,
    required this.eventId,
    required this.participantName,
    required this.displayNonce,
    required this.stamps,
    required this.startedAt,
  });

  final String id;
  final String eventId;
  final String participantName;
  final String displayNonce;
  final List<Stamp> stamps;
  final DateTime startedAt;

  bool hasStampFor(String checkpointId) {
    return stamps.any((stamp) => stamp.checkpointId == checkpointId);
  }

  bool hasToken(String tokenId) {
    return stamps.any((stamp) => stamp.id == tokenId);
  }

  int completedCountFor(Event event) {
    return event.checkpoints
        .where((checkpoint) => hasStampFor(checkpoint.id))
        .length;
  }

  bool hasUnlockedPrize(Event event) {
    return completedCountFor(event) >= event.stampsNeeded;
  }

  Passport copyWith({
    String? id,
    String? eventId,
    String? participantName,
    String? displayNonce,
    List<Stamp>? stamps,
    DateTime? startedAt,
  }) {
    return Passport(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      participantName: participantName ?? this.participantName,
      displayNonce: displayNonce ?? this.displayNonce,
      stamps: stamps ?? this.stamps,
      startedAt: startedAt ?? this.startedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'participantName': participantName,
      'displayNonce': displayNonce,
      'stamps': stamps.map((stamp) => stamp.toJson()).toList(),
      'startedAt': startedAt.toIso8601String(),
    };
  }

  factory Passport.fromJson(Map<String, Object?> json) {
    final rawStamps = json['stamps']! as List<Object?>;

    return Passport(
      id: json['id']! as String,
      eventId: json['eventId']! as String,
      participantName: json['participantName']! as String,
      displayNonce: json['displayNonce'] as String? ?? '',
      stamps: rawStamps
          .map(
            (stamp) => Stamp.fromJson(
              Map<String, Object?>.from(stamp! as Map),
            ),
          )
          .toList(growable: false),
      startedAt: DateTime.parse(json['startedAt']! as String),
    );
  }
}
