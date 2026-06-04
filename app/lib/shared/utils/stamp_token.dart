import 'dart:convert';

import '../../features/passport/models/passport.dart';

class StampToken {
  const StampToken({
    required this.tokenId,
    required this.eventId,
    required this.passportId,
    required this.checkpointId,
    required this.operatorId,
    required this.issuedAt,
    required this.keyId,
    required this.signature,
  });

  final String tokenId;
  final String eventId;
  final String passportId;
  final String checkpointId;
  final String operatorId;
  final DateTime issuedAt;
  final String keyId;
  final String signature;

  static const appId = 'rally';
  static const version = 1;
  static const type = 'stamp';

  Map<String, Object?> unsignedPayload() {
    return {
      'app': appId,
      'version': version,
      'type': type,
      'tokenId': tokenId,
      'eventId': eventId,
      'passportId': passportId,
      'checkpointId': checkpointId,
      'operatorId': operatorId,
      'issuedAt': issuedAt.toIso8601String(),
      'keyId': keyId,
    };
  }

  Map<String, Object?> toJson() {
    return {
      ...unsignedPayload(),
      'signature': signature,
    };
  }

  String toRawJson() => jsonEncode(toJson());

  Stamp toStamp({required DateTime importedAt}) {
    return Stamp(
      id: tokenId,
      eventId: eventId,
      passportId: passportId,
      checkpointId: checkpointId,
      operatorId: operatorId,
      issuedAt: issuedAt,
      importedAt: importedAt,
      verificationMethod: VerificationMethod.signedToken,
      keyId: keyId,
      signature: signature,
    );
  }

  factory StampToken.fromRawJson(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map) {
      throw const FormatException('QR payload must be a JSON object.');
    }
    return StampToken.fromJson(Map<String, Object?>.from(decoded));
  }

  factory StampToken.fromJson(Map<String, Object?> json) {
    _requireEnvelope(json, type);

    return StampToken(
      tokenId: json['tokenId']! as String,
      eventId: json['eventId']! as String,
      passportId: json['passportId']! as String,
      checkpointId: json['checkpointId']! as String,
      operatorId: json['operatorId']! as String,
      issuedAt: DateTime.parse(json['issuedAt']! as String).toUtc(),
      keyId: json['keyId']! as String,
      signature: json['signature']! as String,
    );
  }
}

void _requireEnvelope(Map<String, Object?> json, String expectedType) {
  if (json['app'] != StampToken.appId ||
      json['version'] != StampToken.version ||
      json['type'] != expectedType) {
    throw const FormatException('QR payload is not a compatible Stamp Rally payload.');
  }
}
